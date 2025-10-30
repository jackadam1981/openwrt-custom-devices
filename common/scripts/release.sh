#!/bin/sh
# Hiker 固件发布脚本
# 自动备份固件并生成校验文件

if [ -z "$1" ]; then
    echo "用法: $0 <版本号>"
    echo ""
    echo "示例:"
    echo "  $0 v0.2"
    echo "  $0 v0.3-beta"
    exit 1
fi

VERSION="$1"
SRC_FIRMWARE="bin/targets/ramips/rt305x/openwrt-ramips-rt305x-hiker_hiker-squashfs-sysupgrade.bin"
DEST_FIRMWARE="releases/hiker-25.300_${VERSION}.bin"

echo "======================================"
echo "Hiker 固件发布"
echo "======================================"
echo ""
echo "版本: $VERSION"
echo "源文件: $SRC_FIRMWARE"
echo "目标: $DEST_FIRMWARE"
echo ""

# 检查源文件
if [ ! -f "$SRC_FIRMWARE" ]; then
    echo "❌ 错误: 固件文件不存在"
    echo "请先运行: ./fast-hiker.sh"
    exit 1
fi

# 创建 releases 目录
mkdir -p releases

# 复制固件
echo "==> [1/3] 复制固件..."
cp "$SRC_FIRMWARE" "$DEST_FIRMWARE"
echo "✓ 固件已复制"

# 复制编译生成的校验文件
echo ""
echo "==> [2/3] 复制 SHA256 校验文件..."
SRC_SHA256="bin/targets/ramips/rt305x/sha256sums"
if [ -f "$SRC_SHA256" ]; then
    # 提取对应固件的SHA256
    grep "$(basename $SRC_FIRMWARE)" "$SRC_SHA256" | awk '{print $1}' > "${DEST_FIRMWARE}.sha256"
    echo "✓ SHA256: $(cat ${DEST_FIRMWARE}.sha256)"
else
    echo "⚠️  编译目录中没有 sha256sums，手动生成..."
    sha256sum "$DEST_FIRMWARE" | awk '{print $1}' > "${DEST_FIRMWARE}.sha256"
    echo "✓ SHA256: $(cat ${DEST_FIRMWARE}.sha256)"
fi

# 生成 MD5
echo ""
echo "==> [3/3] 生成 MD5 校验..."
md5sum "$DEST_FIRMWARE" | awk '{print $1}' > "${DEST_FIRMWARE}.md5"
echo "✓ MD5: $(cat ${DEST_FIRMWARE}.md5)"

echo ""
echo "======================================"
echo "✓ 发布完成"
echo "======================================"
echo ""
echo "发布文件:"
ls -lh "$DEST_FIRMWARE"*
echo ""
echo "固件大小: $(stat -c %s $DEST_FIRMWARE | awk '{printf "%.2f MB", $1/1024/1024}')"

