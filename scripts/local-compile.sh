#!/bin/bash
#
# Docker 编译脚本（使用自定义编译镜像）
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

OPENWRT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_IMAGE="openwrt-compile:latest"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Hiker Docker 编译脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    exit 1
fi

# 检查镜像是否存在
if ! docker image inspect ${DOCKER_IMAGE} &> /dev/null 2>&1; then
    echo -e "${YELLOW}Docker 镜像不存在，开始构建...${NC}"
    echo -e "${BLUE}镜像名称: ${DOCKER_IMAGE}${NC}"
    echo ""
    
    docker build -t ${DOCKER_IMAGE} .
    
    echo ""
    echo -e "${GREEN}✓ Docker 镜像构建完成${NC}"
    echo ""
fi

# 清理模式
if [ "$1" = "--clean" ]; then
    echo -e "${YELLOW}=======================================${NC}"
    echo -e "${YELLOW}  清理编译缓存${NC}"
    echo -e "${YELLOW}=======================================${NC}"
    echo ""
    echo -e "${YELLOW}将清理以下目录（需要 sudo 密码）:${NC}"
    echo "  • build_dir/target-mipsel_24kc_musl/"
    echo "  • staging_dir/target-mipsel_24kc_musl/"
    echo "  • tmp/"
    echo "  • .config"
    echo ""
    echo -e "${RED}警告: 这会删除所有编译缓存${NC}"
    echo -e "${YELLOW}请输入 sudo 密码：${NC}"
    
    # 交互式 sudo 清理
    sudo rm -rf "${OPENWRT_DIR}/build_dir/target-mipsel_24kc_musl" \
                "${OPENWRT_DIR}/staging_dir/target-mipsel_24kc_musl" \
                "${OPENWRT_DIR}/tmp" \
                "${OPENWRT_DIR}/.config"
    
    echo ""
    echo -e "${GREEN}✓ 清理完成${NC}"
    echo ""
    echo "下一步: 运行 ./local-hiker.sh 开始编译"
    echo ""
    exit 0
fi

# 编译模式
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  编译 Hiker 固件${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  注意: 如果配置变化较大（如添加/移除 WiFi），${NC}"
echo -e "${YELLOW}   请先运行: ./local-hiker.sh --clean${NC}"
echo ""
echo "当前模式: 增量编译（保留缓存）"
echo "清理命令: ./local-hiker.sh --clean"
# 只删除配置文件，保留编译缓存
rm -f "${OPENWRT_DIR}/.config"
echo ""

# 运行 Docker 容器进行编译
echo -e "${GREEN}==> 启动 Docker 容器编译...${NC}"
echo -e "${BLUE}工作目录: ${OPENWRT_DIR}${NC}"
echo ""

docker run --rm \
    -v "${OPENWRT_DIR}:/openwrt" \
    -w /openwrt \
    -e FORCE_UNSAFE_CONFIGURE=1 \
    --name openwrt-hiker-build \
    ${DOCKER_IMAGE} \
    bash -c '
        set -e
        
        echo "========================================="
        echo "OpenWrt 自动化编译流程"
        echo "========================================="
        echo ""
        
        # 配置 Git 安全目录（解决 Docker 权限问题）
        echo "==> 配置 Git 安全目录..."
        git config --global --add safe.directory /openwrt
        git config --global --add safe.directory /openwrt/feeds/packages
        git config --global --add safe.directory /openwrt/feeds/luci
        git config --global --add safe.directory /openwrt/feeds/routing
        git config --global --add safe.directory /openwrt/feeds/telephony
        git config --global --add safe.directory /openwrt/feeds/video
        git config --global --add safe.directory "*"
        echo "✓ Git 配置完成"
        echo ""
        
        # 1. 执行 DIY Part 1
        if [ -f "diy-part1.sh" ]; then
            echo "==> [1/7] 执行 DIY Part 1..."
            bash diy-part1.sh
        fi
        
        # 2. 更新 feeds
        echo "==> [2/7] 更新 feeds..."
        ./scripts/feeds update -a
        
        # 3. 安装 feeds
        echo "==> [3/7] 安装 feeds..."
        ./scripts/feeds install -a
        
        # 4. 执行 DIY Part 2
        if [ -f "diy-part2.sh" ]; then
            echo "==> [4/7] 执行 DIY Part 2..."
            bash diy-part2.sh
        fi
        
        # 5. 加载配置
        echo "==> [5/7] 加载配置文件..."
        CONFIG_FILE="hiker.config"
        if [ -f "$CONFIG_FILE" ]; then
            cp "$CONFIG_FILE" .config
            make defconfig
            echo "✓ 配置加载完成: $CONFIG_FILE"
            echo ""
            echo "目标配置:"
            grep "^CONFIG_TARGET" .config | head -5
        else
            echo "错误: $CONFIG_FILE 不存在"
            exit 1
        fi
        
        # 6. 下载源码
        echo ""
        echo "==> [6/7] 下载源码包..."
        make download -j$(nproc)
        
        # 7. 编译
        echo ""
        echo "==> [7/7] 开始编译..."
        echo "线程数: $(nproc)"
        echo "预计时间: 30-60 分钟"
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
            echo ""
            echo "固件位置: bin/targets/ramips/rt305x/"
        fi
    '

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}编译流程完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "查看编译产物:"
echo "  ls -lh bin/targets/ramips/rt305x/"
echo ""

