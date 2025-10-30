#!/bin/bash
#
# Hiker 快速编译脚本（使用预编译工具链镜像）
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

OPENWRT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_IMAGE="openwrt-mipsel:prebuilt"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Hiker 快速编译（预编译工具链）${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    exit 1
fi

# 检查镜像是否存在
if ! docker image inspect ${DOCKER_IMAGE} &> /dev/null 2>&1; then
    echo -e "${RED}错误: 预编译镜像不存在${NC}"
    echo "镜像名称: ${DOCKER_IMAGE}"
    echo ""
    echo "请先构建预编译镜像，或使用 ./local-hiker.sh"
    exit 1
fi

# 清理模式
if [ "$1" = "--clean" ]; then
    echo -e "${YELLOW}=======================================${NC}"
    echo -e "${YELLOW}  清理编译缓存${NC}"
    echo -e "${YELLOW}=======================================${NC}"
    echo ""
    echo -e "${YELLOW}将清理以下目录（需要 sudo 密码）:${NC}"
    echo "  • build_dir/target-mipsel_24kc_musl/"
    echo "  • tmp/"
    echo "  • .config"
    echo ""
    echo -e "${YELLOW}⚠️  注意: staging_dir 保留（预编译工具链）${NC}"
    echo -e "${RED}警告: 配置变化时必须清理缓存${NC}"
    echo -e "${YELLOW}请输入 sudo 密码：${NC}"
    
    # 交互式 sudo 清理（保留 staging_dir 中的工具链）
    sudo rm -rf "${OPENWRT_DIR}/build_dir/target-mipsel_24kc_musl" \
                "${OPENWRT_DIR}/tmp" \
                "${OPENWRT_DIR}/.config"
    
    # 使用 Docker 清理容器内的缓存
    echo ""
    echo -e "${YELLOW}清理 Docker 容器内缓存...${NC}"
    docker run --rm -v "${OPENWRT_DIR}:/openwrt" -w /openwrt ${DOCKER_IMAGE} \
        bash -c "rm -rf build_dir/target-mipsel_24kc_musl/root* tmp/" 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}✓ 清理完成${NC}"
    echo ""
    echo "下一步: 运行 ./fast-hiker.sh 开始快速编译"
    echo ""
    exit 0
fi

# 快速编译模式
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}  快速编译 Hiker 固件${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  注意: 如果配置变化较大（如添加/移除 WiFi），${NC}"
echo -e "${YELLOW}   请先运行: ./fast-hiker.sh --clean${NC}"
echo ""
echo "当前模式: 快速编译（使用预编译工具链）"
echo "清理命令: ./fast-hiker.sh --clean"
rm -f "${OPENWRT_DIR}/.config"
echo ""

# 运行 Docker 容器进行编译
echo -e "${GREEN}==> 启动快速编译...${NC}"
echo -e "${BLUE}镜像: ${DOCKER_IMAGE}${NC}"
echo -e "${BLUE}工作目录: ${OPENWRT_DIR}${NC}"
echo ""

docker run --rm \
    -v "${OPENWRT_DIR}:/openwrt" \
    -w /openwrt \
    -e FORCE_UNSAFE_CONFIGURE=1 \
    --name openwrt-hiker-fast-build \
    ${DOCKER_IMAGE} \
    bash -c '
        set -e
        
        echo "========================================="
        echo "OpenWrt 快速编译（预编译工具链）"
        echo "========================================="
        echo ""
        
        # 配置 Git 安全目录
        echo "==> 配置 Git..."
        git config --global --add safe.directory "*"
        echo "✓ Git 配置完成"
        echo ""
        
        # 加载配置
        echo "==> 加载配置文件..."
        CONFIG_FILE="hiker.config"
        if [ -f "$CONFIG_FILE" ]; then
            cp "$CONFIG_FILE" .config
            make defconfig
            echo "✓ 配置加载完成: $CONFIG_FILE"
        else
            echo "错误: $CONFIG_FILE 不存在"
            exit 1
        fi
        
        # 下载源码（如果需要）
        echo ""
        echo "==> 检查源码包..."
        make download -j$(nproc) 2>&1 | grep -v "Checking" || true
        
        # 快速编译（工具链已预编译）
        echo ""
        echo "==> 开始快速编译..."
        echo "线程数: $(nproc)"
        echo "预计时间: 5-10 分钟（工具链已预编译）"
        echo ""
        
        make -j$(nproc) V=s || make -j1 V=s
        
        echo ""
        echo "========================================="
        echo "✓ 编译完成！"
        echo "========================================="
        echo ""
        
        # 显示编译产物
        if [ -d "bin/targets/ramips/rt305x" ]; then
            echo "编译产物:"
            ls -lh bin/targets/ramips/rt305x/*.bin 2>/dev/null || echo "未找到固件文件"
        fi
    '

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}快速编译完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "查看编译产物:"
echo "  ls -lh bin/targets/ramips/rt305x/"
echo ""

