# Factory / EEPROM 完全指南

## 🎯 什么是 factory / EEPROM

### 不同名称，同一个东西

| 上下文 | 名称 | 说明 |
|--------|------|------|
| **Breed** | EEPROM | Breed Bootloader 的术语 |
| **OpenWrt** | factory 分区 | MTD 分区名称 |
| **原厂固件** | EEPROM / ART | 各厂商叫法不同 |
| **本质** | Flash 的一个分区 | 存储校准数据 |

### 位置

```
SPI Flash (8 MB)
├── 0x000000  u-boot (192 KB)
├── 0x030000  u-boot-env (64 KB)
├── 0x040000  factory ← 这里！(64 KB)
└── 0x050000  firmware (7872 KB)
```

## 📋 factory 分区内容

### 完整布局

```
Offset    大小      内容
────────────────────────────────────────
0x0000    512 B     WiFi EEPROM (RT2860)
  ├─ 0x00  2 B      芯片型号
  ├─ 0x02  2 B      版本
  ├─ 0x04  6 B      MAC 地址 ⭐
  ├─ 0x0A  ...      国家代码
  ├─ 0x20  ...      发射功率表
  ├─ 0x34  ...      天线参数
  └─ 0x...  ...     频率校准

0x0028    6 B       备用 MAC（某些设备）

0x0200    ...       厂商自定义数据

剩余空间            未使用 (0xFF 填充)
```

## 🔧 备份和恢复

### 方法 1：使用 Breed（推荐）⭐

```
备份：
1. 进入 Breed (断电按住 Reset，上电)
2. 浏览器访问 192.168.1.1
3. 固件备份 → EEPROM 备份
4. 下载 eeprom.bin (64 KB)

恢复：
1. 进入 Breed
2. 固件更新 → EEPROM 更新
3. 选择备份的 eeprom.bin
4. 上传并写入
```

### 方法 2：在 OpenWrt 中备份

```bash
# SSH 到设备
ssh root@192.168.168.1

# 备份 factory 分区
dd if=/dev/mtd2 of=/tmp/factory.bin
# 或
cat /dev/mtd2 > /tmp/factory.bin

# 下载到本地
scp root@192.168.168.1:/tmp/factory.bin ~/hiker-factory.bin
```

### 方法 3：在 OpenWrt 中恢复

```bash
# 上传 factory.bin
scp factory.bin root@192.168.168.1:/tmp/

# 写入 factory 分区（危险！）
mtd write /tmp/factory.bin factory

# 重启
reboot
```

## 🛠️ 修改 MAC 地址

### 工具 1：编辑脚本（推荐）⭐

```bash
cd /home/jack/openwrt/scripts

# 修改 MAC
./edit-factory-mac.sh factory.bin AA:BB:CC:DD:EE:FF

# 会自动备份原文件
# 生成新的 factory.bin
```

### 工具 2：hexedit（图形界面）

```bash
# 安装 hexedit
sudo apt-get install hexedit

# 编辑文件
hexedit factory.bin

# 跳转到偏移 0x4（按 Tab 输入 4）
# 修改 6 个字节的 MAC
# 按 Ctrl+X 保存
```

### 工具 3：xxd（命令行）

```bash
# 查看 MAC 位置
xxd -s 0x4 -l 6 factory.bin
# 00000004: 2c67 fb38 783c

# 转换为文本
xxd factory.bin > factory.hex

# 编辑 factory.hex
# 找到第 4 字节处，修改 MAC

# 转换回二进制
xxd -r factory.hex > factory_new.bin
```

### 工具 4：Python 脚本

```python
#!/usr/bin/env python3
# edit_mac.py

import sys

if len(sys.argv) != 3:
    print("用法: python3 edit_mac.py factory.bin AA:BB:CC:DD:EE:FF")
    sys.exit(1)

factory_file = sys.argv[1]
new_mac = sys.argv[2]

# 读取文件
with open(factory_file, 'rb') as f:
    data = bytearray(f.read())

# 解析 MAC
mac_bytes = bytes.fromhex(new_mac.replace(':', ''))

# 写入 MAC（偏移 0x4）
data[0x4:0x4+6] = mac_bytes

# 保存
with open(factory_file + '.new', 'wb') as f:
    f.write(data)

print(f"✓ 新文件已保存: {factory_file}.new")
print(f"新 MAC: {new_mac}")
```

## 🧪 查看 factory 内容

### 使用查看脚本

```bash
cd /home/jack/openwrt/scripts

# 查看 factory.bin 内容
./view-factory.sh factory.bin

# 输出：
# MAC 地址: 2C:67:FB:38:78:3C
# WiFi EEPROM: ...
```

### 手动查看

```bash
# 查看 MAC（偏移 0x4，6 字节）
hexdump -C factory.bin -s 4 -n 6
# 00000004  2c 67 fb 38 78 3c

# 查看 WiFi EEPROM（偏移 0x0，512 字节）
hexdump -C factory.bin -n 512

# 查看完整文件
hexdump -C factory.bin | less
```

## 📊 MAC 地址格式

### 文本 → 二进制

```
文本格式: AA:BB:CC:DD:EE:FF
十六进制: AA BB CC DD EE FF
二进制:   (6 个字节)

例如:
2C:67:FB:38:78:3C
↓
0x2C 0x67 0xFB 0x38 0x78 0x3C
```

### 在 factory.bin 中的位置

```
偏移    内容
────────────────────────────
0x0000  [WiFi EEPROM 开始]
0x0001  ...
0x0002  ...
0x0003  ...
0x0004  MAC 字节 1 ← 这里开始
0x0005  MAC 字节 2
0x0006  MAC 字节 3
0x0007  MAC 字节 4
0x0008  MAC 字节 5
0x0009  MAC 字节 6 ← 这里结束
0x000A  [其他数据]
```

## 🔧 实际操作示例

### 示例：修改为自定义 MAC

```bash
cd /home/jack/openwrt/scripts

# 假设你有备份的 factory.bin
# 当前 MAC: 2C:67:FB:38:78:3C
# 想改成: AA:BB:CC:11:22:33

./edit-factory-mac.sh ~/hiker-factory.bin AA:BB:CC:11:22:33

# 输出：
# ✓ 已备份到: hiker-factory.bin.backup.20251028_123456
# 原 MAC: 2C:67:FB:38:78:3C
# 新 MAC: AA:BB:CC:11:22:33
# ✓ MAC 地址已更新
```

### 验证修改

```bash
# 查看修改后的文件
hexdump -C hiker-factory.bin -s 4 -n 6
# 00000004  aa bb cc 11 22 33  ← 已修改

# 或使用查看脚本
./view-factory.sh hiker-factory.bin
# MAC: AA:BB:CC:11:22:33
```

## ⚠️ 重要提示

### 1. 永远先备份！

```bash
# 备份原始文件
cp factory.bin factory.bin.original

# 然后再修改
./edit-factory-mac.sh factory.bin NEW:MA:CA:DD:RE:SS
```

### 2. MAC 地址规则

```
有效的 MAC:
✅ 单播地址（第一字节偶数）
   AA:BB:CC:DD:EE:FF  (0xAA = 170 = 偶数)
   
❌ 组播地址（第一字节奇数）
   AB:BB:CC:DD:EE:FF  (0xAB = 171 = 奇数)

推荐使用:
✅ 本地管理地址（第二位为 2/6/A/E）
   02:xx:xx:xx:xx:xx
   06:xx:xx:xx:xx:xx
```

### 3. 不要修改其他数据

```
factory.bin 中：
✅ 可以修改: MAC 地址 (0x4-0x9)
❌ 不要改: WiFi 校准数据（其他部分）
```

**WiFi 校准是设备特定的，修改会导致 WiFi 异常！**

## 🎯 使用场景

### 场景 1：多设备相同 MAC 冲突

```bash
# 设备 A: 2C:67:FB:38:78:3C
# 设备 B: 2C:67:FB:38:78:3C (相同！)

# 修改设备 B 的 MAC
./edit-factory-mac.sh factory-b.bin 2C:67:FB:38:78:3D
#                                               最后一位 +1
```

### 场景 2：想用自定义 MAC

```bash
# 使用本地管理的 MAC
./edit-factory-mac.sh factory.bin 02:11:22:33:44:55
```

### 场景 3：Breed 恢复后修改

```bash
# 从 Breed 备份的 EEPROM
# 修改 MAC 后再刷回
./edit-factory-mac.sh eeprom.bin NEW:MA:CA:DD:RE:SS

# 在 Breed 中上传修改后的文件
```

## 📝 工具对比

| 工具 | 难度 | 推荐度 | 说明 |
|------|------|--------|------|
| **edit-factory-mac.sh** | 简单 | ⭐⭐⭐⭐⭐ | 自动化脚本 |
| **hexedit** | 中等 | ⭐⭐⭐⭐ | 图形界面 |
| **xxd** | 中等 | ⭐⭐⭐ | 命令行 |
| **dd + printf** | 复杂 | ⭐⭐ | 底层操作 |
| **Python** | 简单 | ⭐⭐⭐⭐ | 灵活 |

## ✅ 总结

**Breed 的 EEPROM = factory 分区**

**修改 MAC 地址**：
- ✅ 使用 `edit-factory-mac.sh` 脚本（最简单）
- ✅ 或用 hexedit 图形编辑
- ✅ 修改偏移 0x4 的 6 个字节
- ⚠️ 永远先备份！

**已创建的工具**：
- `scripts/edit-factory-mac.sh` - 修改 MAC
- `scripts/view-factory.sh` - 查看内容

直接使用即可！🎯

