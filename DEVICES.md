# 支持的设备列表

## 📱 设备总览

| 设备 | SoC | 架构 | 内存 | 闪存 | 配置数 | 推荐配置 | 状态 |
|------|-----|------|------|------|--------|----------|------|
| Hiker RT5350 | Ralink RT5350 | mipsel_24kc | 32MB | 4MB | 4 | p910nd | ✅ 稳定 |

## 设备详情

### 1. Hiker RT5350

**硬件规格**
- **SoC**: Ralink RT5350 (MIPS 24Kc @ 360MHz, 单核)
- **内存**: 32MB DDR2
- **闪存**: 4MB SPI NOR Flash
- **网络**: 1x WAN + 2x LAN (Fast Ethernet 10/100)
- **WiFi**: 802.11b/g/n 2.4GHz（性能受限，不推荐）
- **USB**: 1x USB 2.0
- **电源**: 5V DC

**支持的配置**

| 配置名 | 功能 | 固件大小 | CPU 空闲 | 内存使用 | 适用场景 |
|--------|------|----------|----------|----------|----------|
| [minimal](devices/hiker-rt5350/profiles/minimal/) | 基础系统 | ~4.5MB | 98% | ~18MB | 最小化、二次开发 |
| [p910nd](devices/hiker-rt5350/profiles/p910nd/) ⭐ | USB 打印服务器 | ~5.1MB | 98% | ~22MB | 网络打印共享（推荐） |
| [wifi-client](devices/hiker-rt5350/profiles/wifi-client/) | 打印+WiFi客户端 | ~5.1MB | 95% | ~23MB | 无线打印 |
| [full-wifi](devices/hiker-rt5350/profiles/full-wifi/) | 打印+完整WiFi | ~5.1MB | <5% | ~24MB | 完整功能（不推荐） |

**已知问题**
- ⚠️ RT5350 CPU 性能限制，WiFi 驱动会占用 90%+ CPU
- ⚠️ 32MB 内存有限，避免安装大型软件包
- ✅ 有线网络和 USB 功能稳定

**文档**
- [README](devices/hiker-rt5350/README.md) - 详细说明
- [VERSIONS](devices/hiker-rt5350/VERSIONS.md) - 版本历史
- [快速入门](devices/hiker-rt5350/docs/QUICKSTART.md)

**发布**
- 最新版本：查看 [GitHub Releases](../../releases)
- 刷机指南：[FLASH_UPGRADE_OPTIONS.md](devices/hiker-rt5350/docs/FLASH_UPGRADE_OPTIONS.md)

---

## 🚧 计划添加的设备

欢迎提交 PR 添加更多设备！

优先级列表：
- [ ] HLK-RM04 (RT5350)
- [ ] 其他 RT5350 设备
- [ ] RT3052 设备
- [ ] MT7620 设备

## 🔧 添加新设备

请参考：[docs/adding-device.md](docs/adding-device.md)

要求：
1. 提供完整的 DTS 文件
2. 至少一个可用的配置 profile
3. 完整的设备文档（README.md）
4. 测试通过的固件

## 📊 设备统计

- **总设备数**: 1
- **总配置数**: 4
- **支持架构**: mipsel_24kc
- **平均固件大小**: ~5MB
- **最小内存要求**: 32MB

---

最后更新：2025-10-30

