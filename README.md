# Custom Devices Feed for OpenWrt

**标准 OpenWrt Feed**，支持自定义和传统设备，提供优化的固件配置和 GitHub Actions 自动编译。

## 🎯 项目特点

- ✅ **符合 OpenWrt Feed 标准**：可通过 feed 系统正常安装
- ✅ **多设备支持**：可扩展到更多设备
- ✅ **多配置版本**：每个设备提供多个优化配置
- ✅ **GitHub Actions CI/CD**：自动编译所有组合（4配置 × 2版本 = 8个固件）
- ✅ **完整文档**：使用指南、开发文档、CI/CD 说明

## 📦 支持的设备

| 设备 | SoC | 内存 | 闪存 | 配置数 | 状态 |
|------|-----|------|------|--------|------|
| **Hiker RT5350** | RT5350 | 32MB | 4MB | 4 | ✅ 稳定 |

详见：[DEVICES.md](DEVICES.md)

## 🚀 快速开始

### 方法一：作为 Feed 安装（推荐）

```bash
# 1. 在 OpenWrt 源码目录
cd /path/to/openwrt

# 2. 添加 custom feed
echo "src-git custom https://github.com/jackadam1981/openwrt-custom-devices.git" >> feeds.conf.default

# 3. 更新和安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 4. 选择配置（推荐 p910nd）
cp feeds/custom/configs/hiker-rt5350/p910nd.config .config
cp -r feeds/custom/files/hiker-rt5350/p910nd files
make defconfig

# 5. 编译
make -j$(nproc)
```

### 方法二：直接下载预编译固件（最简单）

访问 GitHub Actions Artifacts：
```
https://github.com/jackadam1981/openwrt-custom-devices/actions
→ 选择最新的成功构建
→ 下载对应的固件 Artifact
```

每次推送代码会自动编译 **8 个固件**：
- Hiker RT5350: minimal, p910nd, wifi-client, full-wifi
- OpenWrt: SNAPSHOT, 23.05
- 示例：`hiker-rt5350-23.05-p910nd.bin`

### 方法三：手动复制文件

```bash
# 1. 克隆本仓库
git clone https://github.com/jackadam1981/openwrt-custom-devices.git

# 2. 复制设备定义
cp custom-devices/target/linux/ramips/dts/* openwrt/target/linux/ramips/dts/
cat custom-devices/target/linux/ramips/image/hiker.mk >> openwrt/target/linux/ramips/image/rt305x.mk

# 3. 复制配置
cp custom-devices/configs/hiker-rt5350/p910nd.config openwrt/.config
cp -r custom-devices/files/hiker-rt5350/p910nd openwrt/files

# 4. 编译
cd openwrt
make defconfig && make -j$(nproc)
```

## 📁 Feed 结构

```
custom-devices/  (标准 OpenWrt Feed)
├── target/                    # Feed 核心（OpenWrt 标准）
│   └── linux/ramips/
│       ├── dts/              # 设备树文件
│       └── image/            # 设备定义
│
├── configs/                   # 配置文件集合（额外资源）
│   └── hiker-rt5350/
│       ├── minimal.config
│       ├── p910nd.config ⭐
│       ├── wifi-client.config
│       └── full-wifi.config
│
├── files/                     # 版本标识文件（额外资源）
│   └── hiker-rt5350/
│       ├── minimal/etc/
│       ├── p910nd/etc/
│       ├── wifi-client/etc/
│       └── full-wifi/etc/
│
├── scripts/                   # 构建工具（额外资源）
├── docs/                      # 文档（额外资源）
└── .github/workflows/         # CI/CD（额外资源）
```

**关键点**：
- `target/` 在根目录 → 符合 OpenWrt Feed 标准 ✅
- `configs/` 和 `files/` → 额外的配置资源，不影响 feed ✅
- Feed 系统只关注 `target/` 目录 ✅

## 🔧 Hiker RT5350 配置对比

| 配置 | 功能 | 23.05 大小 | SNAPSHOT 大小 | 适用场景 |
|------|------|-----------|--------------|----------|
| minimal | 基础系统 | 3.35 MB ✅ | 3.88 MB ✅ | 最小化、开发 |
| p910nd | USB 打印服务器 | 3.47 MB ✅ | 3.99 MB ✅ | **网络打印⭐** |
| wifi-client | 打印+WiFi客户端 | 4.35 MB ✅ | 5.03 MB ❌ | 无线打印 |
| full-wifi | 打印+完整WiFi | 4.29 MB ✅ | 4.94 MB ⚠️ | 完整功能 |

**闪存限制**（RT5350 = 4MB）：
- ✅ 23.05 所有配置都能装下
- ⚠️ SNAPSHOT wifi-client 超限（5.03 MB）
- ⚠️ SNAPSHOT full-wifi 接近上限（4.94 MB）

**推荐**：使用 **23.05-p910nd** (3.47 MB，稳定可靠)

## 🤖 GitHub Actions

本项目使用 GitHub Actions 自动编译：

### Workflows

1. **Build All Profiles (Auto)**
   - 触发：push/PR 自动
   - 编译：8 个固件（4配置 × 2OpenWrt版本）
   - 时间：~60 分钟（并行）

2. **Build Single Profile**
   - 触发：手动
   - 编译：选择单个配置和 OpenWrt 版本
   - 时间：~15 分钟

3. **Create Release**
   - 触发：推送 tag
   - 编译：所有配置（SNAPSHOT）
   - 自动创建 GitHub Release

详见：[docs/github-actions.md](docs/github-actions.md)

## 📚 文档

- [设备列表](DEVICES.md) - 支持的设备和配置对比
- [结构说明](STRUCTURE.md) - Feed 结构详解
- [Workflow 指南](WORKFLOW_GUIDE.md) - GitHub Actions 使用
- [GitHub Actions 详细](docs/github-actions.md) - CI/CD 完整指南
- [Hiker RT5350 版本历史](docs/devices/hiker-rt5350-versions.md)

## 🛠️ 开发

### 添加新设备

1. 添加设备定义：
```bash
# DTS
target/linux/ramips/dts/rtXXXX_vendor_model.dts

# Image definition
target/linux/ramips/image/vendor.mk
```

2. 添加配置：
```bash
configs/vendor-model/default.config
files/vendor-model/default/etc/...
```

3. 更新文档和 GitHub Actions matrix

### 本地测试

```bash
# 使用本项目的脚本
./scripts/fast-compile.sh    # 快速编译（Docker）
./scripts/local-compile.sh   # 完整编译
./scripts/flash.sh <IP> <firmware>  # 刷机
```

## 🌟 特性亮点

- 📦 **标准 Feed**：完全符合 OpenWrt feed 规范
- 🔧 **多配置**：一个设备，多个优化版本
- 🤖 **自动化**：GitHub Actions 自动编译和发布
- 🏷️ **版本识别**：hostname、banner、version 文件
- 📖 **文档完善**：中英文文档，详细的使用和开发指南
- 🚀 **开箱即用**：预编译固件直接下载使用

## 🤝 贡献

欢迎：
- 添加新设备支持
- 优化现有配置
- 改进文档
- 报告 Bug

## 📄 许可

GPLv2 - 与 OpenWrt 保持一致

## 🔗 相关链接

- [OpenWrt 官网](https://openwrt.org/)
- [OpenWrt Feeds](https://openwrt.org/docs/guide-developer/feeds)
- [本项目 GitHub Actions](https://github.com/jackadam1981/openwrt-custom-devices/actions)

---

**当前状态**: ✅ 生产就绪 | **设备数**: 1 | **配置数**: 4 | **自动编译**: 8 个固件
