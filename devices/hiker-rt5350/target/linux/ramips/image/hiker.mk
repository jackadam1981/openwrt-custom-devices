# Hiker RT5350 Device Definition
# Include this file in target/linux/ramips/image/rt305x.mk

define Device/hiker_hiker
  SOC := rt5350
  IMAGE_SIZE := 7872k
  DEVICE_VENDOR := Hiker
  DEVICE_MODEL := Hiker
  SUPPORTED_DEVICES := HIKER
endef
TARGET_DEVICES += hiker_hiker
