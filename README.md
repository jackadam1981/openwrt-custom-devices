# Custom Devices Feed for OpenWrt

OpenWrt feed for custom and legacy devices with optimized firmware profiles.

## 🎯 项目目标

- 支持多个自定义/老旧设备
- 每个设备提供多个优化配置
- 统一的构建和刷机工具
- 完整的文档和版本管理

## 📦 支持的设备

| 设备 | SoC | 内存 | 闪存 | 配置数 | 状态 |
|------|-----|------|------|--------|------|
| [Hiker RT5350](devices/hiker-rt5350/) | RT5350 | 32MB | 4MB | 4 | ✅ 稳定 |

更多设备持续添加中...

## 🚀 快速开始

### 1. 添加 Feed

```bash
cd /path/to/openwrt
echo "src-link custom $(pwd)/custom-devices" >> feeds.conf.default
./scripts/feeds update custom
./scripts/feeds install -a -p custom
```

### 2. 选择设备和配置

```bash
# Hiker RT5350 - P910ND 打印服务器（推荐）
cp feeds/custom/devices/hiker-rt5350/profiles/p910nd/defconfig .config
cp -r feeds/custom/devices/hiker-rt5350/profiles/p910nd/files files
make defconfig
```

### 3. 编译

**方法一：GitHub Actions（推荐）**
```bash
# 推送到 GitHub 后，Actions 会自动编译
git push

# 或手动触发: 
# GitHub → Actions → Build OpenWrt Firmware → Run workflow
```

**方法二：本地编译**
```bash
# 使用通用快速编译脚本
./feeds/custom/common/scripts/fast-compile.sh

# 或标准编译
make -j$(nproc)
```

### 4. 刷机

```bash
./feeds/custom/common/scripts/flash.sh <设备IP> \
  bin/targets/*/openwrt-*-sysupgrade.bin
```

## 📁 Feed 结构

```
custom-devices/
├── devices/              # 设备目录
│   └── hiker-rt5350/    # 设备名
│       ├── target/      # 硬件定义（DTS, image）
│       ├── profiles/    # 固件配置版本
│       │   ├── minimal/      # 配置1
│       │   │   ├── defconfig
│       │   │   └── files/
│       │   ├── p910nd/       # 配置2 ⭐
│       │   ├── wifi-client/  # 配置3
│       │   └── full-wifi/    # 配置4
│       ├── scripts/     # 设备专用脚本
│       ├── docs/        # 设备文档
│       └── README.md    # 设备说明
│
├── common/              # 通用资源
│   ├── scripts/        # 通用构建/刷机脚本
│   ├── configs/        # 可复用配置片段
│   └── patches/        # 通用补丁
│
├── openwrt-compat/     # OpenWrt 版本兼容性
│   ├── 23.05/
│   └── snapshot/
│
└── docs/               # 通用文档
```

## 🛠️ 设备开发

### 添加新设备

1. 创建设备目录：
```bash
mkdir -p custom-devices/devices/your-device/{target,profiles,scripts,docs}
```

2. 添加硬件定义（DTS + image Makefile）

3. 创建至少一个 profile：
```bash
mkdir custom-devices/devices/your-device/profiles/default
# 添加 defconfig 和 files/
```

4. 更新 DEVICES.md 列表

详见：[docs/adding-device.md](docs/adding-device.md)

### 添加新配置 Profile

```bash
cd custom-devices/devices/your-device/profiles
mkdir new-profile
cd new-profile
# 创建 defconfig（固件配置）
# 创建 files/（版本标识、覆盖文件）
```

详见：[docs/adding-profile.md](docs/adding-profile.md)

## 📚 文档

- [设备列表](DEVICES.md) - 所有支持的设备
- [集成指南](INTEGRATION.md) - 如何集成到 OpenWrt
- [GitHub Actions](docs/github-actions.md) - 自动化编译指南 ⭐
- [添加设备](docs/adding-device.md) - 添加新设备指南
- [添加配置](docs/adding-profile.md) - 添加新配置指南

### 设备专用文档

- [Hiker RT5350](devices/hiker-rt5350/README.md)

## 🔧 通用工具

### 构建脚本

```bash
# 快速编译（使用 Docker 预编译工具链）
./common/scripts/fast-compile.sh

# 完整编译
./common/scripts/local-compile.sh

# 批量编译多个配置
./devices/your-device/scripts/build-all.sh
```

### 刷机脚本

```bash
# 自动刷机（SSH + sysupgrade）
./common/scripts/flash.sh <设备IP> <固件路径>
```

### 发布脚本

```bash
# 创建发布包
./common/scripts/release.sh <版本> <固件路径>
```

## 🌟 特性

- ✅ **多设备支持**：统一管理多个设备
- ✅ **多配置版本**：每个设备可有多个优化配置
- ✅ **版本识别**：固件内置版本信息（hostname, banner, /etc/xxx-version）
- ✅ **自动化工具**：编译、刷机、发布全自动
- ✅ **Docker 支持**：快速编译，无需本地工具链
- ✅ **完整文档**：设备说明、集成指南、开发文档

## 🤝 贡献

欢迎提交：
- 新设备支持
- 优化配置
- Bug 修复
- 文档改进

提交 PR 前请阅读：[docs/contributing.md](docs/contributing.md)

## 📄 许可

GPLv2 - 与 OpenWrt 保持一致

## 🔗 相关链接

- [OpenWrt 官网](https://openwrt.org/)
- [OpenWrt Feeds](https://openwrt.org/docs/guide-developer/feeds)
- [设备开发指南](https://openwrt.org/docs/guide-developer/add_new_device)

---

**当前状态**: 活跃开发中 | **设备数**: 1 | **配置数**: 4
