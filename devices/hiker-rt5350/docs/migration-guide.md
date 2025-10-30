# OpenWrt 15 到最新版本迁移指南

本文档指导如何将运行 OpenWrt 15 的设备迁移到最新版本的 OpenWrt。

## 第一步：收集设备信息

首先需要从运行 OpenWrt 15 的设备上收集关键信息。

### 1.1 收集设备硬件信息

在 OpenWrt 15 设备上执行以下命令：

```bash
# 获取芯片型号和架构
cat /proc/cpuinfo
cat /sys/class/mtd/mtd0/size  # 获取 Flash 大小
cat /proc/partitions

# 获取内存信息
cat /proc/meminfo | grep MemTotal

# 获取网络接口
ip link show

# 获取设备树信息（如果支持）
cat /proc/device-tree/model 2>/dev/null || echo "Device tree not available"
```

### 1.2 收集 OpenWrt 配置信息

```bash
# 获取 OpenWrt 版本信息
cat /etc/openwrt_release
cat /etc/config/system  # 系统配置
cat /etc/config/network # 网络配置
cat /etc/config/wireless # 无线配置

# 列出已安装的包
opkg list-installed > /tmp/installed_packages.txt

# 导出 UCI 配置
for config in $(uci show | grep "^[a-z]" | cut -d. -f1 | sort -u); do
    uci export $config
done > /tmp/uci_config.txt
```

### 1.3 收集内核信息

```bash
uname -a
cat /proc/version
cat /proc/config.gz | gunzip > /tmp/kernel_config.txt 2>/dev/null || echo "No config available"
```

### 1.4 收集网络芯片信息

```bash
lspci | grep -i network 2>/dev/null || echo "No PCI network devices"
lsusb | grep -i network 2>/dev/null || echo "No USB network devices"
dmesg | grep -i -E "eth|wifi|wireless|radio|chip" | head -100
```

## 第二步：识别设备的目标平台

根据收集的信息，在最新的 OpenWrt 仓库中查找对应的目标平台。

### 2.1 常见平台映射

OpenWrt 15 (Chaos Calmer) 到最新版本的主要平台迁移：

| OpenWrt 15 平台 | 最新版本平台 | 说明 |
|----------------|------------|------|
| ramips | ramips | 保留 |
| ar71xx | ath79 | 大部分设备迁移到 ath79 |
| brcm47xx | bcm47xx/bcm27xx | 保留或细分 |
| x86 | x86 | 保留 |
| brcm63xx | 已废弃 | 需要迁移到其他平台 |

### 2.2 查看当前支持的目标

运行以下命令查看当前版本支持的所有目标：

```bash
ls target/linux/
```

## 第三步：查找设备 DTS 文件

### 3.1 通过设备型号查找

根据设备的品牌和型号，在对应的平台目录下查找 DTS 文件：

```bash
# 例如，如果设备是 ramips 平台
find target/linux/ramips/dts/ -name "*your-device*"

# 如果是 ath79 平台
find target/linux/ath79/dts/ -name "*your-device*"
```

### 3.2 匹配设备信息

使用收集的硬件信息来匹配：
- 芯片型号（如 MT7628, AR9344 等）
- 内存大小
- Flash 大小
- 网络接口配置

## 第四步：创建新设备支持

如果设备不在最新版本中，需要为其创建支持。

### 4.1 创建 DTS 文件

参考同一平台上类似设备的 DTS 文件，创建新设备的 DTS。

```bash
# 定位到目标平台目录，例如 ramips
cd target/linux/ramips/dts/

# 复制最相似的设备的 DTS
# 根据实际情况修改
```

### 4.2 创建 Makefile 支持

编辑平台的设备 Makefile，例如 `target/linux/ramips/image/mt76x8.mk`：

```makefile
define Device/your-device
  SOC := mt76x8
  DEVICE_VENDOR := YourVendor
  DEVICE_MODEL := YourModel
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += your-device
```

### 4.3 添加网络配置

在 `target/linux/ramips/base-files/etc/board.d/02_network` 中添加设备的网络配置。

## 第五步：配置编译

### 5.1 配置目标

```bash
# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 开始配置
make menuconfig
```

在 menuconfig 中：
1. 选择 Target System（如 MediaTek Ralink MIPS）
2. 选择 Subtarget（如 MT76x8）
3. 选择 Profile（选择你的设备）

### 5.2 选择包

根据 OpenWrt 15 上安装的包，在新版本中选择对应的包。

### 5.3 编译

```bash
make -j$(nproc)
```

## 第六步：迁移配置

### 6.1 配置迁移

OpenWrt 配置文件格式基本兼容，但需要注意：
- `/etc/config/system` 的 UCI 配置
- `/etc/config/network` 的网络配置
- `/etc/config/wireless` 的无线配置
- `/etc/config/firewall` 的防火墙配置

### 6.2 包迁移

检查是否有包被弃用或重命名：
- 某些包可能被合并
- 某些包可能需要新版本
- 某些功能可能已经集成到内核

## 第七步：测试

### 7.1 测试编译产物

```bash
# 查看编译产物
ls bin/targets/ramips/mt76x8/
```

### 7.2 准备升级

```bash
# 备份当前系统
sysupgrade -b /tmp/backup.tar.gz

# 使用新固件
sysupgrade /path/to/new-firmware.bin
```

## 常见问题和解决方案

### 问题1：设备不在支持列表

**解决方案**：创建新设备支持或使用相似的设备配置。

### 问题2：包不兼容

**解决方案**：查找替代包或升级到兼容版本。

### 问题3：配置迁移失败

**解决方案**：手动迁移配置，参考新版本的 UCI 配置格式。

### 问题4：网络配置问题

**解决方案**：根据新的内核和驱动，调整网络配置。

## 有用的命令和文件

```bash
# 查看设备树编译信息
make target/linux/install V=s

# 查看设备 DTS 编译过程
cat build_dir/target-*/linux-*/ .config

# 查看特定设备的支持情况
make info

# 列出所有支持的设备
make info | grep "Default"
```

## 参考资料

- [OpenWrt 设备支持数据库](https://openwrt.org/supported_devices)
- [OpenWrt Wiki 设备移植指南](https://openwrt.org/docs/guide-developer/device-tree)
- [OpenWrt 设备树迁移指南](https://openwrt.org/docs/guide-user/installation/generic.migrate)

