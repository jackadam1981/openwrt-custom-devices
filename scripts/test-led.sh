#!/bin/bash
# LED Test Script
# Test LED blinking patterns

if [ -z "$1" ]; then
    echo "Usage: $0 <ip_address> [pattern]"
    echo ""
    echo "Patterns:"
    echo "  1 or slow       - Slow blink (1s interval)"
    echo "  2 or slow2      - Slow blink (2s interval)"
    echo "  0.5 or fast     - Fast blink (0.5s interval)"
    echo "  0.1 or veryfast - Very fast blink (0.1s interval)"
    echo "  alternate       - Blue on/off, Red on/off (0.15s interval)"
    echo "  alternate-slow  - Blue on/off, Red on/off (0.5s interval)"
    echo "  both-on         - Both LEDs on"
    echo "  both-off        - Both LEDs off"
    exit 1
fi

IP="$1"
PATTERN="${2:-slow}"

LED_R="/sys/class/leds/hiker:red:led_r/brightness"
LED_R_TRIGGER="/sys/class/leds/hiker:red:led_r/trigger"
LED_B="/sys/class/leds/hiker:blue:led_b/brightness"
LED_B_TRIGGER="/sys/class/leds/hiker:blue:led_b/trigger"

echo "Testing LED on $IP with pattern: $PATTERN"
echo "Press Ctrl+C to stop"
echo "---"

# Helper functions
set_trigger() {
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" "echo 'none' > $LED_R_TRIGGER 2>/dev/null && echo 'none' > $LED_B_TRIGGER 2>/dev/null" 2>/dev/null
}

set_red() {
    local val=$1
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" "echo $val > $LED_R 2>/dev/null" 2>/dev/null
}

set_blue() {
    local val=$1
    ssh -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
        root@"$IP" "echo $val > $LED_B 2>/dev/null" 2>/dev/null
}

# Set trigger mode
set_trigger

# Pattern selection
case "$PATTERN" in
    1|slow)
        echo "Pattern: Slow blink (1s interval) - Red LED only"
        while true; do
            set_red 1
            sleep 1
            set_red 0
            sleep 1
        done
        ;;
    2|slow2)
        echo "Pattern: Slow blink (2s interval) - Red LED only"
        while true; do
            set_red 1
            sleep 2
            set_red 0
            sleep 2
        done
        ;;
    0.5|fast)
        echo "Pattern: Fast blink (0.5s interval) - Red LED only"
        while true; do
            set_red 1
            sleep 0.5
            set_red 0
            sleep 0.5
        done
        ;;
    0.1|veryfast)
        echo "Pattern: Very fast blink (0.1s interval) - Red LED only"
        while true; do
            set_red 1
            sleep 0.1
            set_red 0
            sleep 0.1
        done
        ;;
    alternate)
        echo "Pattern: Alternate (0.5s on, instant switch) - Blue on/off, Red on/off"
        while true; do
            # Blue: on
            set_blue 1
            set_red 0
            sleep 0.5
            # Blue: off
            set_blue 0
            # Red: on (instant switch, no delay)
            set_red 1
            sleep 0.5
            # Red: off
            set_red 0
            # Blue: on (instant switch, no delay)
        done
        ;;
    alternate-slow)
        echo "Pattern: Alternate (1s on, instant switch) - Blue on/off, Red on/off"
        while true; do
            # Blue: on
            set_blue 1
            set_red 0
            sleep 1
            # Blue: off
            set_blue 0
            # Red: on (instant switch, no delay)
            set_red 1
            sleep 1
            # Red: off
            set_red 0
            # Blue: on (instant switch, no delay)
        done
        ;;
    both-on)
        echo "Pattern: Both LEDs on"
        set_red 1
        set_blue 1
        sleep 10
        set_red 0
        set_blue 0
        ;;
    both-off)
        echo "Pattern: Both LEDs off"
        set_red 0
        set_blue 0
        ;;
    *)
        echo "Unknown pattern: $PATTERN"
        exit 1
        ;;
esac

