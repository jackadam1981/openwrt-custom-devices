#!/bin/sh
# Hiker 固件刷机脚本
# 兼容 sh/bash

# 默认固件路径
DEFAULT_FIRMWARE="bin/targets/ramips/rt305x/openwrt-ramips-rt305x-hiker_hiker-squashfs-sysupgrade.bin"

# 检查参数
if [ -z "$1" ]; then
    echo "用法: $0 <设备IP> [固件文件]"
    echo ""
    echo "示例:"
    echo "  $0 192.168.1.1                         # 使用最新编译的固件"
    echo "  $0 192.168.1.1 releases/hiker-25.300_v0.2.bin  # 使用指定固件"
    exit 1
fi

DEVICE_IP="$1"
FIRMWARE="${2:-$DEFAULT_FIRMWARE}"

echo "======================================"
echo "Hiker 固件刷机"
echo "======================================"
echo ""
echo "目标设备: $DEVICE_IP"
echo "固件文件: $FIRMWARE"
echo ""

# 检查固件文件
if [ ! -f "$FIRMWARE" ]; then
    echo "❌ 错误: 固件文件不存在"
    echo "请先运行: ./docker-compile.sh"
    exit 1
fi

# 显示固件信息
echo "固件信息:"
ls -lh "$FIRMWARE"
echo ""

# 上传固件
echo "==> [1/2] 上传固件到设备..."
scp -O \
    -o "StrictHostKeyChecking=no" \
    -o "UserKnownHostsFile=/dev/null" \
    -o "HostKeyAlgorithms=+ssh-rsa" \
    -o "PubkeyAcceptedAlgorithms=+ssh-rsa" \
    "$FIRMWARE" root@$DEVICE_IP:/tmp/sysupgrade.bin

if [ $? -ne 0 ]; then
    echo "❌ 固件上传失败"
    exit 1
fi

echo "✓ 固件上传成功"
echo ""

# 执行刷机
echo "==> [2/2] 开始刷机..."
echo ""
echo "⚠️  升级说明："
echo "  - 使用 -n 不保留配置（推荐）"
echo "  - 刷机后设备会重启，等待约 1-2 分钟"
echo "  - 刷机后默认 IP: 192.168.1.1"
echo ""
printf "确认开始刷机？[y/N] "
read -r REPLY

case "$REPLY" in
    [Yy]*)
        echo ""
        ssh \
            -o "StrictHostKeyChecking=no" \
            -o "UserKnownHostsFile=/dev/null" \
            -o "HostKeyAlgorithms=+ssh-rsa" \
            -o "PubkeyAcceptedAlgorithms=+ssh-rsa" \
            root@$DEVICE_IP \
            "sysupgrade -F -n /tmp/sysupgrade.bin"
        
        echo ""
        echo "======================================"
        echo "✓ 刷机命令已执行"
        echo "======================================"
        echo ""
        echo "设备正在重启..."
        echo ""
        
        # Start timing immediately after sysupgrade
        START_TIME=$(date +%s)
        
        # Wait 3 minutes before testing
        echo "等待 3 分钟后开始测试设备连接..."
        WAIT_COUNT=180
        while [ $WAIT_COUNT -gt 0 ]; do
            printf "\r剩余等待: %d 秒 " "$WAIT_COUNT"
            sleep 1
            WAIT_COUNT=$((WAIT_COUNT - 1))
        done
        printf "\r                                  \r"
        echo ""
        
        # Wait for device reboot and test connectivity
        echo "开始测试设备连接..."
        MAX_WAIT=600  # Maximum wait time (10 minutes) in seconds
        INTERVAL=2    # Check interval in seconds
        
        while true; do
            CURRENT_TIME=$(date +%s)
            ELAPSED=$((CURRENT_TIME - START_TIME))
            
            # Try to ping the device
            if ping -c 1 -W 1 192.168.1.1 >/dev/null 2>&1; then
                printf "\r"
                echo "✓ 设备已上线!"
                echo ""
                
                # Test SSH connection
                echo "测试 SSH 连接..."
                if ssh \
                    -o "StrictHostKeyChecking=no" \
                    -o "UserKnownHostsFile=/dev/null" \
                    -o "HostKeyAlgorithms=+ssh-rsa" \
                    -o "PubkeyAcceptedAlgorithms=+ssh-rsa" \
                    -o "ConnectTimeout=10" \
                    root@192.168.1.1 \
                    "echo 'SSH 连接成功'" >/dev/null 2>&1; then
                    echo "✓ SSH 连接成功"
                    echo ""
                    echo "======================================"
                    echo "首次启动时间: ${ELAPSED} 秒"
                    echo "======================================"
                    echo ""
                    echo "设备访问地址: http://192.168.1.1/"
                    echo ""
                    
                    # Collect system information via SSH
                    echo "收集系统信息..."
                    ssh \
                        -o "StrictHostKeyChecking=no" \
                        -o "UserKnownHostsFile=/dev/null" \
                        -o "HostKeyAlgorithms=+ssh-rsa" \
                        -o "PubkeyAcceptedAlgorithms=+ssh-rsa" \
                        root@192.168.1.1 \
                        "echo '=== 系统信息 ===' && \
                         cat /proc/version && \
                         echo '' && \
                         echo '=== 内存使用 ===' && \
                         free -h && \
                         echo '' && \
                         echo '=== CPU 使用 ===' && \
                         top -bn1 | head -5 && \
                         echo '' && \
                         echo '=== 磁盘使用 ===' && \
                         df -h"
                    
                    echo ""
                    echo "======================================"
                    echo "系统信息收集完成"
                    echo "======================================"
                    echo ""
                    break
                else
                    echo "⚠️  SSH 连接失败，继续等待..."
                    sleep $INTERVAL
                fi
            fi
            
            # Check timeout
            if [ $ELAPSED -ge $MAX_WAIT ]; then
                printf "\r"
                echo "⚠️  超时：设备在 $(($MAX_WAIT / 60)) 分钟内未响应"
                echo "请手动检查设备状态"
                echo ""
                break
            fi
            
            # Show progress
            printf "\r等待中... (%d 秒) " "$ELAPSED"
            sleep $INTERVAL
        done
        ;;
    *)
        echo "已取消"
        exit 0
        ;;
esac

