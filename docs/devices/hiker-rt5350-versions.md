# Hiker RT5350 固件版本说明

## 设计理念

**相同硬件，不同软件配置**

本项目为 Hiker RT5350 硬件设计 **4 个独立的软件型号**，每个型号针对不同的应用场景。所有型号共享相同的硬件基础：
- **硬件平台**: Ralink RT5350 (MIPS @ 360MHz, 32MB RAM)
- **基础功能**: LuCI Web界面、SSH、LED控制、opkg、mtd
- **架构**: ramips/rt305x

## 软件型号概览

```
Hiker Minimal (hiker_hiker-minimal)
  │ 基础系统 + LuCI中文
  │
  ├─ Hiker Print (hiker_hiker-p910nd) ⭐推荐
  │    + USB打印服务器 + P910ND
  │
  ├─ Hiker WifiClient (hiker_hiker-wifi-client) ⚠️性能差
  │    + WiFi客户端
  │
  └─ Hiker WifiFull (hiker_hiker-full-wifi) ⚠️性能差
       + WiFi AP
```

## 技术实现

### 设备定义架构

每个型号都有完整独立的设备定义：

| 型号 | DTS文件 | 设备ID | DEVICE_MODEL | 兼容性 |
|------|---------|--------|--------------|--------|
| Minimal | `rt5350_hiker_hiker-minimal.dts` | `hiker_hiker-minimal` | Hiker Minimal | `hiker,hiker-minimal` |
| Print | `rt5350_hiker_hiker-p910nd.dts` | `hiker_hiker-p910nd` | Hiker Print | `hiker,hiker-print` |
| WifiClient | `rt5350_hiker_hiker-wifi-client.dts` | `hiker_hiker-wifi-client` | Hiker WifiClient | `hiker,hiker-wificlient` |
| WifiFull | `rt5350_hiker_hiker-full-wifi.dts` | `hiker_hiker-full-wifi` | Hiker WifiFull | `hiker,hiker-wififull` |

### 配置文件组织

```
configs/hiker-rt5350/
├── minimal.config        # Minimal型号配置
├── p910nd.config         # Print型号配置
├── wifi-client.config    # WifiClient型号配置
└── full-wifi.config      # WifiFull型号配置
```

### 设备树（DTS）文件

```
hiker-target/files/
├── rt5350_hiker_hiker-minimal.dts
├── rt5350_hiker_hiker-p910nd.dts
├── rt5350_hiker_hiker-wifi-client.dts
└── rt5350_hiker_hiker-full-wifi.dts
```

所有DTS文件共享相同的硬件配置：
- 相同的GPIO定义
- 相同的LED配置
- 相同的分区布局
- 相同的USB支持
- 唯一的差异：`model` 和 `compatible` 字符串

### 设备Makefile定义

在 `hiker-target/files/hiker.mk` 中定义：

```makefile
# 通用配置
define Device/hiker_hiker-common
  SOC := rt5350
  IMAGE_SIZE := 7872k
  DEVICE_VENDOR := Hiker
  SUPPORTED_DEVICES := HIKER
endef

# 各型号定义
define Device/hiker_hiker-minimal
  $(call Device/hiker_hiker-common)
  DEVICE_MODEL := Hiker Minimal
  DEVICE_PACKAGES := luci-light luci-theme-bootstrap luci-i18n-base-zh-cn
endef
TARGET_DEVICES += hiker_hiker-minimal

# ... 其他型号 ...
```

## 完整对比表

### 功能对比

| 功能特性 | Minimal | Print ⭐ | WifiClient ⚠️ | WifiFull ⚠️ |
|---------|---------|---------|---------------|-------------|
| **设备标识** | | | | |
| 型号 (model) | Hiker Minimal | Hiker Print | Hiker WifiClient | Hiker WifiFull |
| 设备ID | hiker_hiker-minimal | hiker_hiker-p910nd | hiker_hiker-wifi-client | hiker_hiker-full-wifi |
| DTS文件 | minimal.dts | p910nd.dts | wifi-client.dts | full-wifi.dts |
| **基础系统** | | | | |
| LuCI 中文界面 | ✅ | ✅ | ✅ | ✅ |
| SSH (Dropbear) | ✅ | ✅ | ✅ | ✅ |
| LED 控制（红+蓝） | ✅ | ✅ | ✅ | ✅ |
| DHCP 客户端 | ✅ | ✅ | ✅ | ✅ |
| Web固件升级 | ✅ | ✅ | ✅ | ✅ |
| opkg 包管理器 | ✅ | ✅ | ✅ | ✅ |
| mtd 工具 | ✅ | ✅ | ✅ | ✅ |
| **打印功能** | | | | |
| USB 驱动 | ❌ | ✅ | ✅ | ✅ |
| P910ND 服务器 | ❌ | ✅ | ✅ | ✅ |
| LuCI P910ND 界面 | ❌ | ✅ | ✅ | ✅ |
| **网络功能** | | | | |
| WiFi 客户端 | ❌ | ❌ | ✅ | ✅ |
| wpad-basic (WPA客户端认证) | ❌ | ❌ | ✅ | ✅ |
| WiFi AP | ❌ | ❌ | ❌ | ✅ |
| hostapd (AP认证) | ❌ | ❌ | ❌ | ✅ |

> **注意**: WiFi客户端需要 `wpad` 连接到加密的网络；WiFi AP需要 `hostapd` 提供加密的网络。因此 full-wifi 同时包含两者。

### 性能对比

| 指标 | Minimal | Print ⭐ | WifiClient ⚠️ | WifiFull ⚠️ |
|------|---------|---------|---------------|-------------|
| **软件包数** | ~18 | ~25 | ~32 | ~33 |
| **固件大小** | ~3.5 MB | ~4.0 MB | ~5.0 MB | ~5.2 MB |
| **CPU idle** | 98% | 98% | 0% | 0% |
| **CPU sys** | 1% | 1% | 90-97% | 90-97% |
| **内存占用** | ~14 MB | ~22 MB | ~24 MB | ~24 MB |
| **启动时间** | 快 | 快 | 慢 | 慢 |
| **系统负载** | <1.0 | <1.0 | >5.0 | >5.0 |
| **响应速度** | 流畅 ✅ | 流畅 ✅ | 卡顿 ❌ | 卡顿 ❌ |
| **推荐度** | ⭐⭐ | ⭐⭐⭐ | ❌ | ❌ |

---

## Hiker Minimal - 基础型号

**最轻量的 LuCI 中文固件**

### 设备信息
- **型号**: Hiker Minimal
- **设备ID**: `hiker_hiker-minimal`
- **DTS文件**: `rt5350_hiker_hiker-minimal.dts`
- **配置文件**: `configs/hiker-rt5350/minimal.config`

### 功能特点
- ✅ **完整Web界面**: LuCI中文 + Bootstrap主题
- ✅ **网络管理**: DHCP客户端、IPv4/IPv6支持
- ✅ **管理工具**: SSH (Dropbear)、Web固件升级、opkg、mtd
- ✅ **硬件支持**: LED控制（红+蓝）、GPIO导出
- ❌ **打印功能**: 不包含USB和P910ND
- ❌ **无线功能**: 不包含WiFi
- ❌ **网络服务**: 不包含防火墙、DHCP/DNS服务器

### 性能指标
- **固件大小**: ~3.5 MB
- **CPU idle**: 98%
- **内存占用**: ~14 MB
- **软件包数**: ~18 个（含 mtd、opkg）
- **启动时间**: 快速

### 性能测试结果
```
CPU:   0% usr   1% sys   0% nic  98% idle
Load average: 0.71 0.42 0.17  (OpenWrt 23.05-SNAPSHOT)
Mem: 14400K used, 17800K free
```

### 适用场景
- 基础路由/网关管理
- 纯管理设备
- 追求最小体积和功耗
- 二次开发基础

### 编译方法
```bash
# 配置文件
configs/hiker-rt5350/minimal.config

# 编译
./scripts/local-compile.sh
# 或使用GitHub Actions自动编译
```

---

## Hiker Print - 打印服务器型号 ⭐推荐

**Minimal + USB打印服务器**

### 设备信息
- **型号**: Hiker Print
- **设备ID**: `hiker_hiker-p910nd`
- **DTS文件**: `rt5350_hiker_hiker-p910nd.dts`
- **配置文件**: `configs/hiker-rt5350/p910nd.config`

### 功能特点
- ✅ **Minimal所有功能**
- ✅ **USB打印支持**: USB 2.0 + USB 1.1 (OHCI/EHCI)
- ✅ **P910ND服务器**: 网络打印服务器 + LuCI中文管理界面
- ✅ **Web配置**: 完整的打印服务器Web配置界面

### 新增软件包（相比Minimal）
- `kmod-usb-core` - USB 核心
- `kmod-usb-ohci` - USB 1.1
- `kmod-usb2` - USB 2.0
- `kmod-usb-printer` - USB 打印机驱动
- `p910nd` - P910ND打印服务器
- `luci-app-p910nd` - LuCI P910ND界面
- `luci-i18n-p910nd-zh-cn` - 中文语言包

### 性能指标
- **固件大小**: ~4.0 MB
- **CPU idle**: 98% ✅
- **内存占用**: ~22 MB
- **软件包数**: ~25 个（Minimal + USB + P910ND）
- **启动时间**: 快速（~30-40秒）

### 性能测试结果
```
CPU:   0% usr   1% sys   0% nic  98% idle
Load average: 0.74
Mem: 22440K used, 3940K free, 5512K cached
```

### 适用场景
- ⭐ **网络打印服务器**（主要用途）
- ⭐ 有线连接路由器
- ⭐ USB 打印机共享
- ⭐ 需要 Web 界面管理

### 编译方法
```bash
# 配置文件
configs/hiker-rt5350/p910nd.config

# 编译
./scripts/local-compile.sh
```

---

## Hiker WifiClient - WiFi客户端型号 ⚠️

**Minimal + WiFi客户端 + P910ND**

### 设备信息
- **型号**: Hiker WifiClient
- **设备ID**: `hiker_hiker-wifi-client`
- **DTS文件**: `rt5350_hiker_hiker-wifi-client.dts`
- **配置文件**: `configs/hiker-rt5350/wifi-client.config`

### 功能特点
- ✅ **Minimal所有功能**
- ✅ **USB打印**: USB + P910ND打印服务器（与Print相同）
- ✅ **WiFi客户端**: WPA2/WPA3支持、无线配置工具
- ✅ **无线工具**: iw、iwinfo
- ❌ **WiFi AP**: 不包含AP功能（仅客户端）

### 新增软件包（相比Print）
- `kmod-mac80211` - WiFi 协议栈
- `kmod-rt2800-lib` - RT2800 驱动库
- `kmod-rt2800-mmio` - MMIO 支持
- `kmod-rt2800-soc` - RT5350 专用驱动
- `kmod-rt2x00-lib` - RT2x00 通用库
- `kmod-rt2x00-mmio` - MMIO 通用
- `wpad-basic-mbedtls` - WPA/WPA2 认证
- `iw` - WiFi 配置工具
- `iwinfo` - WiFi 信息工具

### 性能指标
- **固件大小**: ~5.0 MB
- **CPU idle**: 0% ❌
- **CPU sys**: 90-97% ⚠️
- **内存占用**: ~24 MB
- **软件包数**: ~32 个（Print + WiFi客户端）
- **启动时间**: 慢（~60-90秒）

### 性能测试结果 ⚠️
```
CPU:  10% usr  89% sys   0% nic   0% idle
Load average: 6.48 5.03 3.37
Mem: 24704K used, 1676K free
```

### 已知问题
- ❌ **WiFi 驱动占用 100% CPU**
- ❌ 系统严重卡顿
- ❌ SSH 响应慢或超时
- ❌ Web 界面几乎无法使用
- ❌ 启动时间长

### 问题原因
可能是 OpenWrt 6.12 内核的 rt2800 驱动性能回归问题。

### 适用场景
- ⚠️ **不推荐日常使用**
- 仅供实验/测试
- 建议使用 Print + 外置路由器 WiFi

### 编译方法
```bash
# 配置文件
configs/hiker-rt5350/wifi-client.config

# 编译
./scripts/local-compile.sh
```

---

## Hiker WifiFull - 完整WiFi型号 ⚠️

**Minimal + WiFi客户端 + WiFi AP**

### 设备信息
- **型号**: Hiker WifiFull
- **设备ID**: `hiker_hiker-full-wifi`
- **DTS文件**: `rt5350_hiker_hiker-full-wifi.dts`
- **配置文件**: `configs/hiker-rt5350/full-wifi.config`

### 功能特点
- ✅ **Minimal所有功能**
- ✅ **USB打印**: USB + P910ND打印服务器（与Print相同）
- ✅ **WiFi客户端**: WPA2/WPA3支持、无线配置工具
- ✅ **WiFi AP**: 完整的WiFi接入点功能（hostapd）
- ✅ **最完整功能**: 所有功能集合

### 新增软件包（相比WifiClient）
- `hostapd` - WiFi AP完整支持

### 性能指标
- **固件大小**: ~5.0 MB
- **CPU idle**: 0% ❌
- **CPU sys**: 90-97% ⚠️
- **内存占用**: ~24 MB
- **软件包数**: ~33 个
- **启动时间**: 慢

### 性能测试结果 ⚠️
```
CPU:   2% usr  97% sys   0% nic   0% idle
Load average: 5.82 6.78 4.60
Mem: 22864K used, 3516K free
```

### 已知问题
- ❌ **WiFi驱动占用100% CPU**
- ❌ 系统严重卡顿
- ❌ SSH响应慢或超时
- ❌ Web界面几乎无法使用

### 问题原因
可能是 OpenWrt 5.15/6.12 内核的 rt2800 驱动性能回归问题。

### 适用场景
- ❌ **不推荐日常使用**
- 仅供测试完整功能
- RT5350 硬件无法胜任WiFi并发

### 编译方法
```bash
# 配置文件
configs/hiker-rt5350/full-wifi.config

# 编译
./scripts/local-compile.sh
```

---

## 型号选择建议

### 🎯 推荐使用

1. **大多数用户**: 使用 **Hiker Print** ⭐
   - 完整的打印服务器功能
   - 性能完美（CPU 98% idle）
   - 稳定可靠

2. **追求极致精简**: 使用 **Hiker Minimal**
   - 最小固件体积
   - 可通过 opkg 按需安装软件

3. **需要 WiFi**: ⚠️ **不推荐WiFi型号**
   - RT5350 + WiFi = 性能灾难
   - 建议：使用 **Hiker Print** + 外置路由器提供 WiFi

### 📊 快速对比

| 使用场景 | 推荐型号 | 性能 | 推荐度 |
|----------|----------|------|--------|
| 网络打印服务器 | **Hiker Print** | CPU 98% idle | ⭐⭐⭐ |
| 基础管理设备 | Hiker Minimal | CPU 98% idle | ⭐⭐ |
| WiFi客户端 | Hiker WifiClient | CPU 100% | ❌ |
| WiFi AP | Hiker WifiFull | CPU 100% | ❌ |

---

## 编译说明

本项目支持多种编译方式：

### 1. GitHub Actions 自动编译（推荐）⭐

推送代码到 `main` 分支会自动触发编译所有4个型号，无需本地环境。

### 2. 本地编译

```bash
# 使用提供的编译脚本
./scripts/local-compile.sh

# 或手动编译
cd openwrt
# 配置环境、复制config、编译...
```

### 3. Feed 集成编译

```bash
# 在OpenWrt源码目录
echo "src-link custom $PATH_TO_CUSTOM_DEVICES" >> feeds.conf.default
./scripts/feeds update custom
./scripts/feeds install -a -p custom
make menuconfig  # 选择 Hiker 型号
make -j$(nproc)
```

### 编译输出

每个型号生成独立的固件文件：
- `openwrt-ramips-rt305x-hiker_hiker-minimal-squashfs-sysupgrade.bin`
- `openwrt-ramips-rt305x-hiker_hiker-p910nd-squashfs-sysupgrade.bin`
- `openwrt-ramips-rt305x-hiker_hiker-wifi-client-squashfs-sysupgrade.bin`
- `openwrt-ramips-rt305x-hiker_hiker-full-wifi-squashfs-sysupgrade.bin`

---

## 刷机升级

### Web界面刷机（推荐）⭐

所有型号都支持通过LuCI Web界面刷机：
1. 登录 `http://192.168.1.1`
2. 导航：**系统 → 备份/刷写**
3. 选择固件文件并上传
4. 点击"刷写固件"

### SSH刷机

```bash
# 使用提供的刷机脚本
./scripts/flash.sh <设备IP> <固件文件>

# 或手动操作
scp openwrt-*.bin root@192.168.1.1:/tmp/
ssh root@192.168.1.1 "sysupgrade -v /tmp/openwrt-*.bin"
```

### 型号间升级

由于所有型号共享相同硬件，可以在型号间自由升级：
- Minimal ↔ Print ↔ WifiClient ↔ WifiFull
- 所有升级都直接支持，无需特殊参数

---

## RT5350 硬件评估

### ✅ 适合的应用
- 有线网络设备
- USB打印服务器 ⭐（最佳用途）
- 轻量路由/网关管理
- 基础网络服务

### ❌ 不适合的应用
- WiFi 功能（驱动性能严重问题）
- 高并发网络服务
- 多媒体应用
- WiFi + 其他服务并发

### 💡 最佳实践

**推荐配置**: Hiker Print（打印服务器型号）⭐⭐⭐
- 性能完美（CPU 98% idle）
- 功能完整稳定
- 完美适配RT5350硬件能力

---

## 项目文件结构

### 设备定义
- `hiker-target/files/rt5350_hiker_hiker-minimal.dts` - Minimal DTS
- `hiker-target/files/rt5350_hiker_hiker-p910nd.dts` - Print DTS
- `hiker-target/files/rt5350_hiker_hiker-wifi-client.dts` - WifiClient DTS
- `hiker-target/files/rt5350_hiker_hiker-full-wifi.dts` - WifiFull DTS
- `hiker-target/files/hiker.mk` - 设备定义文件

### 配置文件
- `configs/hiker-rt5350/minimal.config` - Minimal配置
- `configs/hiker-rt5350/p910nd.config` - Print配置 ⭐
- `configs/hiker-rt5350/wifi-client.config` - WifiClient配置
- `configs/hiker-rt5350/full-wifi.config` - WifiFull配置

### 工具脚本
- `scripts/collect-performance.sh` - 性能收集脚本
- `scripts/flash.sh` - 刷机脚本
- `scripts/local-compile.sh` - 本地编译脚本

### 文档
- `README.md` - 项目总览
- `DEVICES.md` - 设备列表
- `docs/devices/hiker-rt5350-versions.md` - 本文档

---

最后更新：2025-10-31

