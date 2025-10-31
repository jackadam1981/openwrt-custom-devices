# WiFi Client 型号问题

## 现象
WiFi客户端型号无法启动无线功能。

## 错误信息
```
rt2800_wmac: probe of 10180000.wmac failed with error -12
ieee80211 phy0: rt2x00lib_request_eeprom_file: Error - Failed to request EEPROM.
```

## 可能原因
1. nvmem-layout 设备树配置问题
2. 缺少必要的内核模块（kmod-nvmem?）
3. 设备树解析错误（"OF: Bad cell count"）

## 当前状态
- 无线驱动已加载（rt2x00, rt2800）
- wmac 设备已识别
- EEPROM 数据存在于 factory 分区
- nvmem 无法从设备树读取 EEPROM

## 需要进一步调查
1. 查看 OpenWrt 官方 RT5350 设备示例
2. 检查是否需要特殊的内核模块
3. 可能需要调整 DTS nvmem-layout 配置
