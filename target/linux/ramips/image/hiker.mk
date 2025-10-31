# Hiker RT5350 Device Profiles
# Include this file in target/linux/ramips/image/rt305x.mk

# Common configuration for all Hiker profiles
define Device/hiker_hiker-common
  SOC := rt5350
  IMAGE_SIZE := 7872k
  DEVICE_VENDOR := Hiker
  SUPPORTED_DEVICES := HIKER
endef

# Profile 1: Minimal (基础版)
define Device/hiker_hiker-minimal
  $(call Device/hiker_hiker-common)
  DEVICE_MODEL := Hiker Minimal
  DEVICE_PACKAGES := luci-light luci-theme-bootstrap \
    luci-i18n-base-zh-cn
endef
TARGET_DEVICES += hiker_hiker-minimal

# Profile 2: P910ND (打印服务器) ⭐ 推荐
define Device/hiker_hiker-p910nd
  $(call Device/hiker_hiker-common)
  DEVICE_MODEL := Hiker Print
  DEVICE_PACKAGES := luci-light luci-theme-bootstrap \
    luci-i18n-base-zh-cn \
    p910nd luci-app-p910nd luci-i18n-p910nd-zh-cn \
    kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb-printer
endef
TARGET_DEVICES += hiker_hiker-p910nd

# Profile 3: WiFi Client (打印+WiFi客户端)
define Device/hiker_hiker-wifi-client
  $(call Device/hiker_hiker-common)
  DEVICE_MODEL := Hiker WifiClient
  DEVICE_PACKAGES := luci-light luci-theme-bootstrap \
    luci-i18n-base-zh-cn \
    p910nd luci-app-p910nd luci-i18n-p910nd-zh-cn \
    kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb-printer \
    kmod-mac80211 kmod-rt2800-lib kmod-rt2800-mmio kmod-rt2800-soc \
    kmod-rt2x00-lib kmod-rt2x00-mmio \
    wpad-basic-mbedtls hostapd-common iw iwinfo
endef
TARGET_DEVICES += hiker_hiker-wifi-client

# Profile 4: Full WiFi (打印+完整WiFi)
define Device/hiker_hiker-full-wifi
  $(call Device/hiker_hiker-common)
  DEVICE_MODEL := Hiker WifiFull
  DEVICE_PACKAGES := luci-light luci-theme-bootstrap \
    luci-i18n-base-zh-cn \
    p910nd luci-app-p910nd luci-i18n-p910nd-zh-cn \
    kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb-printer \
    kmod-mac80211 kmod-rt2800-lib kmod-rt2800-mmio kmod-rt2800-soc \
    kmod-rt2x00-lib kmod-rt2x00-mmio \
    wpad-basic-mbedtls hostapd-common iw iwinfo
endef
TARGET_DEVICES += hiker_hiker-full-wifi
