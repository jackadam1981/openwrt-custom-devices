# Custom Devices Feed - 标准结构

本仓库现已调整为**符合 OpenWrt Feed 标准**的结构。

## 📁 目录结构

```
custom-devices/  (标准 OpenWrt Feed)
├── target/                         # ← Feed 核心（设备定义）
│   └── linux/
│       └── ramips/
│           ├── dts/
│           │   └── rt5350_hiker_hiker.dts
│           └── image/
│               └── hiker.mk
│
├── configs/                        # ← 配置文件集合（非 feed 部分）
│   └── hiker-rt5350/
│       ├── minimal.config
│       ├── p910nd.config
│       ├── wifi-client.config
│       └── full-wifi.config
│
├── files/                          # ← 版本标识文件（非 feed 部分）
│   └── hiker-rt5350/
│       ├── minimal/etc/
│       ├── p910nd/etc/
│       ├── wifi-client/etc/
│       └── full-wifi/etc/
│
├── scripts/                        # ← 构建工具（非 feed 部分）
│   ├── fast-compile.sh
│   ├── local-compile.sh
│   ├── flash.sh
│   └── release.sh
│
├── docs/                           # ← 文档（非 feed 部分）
│   ├── devices/
│   └── github-actions.md
│
├── .github/workflows/              # ← CI/CD（非 feed 部分）
│   ├── build-firmware.yml
│   ├── build-single.yml
│   └── release.yml
│
├── README.md
├── DEVICES.md
└── Makefile                        # Feed 必需文件
```

## 🎯 双重用途

### 1. 作为标准 OpenWrt Feed

```bash
# 在 OpenWrt 源码目录
echo "src-git custom https://github.com/jackadam1981/openwrt-custom-devices.git" >> feeds.conf.default
./scripts/feeds update custom
./scripts/feeds install -a -p custom

# Feed 会安装：
# - target/linux/ramips/dts/rt5350_hiker_hiker.dts
# - 设备定义（添加到 image/rt305x.mk）

# 然后手动选择配置：
cp feeds/custom/configs/hiker-rt5350/p910nd.config .config
cp -r feeds/custom/files/hiker-rt5350/p910nd files
make defconfig && make -j$(nproc)
```

### 2. 直接使用（无需 Feed 系统）

```bash
# 克隆仓库
git clone https://github.com/jackadam1981/openwrt-custom-devices.git

# 手动复制文件
cp custom-devices/target/linux/ramips/dts/* openwrt/target/linux/ramips/dts/
cat custom-devices/target/linux/ramips/image/hiker.mk >> openwrt/target/linux/ramips/image/rt305x.mk

# 使用配置
cp custom-devices/configs/hiker-rt5350/p910nd.config openwrt/.config
cp -r custom-devices/files/hiker-rt5350/p910nd openwrt/files
cd openwrt && make defconfig && make -j$(nproc)
```

### 3. GitHub Actions（自动编译）

推送代码自动触发，无需任何配置！

## 📊 Feed 部分 vs 非 Feed 部分

| 目录 | 是否 Feed | 用途 |
|------|-----------|------|
| `target/` | ✅ Feed 核心 | 设备定义（DTS + image） |
| `configs/` | ❌ 额外资源 | 固件配置文件集合 |
| `files/` | ❌ 额外资源 | 版本标识文件 |
| `scripts/` | ❌ 额外资源 | 构建和刷机脚本 |
| `docs/` | ❌ 额外资源 | 文档 |
| `.github/` | ❌ 额外资源 | CI/CD workflows |

**关键点**：
- `target/` 在根目录 → 符合 Feed 标准 ✅
- 其他目录不影响 Feed 功能 ✅
- Feed 系统只关心 `target/` 和 `package/` ✅

## 🚀 优势

1. **符合标准**：可以被 OpenWrt feed 系统正确识别
2. **多配置支持**：configs/ 和 files/ 提供多个版本
3. **灵活使用**：可以作为 feed 或直接复制文件
4. **易于扩展**：添加新设备只需在相应目录添加文件
5. **GitHub Actions**：自动编译所有组合

## 📝 未来扩展

添加新设备：
```bash
# 添加设备定义
custom-devices/target/linux/ramips/dts/rt3052_newdevice.dts
custom-devices/target/linux/ramips/image/newdevice.mk

# 添加配置
custom-devices/configs/newdevice/default.config
custom-devices/files/newdevice/default/...
```

---

**结构调整完成！** 现在既是标准 Feed，又支持多配置管理。
