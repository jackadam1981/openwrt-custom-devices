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
        ssh \
            -o "StrictHostKeyChecking=no" \
            -o "UserKnownHostsFile=/dev/null" \
            -o "HostKeyAlgorithms=+ssh-rsa" \
            -o "PubkeyAcceptedAlgorithms=+ssh-rsa" \
            root@$DEVICE_IP \
            "sysupgrade -n /tmp/sysupgrade.bin"
        
        echo ""
        echo "======================================"
        echo "✓ 刷机命令已执行"
        echo "======================================"
        echo ""
        echo "设备正在重启..."
        echo "约 1-2 分钟后访问: http://192.168.1.1/"
        echo ""
        ;;
    *)
        echo "已取消"
        exit 0
        ;;
esac

