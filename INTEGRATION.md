# Hiker Feed 集成指南

本文档说明如何将 Hiker feed 集成到 OpenWrt 构建系统。

## 方法一：本地 Feed（开发推荐）

适用于本地开发和测试。

### 步骤

1. **将 feed 放在 OpenWrt 源码外部**（推荐）：

```bash
cd /home/jack
git clone https://github.com/yourusername/hiker-feed.git
cd openwrt
echo "src-link hiker /home/jack/hiker-feed" >> feeds.conf.default
```

2. **或放在 OpenWrt 源码内部**：

```bash
cd /home/jack/openwrt
# hiker-feed 已经在这里
echo "src-link hiker $(pwd)/hiker-feed" >> feeds.conf.default
```

3. **更新和安装**：

```bash
./scripts/feeds update hiker
./scripts/feeds install -a -p hiker
```

4. **使用配置**：

```bash
# 复制配置文件（推荐 v0.2）
cp feeds/hiker/configs/v0.2.config .config
make defconfig

# 复制版本标识文件
rm -rf files
cp -r feeds/hiker/files/v0.2 files
```

5. **编译**：

```bash
make -j$(nproc)
```

## 方法二：Git Feed（生产推荐）

适用于分发和持续集成。

### 前提条件

将 hiker-feed 发布到 Git 仓库：

```bash
cd hiker-feed
git init
git add .
git commit -m "Initial commit: Hiker RT5350 feed"
git remote add origin https://github.com/yourusername/hiker-feed.git
git push -u origin main
```

### 使用步骤

1. **添加 feed**：

```bash
cd /home/jack/openwrt
echo "src-git hiker https://github.com/yourusername/hiker-feed.git" >> feeds.conf.default
```

2. **更新和安装**：

```bash
./scripts/feeds update hiker
./scripts/feeds install -a -p hiker
```

3. **配置和编译**（同方法一）

## 集成到 OpenWrt 主源码

如果你想将 Hiker 设备支持合并到 OpenWrt 主线，需要：

### 1. 复制 DTS 文件

```bash
cp hiker-feed/target/linux/ramips/dts/rt5350_hiker_hiker.dts \
   target/linux/ramips/dts/
```

### 2. 添加设备定义

编辑 `target/linux/ramips/image/rt305x.mk`，在 RT5350 设备部分添加：

```makefile
define Device/hiker_hiker
  SOC := rt5350
  IMAGE_SIZE := 7872k
  DEVICE_VENDOR := Hiker
  DEVICE_MODEL := Hiker
  SUPPORTED_DEVICES := HIKER
endef
TARGET_DEVICES += hiker_hiker
```

### 3. 提交到 OpenWrt

按照 [OpenWrt 贡献指南](https://openwrt.org/submitting-patches) 提交补丁。

## 使用 Feed 中的脚本

Feed 提供了编译和刷机脚本：

```bash
# 快速编译（使用预编译镜像）
./feeds/hiker/scripts/fast-compile.sh

# 完整编译
./feeds/hiker/scripts/local-compile.sh

# 刷机
./feeds/hiker/scripts/flash.sh 192.168.1.1 bin/targets/ramips/rt305x/*-sysupgrade.bin
```

## Docker 集成

### 构建预编译镜像

当前 feed 假设你已经有一个预编译的 Docker 镜像 `openwrt-mipsel:prebuilt`。

如果没有，使用主仓库的 `Dockerfile.mipsel` 构建：

```bash
cd /home/jack/openwrt
docker build -f Dockerfile.mipsel -t openwrt-mipsel:prebuilt .
```

### 一键构建脚本

使用主仓库的 `build-and-compile.sh` 来构建镜像并编译所有版本：

```bash
cd /home/jack/openwrt
./build-and-compile.sh
```

## 目录结构说明

集成后，你的 OpenWrt 源码目录结构：

```
openwrt/
├── feeds.conf.default         # 包含 hiker feed
├── feeds/
│   └── hiker/                 # Feed 内容（自动生成）
│       ├── target/
│       ├── configs/
│       ├── files/
│       └── ...
├── target/linux/ramips/       # OpenWrt 主线
│   ├── dts/
│   │   └── rt5350_hiker_hiker.dts  # 通过 feed 安装
│   └── image/
│       └── rt305x.mk          # 需要手动添加设备定义
├── files/                     # 当前编译的版本标识
└── .config                    # 当前编译的配置
```

## 常见问题

### Q: Feed 更新后如何同步？

```bash
./scripts/feeds update hiker
./scripts/feeds install -a -p hiker
```

### Q: 如何切换版本？

```bash
# 切换到 v0.3
cp feeds/hiker/configs/v0.3.config .config
rm -rf files
cp -r feeds/hiker/files/v0.3 files
make defconfig
make -j$(nproc)
```

### Q: Feed 中的设备定义不生效？

需要手动将 `feeds/hiker/target/linux/ramips/image/hiker.mk` 的内容添加到 `target/linux/ramips/image/rt305x.mk`。

或者创建一个链接：

```bash
# 警告：这会修改 OpenWrt 主源码
grep -q "hiker_hiker" target/linux/ramips/image/rt305x.mk || \
  cat feeds/hiker/target/linux/ramips/image/hiker.mk >> target/linux/ramips/image/rt305x.mk
```

## 推荐工作流

1. **首次设置**：
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

2. **选择版本**（推荐 v0.2）：
   ```bash
   cp feeds/hiker/configs/v0.2.config .config
   cp -r feeds/hiker/files/v0.2 files
   make defconfig
   ```

3. **编译**：
   ```bash
   make -j$(nproc)  # 或使用 feeds/hiker/scripts/fast-compile.sh
   ```

4. **测试**：
   ```bash
   feeds/hiker/scripts/flash.sh 192.168.1.1 bin/targets/ramips/rt305x/*-sysupgrade.bin
   ```

5. **验证**：
   ```bash
   ssh root@192.168.1.1
   cat /etc/hiker-version
   ```

