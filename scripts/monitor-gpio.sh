#!/bin/bash
# GPIO Monitor Script
# Monitor all GPIO pins for button presses

if [ -z "$1" ]; then
    echo "Usage: $0 <ip_address>"
    echo "Example: $0 192.168.168.1"
    exit 1
fi

IP="$1"

echo "Monitoring all GPIO pins on $IP..."
echo "Press Ctrl+C to stop"
echo "---"

# Function to get all exported GPIOs
get_gpios() {
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" \
        "ls -d /sys/class/gpio/gpio[0-9]* 2>/dev/null | sed 's|.*gpio||' | sort -n" 2>/dev/null
}

# Function to read GPIO value
read_gpio() {
    local pin=$1
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" \
        "cat /sys/class/gpio/gpio${pin}/value 2>/dev/null" 2>/dev/null
}

# Function to read GPIO direction
read_gpio_dir() {
    local pin=$1
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" \
        "cat /sys/class/gpio/gpio${pin}/direction 2>/dev/null" 2>/dev/null
}

# Function to read interrupt count
read_interrupts() {
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" \
        "cat /proc/interrupts | grep gpio" 2>/dev/null
}

# Get initial GPIO list
echo "Detecting exported GPIOs..."
GPIO_LIST=$(get_gpios)

echo "Found GPIOs: $GPIO_LIST"
echo "---"

# Export all common GPIOs as inputs for monitoring
echo "Exporting GPIOs 0-31 for monitoring..."
for pin in {0..31}; do
    if ! echo "$GPIO_LIST" | grep -q "^${pin}$"; then
        # Export GPIO
        ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no \
            root@"$IP" \
            "echo $pin > /sys/class/gpio/export 2>/dev/null" 2>/dev/null
        
        # Set as input
        ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no \
            root@"$IP" \
            "echo in > /sys/class/gpio/gpio${pin}/direction 2>/dev/null" 2>/dev/null
    fi
done

# Refresh GPIO list after export
sleep 1
GPIO_LIST=$(get_gpios)
echo "Monitoring GPIOs: $GPIO_LIST"
echo "---"

# Monitor loop
count=0
prev_vals=""

while true; do
    count=$((count + 1))
    timestamp=$(date '+%H:%M:%S')
    
    # Read all GPIO values
    current_vals=""
    changed_pins=""
    
    for pin in $GPIO_LIST; do
        val=$(read_gpio "$pin")
        dir=$(read_gpio_dir "$pin")
        
        # Skip if not readable
        [ -z "$val" ] && continue
        
        # Build current values string
        current_vals="${current_vals}gpio${pin}=${val};"
        
        # Check if value changed
        if [ -n "$prev_vals" ]; then
            prev_val=$(echo "$prev_vals" | grep -o "gpio${pin}=[01]" | cut -d= -f2)
            if [ "$prev_val" != "$val" ]; then
                changed_pins="${changed_pins}gpio${pin}:${prev_val}->${val} "
            fi
        fi
    done
    
    # Display changes
    if [ -n "$changed_pins" ]; then
        printf "\n[%s] #%d - *** CHANGED ***\n" "$timestamp" "$count"
        echo "$changed_pins" | tr ' ' '\n'
        echo "---"
    else
        # Show status every 10 iterations
        if [ $((count % 10)) -eq 0 ]; then
            printf "[%s] #%d - Monitoring (no changes)\n" "$timestamp" "$count"
        fi
    fi
    
    prev_vals="$current_vals"
    sleep 0.1  # Faster polling for responsiveness
done

