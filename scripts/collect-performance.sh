#!/bin/sh
# Hiker RT5350 性能数据收集脚本
# 通过SSH连接到设备并收集性能指标

# 默认设备IP
DEFAULT_IP="192.168.1.1"

# 检查参数
if [ -z "$1" ]; then
    echo "用法: $0 <设备IP>"
    echo ""
    echo "示例:"
    echo "  $0 192.168.1.1"
    echo "  $0 192.168.168.1"
    exit 1
fi

DEVICE_IP="$1"

echo "======================================"
echo "Hiker RT5350 性能数据收集"
echo "======================================"
echo ""
echo "目标设备: $DEVICE_IP"
echo "开始收集..."
echo ""

# 检查设备是否可达
if ! ping -c 1 -W 2 "$DEVICE_IP" > /dev/null 2>&1; then
    echo "❌ 错误: 无法连接到设备 $DEVICE_IP"
    echo "请检查:"
    echo "  - 设备是否已启动"
    echo "  - IP地址是否正确"
    echo "  - 网络是否连通"
    exit 1
fi

echo "✓ 设备可达"
echo ""

# 创建输出文件
OUTPUT_FILE="performance-report-$(date +%Y%m%d-%H%M%S).txt"

# 连接设备并收集数据
echo "正在连接设备并收集数据..."
echo ""

# 直接使用SSH连接（类似flash.sh的方式）
ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    -o ConnectTimeout=10 \
    root@"$DEVICE_IP" 'bash -s' << 'REMOTE_COMMANDS' | tee "$OUTPUT_FILE"
# 远程执行的命令
echo "======================================"
echo "Hiker RT5350 性能报告"
echo "======================================"
echo ""
echo "收集时间: $(date)"
echo ""

echo "=== 1. OpenWrt 版本信息 ==="
if [ -f /etc/openwrt_release ]; then
    cat /etc/openwrt_release
elif [ -f /etc/os-release ]; then
    cat /etc/os-release | grep -E '^NAME=|^VERSION='
else
    echo "无法确定OpenWrt版本"
fi
echo ""

echo "=== 2. 系统负载 ==="
uptime
echo ""

echo "=== 3. CPU 使用情况 ==="
top -bn1 | grep -E "^%Cpu|^CPU:"
echo ""

echo "=== 4. 内存使用情况 (KB) ==="
free -k
echo ""

echo "=== 5. 存储使用情况 ==="
df -h | grep -E "Filesystem|tmpfs|overlay|ubi"
echo ""

echo "=== 6. 运行的进程 ==="
ps aux | head -20
echo ""

echo "=== 7. 网络接口 ==="
ip -4 addr show | grep -E "^[0-9]+:|inet "
echo ""

echo "=== 8. 系统启动时间 ==="
if [ -f /proc/uptime ]; then
    uptime_seconds=$(cat /proc/uptime | cut -d' ' -f1 | cut -d'.' -f1)
    days=$((uptime_seconds / 86400))
    hours=$((uptime_seconds % 86400 / 3600))
    minutes=$((uptime_seconds % 3600 / 60))
    echo "系统已运行: ${days}天 ${hours}小时 ${minutes}分钟"
fi
echo ""

echo "=== 9. 内核信息 ==="
uname -a
echo ""

echo "======================================"
echo "收集完成"
echo "======================================"
REMOTE_COMMANDS

# 检查收集结果
SSH_EXIT=$?

if [ $SSH_EXIT -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
    echo ""
    echo "✓ 数据收集完成"
    echo "  报告已保存到: $OUTPUT_FILE"
    echo ""
    echo "快速查看:"
    grep -A2 "系统负载\|Load average" "$OUTPUT_FILE" || echo "  查看完整报告: cat $OUTPUT_FILE"
else
    echo ""
    echo "❌ 数据收集失败"
    echo "  SSH退出码: $SSH_EXIT"
    exit 1
fi

