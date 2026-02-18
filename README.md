# openwrt-custom-devices

以 feed 形式提供 OpenWrt 自定义设备 overlay，供 [Actions-OpenWrt](https://github.com/jackadam1981/Actions-OpenWrt) 等构建流程使用。

## 架构与 Board 选择

本仓库采用 **ramips/rt305x + 设备 overlay** 方案，复用主线 generic 的 kernel、dts、patches，不做独立 board。

| 说明       | 路径 |
|------------|------|
| 架构       | ramips（或 rockchip 等，按需扩展） |
| 子 target  | rt305x（RT5350 等 MIPS 24Kc 芯片） |
| 设备 overlay | `target/linux/ramips/image/hiker.mk` + `target/linux/ramips/dts/` |

## Target 与 Device 选择

在 `make menuconfig` 中依次选择：

1. **Target System** → `MediaTek Ralink MIPS`（ramips）
2. **Subtarget** → `RT3x5x/RT5350 based boards`（rt305x）
3. **Target Profile** → 选择本 feed 提供的设备，如：
   - `Hiker X9 Minimal`
   - `Hiker X9 Print`（打印服务器，推荐）
   - `Hiker X9 Full`（打印 + 完整 WiFi）

对应 `.config` 示例（最精简）：

```
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_rt305x=y
CONFIG_TARGET_ramips_rt305x_DEVICE_hiker_x9_minimal=y
```
对应 `.config` 示例（同时编译三个）：
```
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_rt305x=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_ramips_rt305x_DEVICE_hiker_x9-minimal=y
CONFIG_TARGET_ramips_rt305x_DEVICE_hiker_x9-p910nd=y
CONFIG_TARGET_ramips_rt305x_DEVICE_hiker_x9-full=y
```

## 创建最精简 .config

使用 OpenWrt 自带的 `scripts/diffconfig.sh` 生成仅包含你修改的精简配置。

### 流程

1. **更新 feed 并安装设备定义**

   ```bash
   ./scripts/feeds update targets
   ./scripts/feeds install -p targets -f <target-package>
   ```

2. **配置目标设备**

   ```bash
   make menuconfig
   # 选择 Target System → ramips
   # 选择 Subtarget → rt305x
   # 选择 Target Profile → Hiker X9 Print（或其它设备）
   # 勾选需要的 LuCI、p910nd 等包
   ```

3. **生成精简 diff**

   ```bash
   ./scripts/diffconfig.sh > my-minimal.config
   ```

4. **使用精简配置重建**

   - 将 `my-minimal.config` 复制为 `.config`
   - 执行 `make defconfig` 展开为完整配置
   - 再执行 `make` 编译

### diffconfig 说明

- **输入**：当前工作目录下的 `.config`（完整或部分均可）
- **输出**：相对于 defconfig 的增量，只包含非默认选项
- **适用**：版本控制、跨构建复用、CI 中作为 targets/\<name\>/.config

若需更精简，可手工删除 diff 中由依赖自动拉入的包，只保留顶层显式勾选的包。
