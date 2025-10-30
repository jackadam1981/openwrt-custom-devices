# Hiker Feed 快速参考

## 📦 Feed 内容

```
hiker-feed/
├── target/linux/ramips/
│   ├── dts/rt5350_hiker_hiker.dts      # 设备树
│   └── image/hiker.mk                   # 设备定义
├── configs/
│   ├── v0.1.config                      # 基础版配置
│   ├── v0.2.config                      # 打印服务器（推荐⭐）
│   ├── v0.3.config                      # WiFi 客户端
│   └── v0.4.config                      # 完整 WiFi
├── files/
│   ├── v0.1/etc/{hiker-version,banner,config/system}
│   ├── v0.2/etc/{hiker-version,banner,config/system}
│   ├── v0.3/etc/{hiker-version,banner,config/system}
│   └── v0.4/etc/{hiker-version,banner,config/system}
├── scripts/
│   ├── fast-compile.sh                  # 快速编译
│   ├── local-compile.sh                 # 完整编译
│   ├── flash.sh                         # 刷机
│   └── release.sh                       # 发布
├── docs/                                # 文档
├── README.md                            # 主说明
├── INTEGRATION.md                       # 集成指南
├── VERSIONS.md                          # 版本详情
└── Makefile                             # Feed Makefile
```

## 🚀 5 分钟快速开始

### 1. 添加 Feed

```bash
cd /home/jack/openwrt
echo "src-link hiker $(pwd)/hiker-feed" >> feeds.conf.default
./scripts/feeds update hiker
./scripts/feeds install -a -p hiker
```

### 2. 选择配置（推荐 v0.2）

```bash
cp feeds/hiker/configs/v0.2.config .config
cp -r feeds/hiker/files/v0.2 files
make defconfig
```

### 3. 编译

```bash
# 方法一：快速编译（需要预编译镜像）
./feeds/hiker/scripts/fast-compile.sh

# 方法二：完整编译
make -j$(nproc)
```

### 4. 刷机

```bash
./feeds/hiker/scripts/flash.sh 192.168.1.1 \
  bin/targets/ramips/rt305x/openwrt-ramips-rt305x-hiker_hiker-squashfs-sysupgrade.bin
```

## 📋 常用命令

### Feed 管理

```bash
# 更新 feed
./scripts/feeds update hiker

# 安装 feed 所有包
./scripts/feeds install -a -p hiker

# 卸载 feed
./scripts/feeds uninstall -a -p hiker
```

### 版本切换

```bash
# 切换到 v0.3
cp feeds/hiker/configs/v0.3.config .config
rm -rf files && cp -r feeds/hiker/files/v0.3 files
make defconfig
make -j$(nproc)
```

### 批量编译所有版本

```bash
# 使用主仓库的批量脚本
cd /home/jack/openwrt
./build-all-versions.sh
```

## 🎯 版本选择指南

| 版本 | 何时使用 | 性能 |
|------|---------|------|
| v0.1 | 最小系统、二次开发 | ⚡ 最快 |
| v0.2 | USB 打印服务器 | ⭐ 推荐 |
| v0.3 | 需要 WiFi 客户端 | ⚠️ 较慢 |
| v0.4 | 完整功能测试 | ❌ 很慢 |

## 🔧 配置 menuconfig

```bash
make menuconfig

# 关键选项：
# Target System: MediaTek Ralink MIPS
# Subtarget: RT305x based boards
# Target Profile: Hiker Hiker
```

## 📁 文件位置

| 内容 | Feed 路径 | OpenWrt 路径 |
|------|-----------|-------------|
| 配置文件 | `configs/v0.X.config` | `.config` |
| 版本标识 | `files/v0.X/` | `files/` |
| DTS | `target/.../dts/*.dts` | `target/linux/ramips/dts/` |
| 设备定义 | `target/.../image/hiker.mk` | `target/linux/ramips/image/rt305x.mk` |

## 🐛 故障排查

### Feed 不显示

```bash
# 检查 feed 配置
cat feeds.conf.default | grep hiker

# 更新所有 feeds
./scripts/feeds update -a
./scripts/feeds install -a
```

### 设备不在 menuconfig 中

需要手动添加设备定义到 `target/linux/ramips/image/rt305x.mk`：

```bash
cat feeds/hiker/target/linux/ramips/image/hiker.mk >> \
  target/linux/ramips/image/rt305x.mk
```

### 编译失败

```bash
# 清理并重试
make clean
make -j1 V=s 2>&1 | tee build.log
```

## 📞 支持

- 文档：查看 `hiker-feed/docs/`
- 版本详情：`VERSIONS.md`
- 集成指南：`INTEGRATION.md`

## 🔗 相关链接

- [OpenWrt Wiki](https://openwrt.org/)
- [OpenWrt Feeds](https://openwrt.org/docs/guide-developer/feeds)
- [RT5350 datasheet](https://www.mediatek.com/products/home-networking/rt5350)

