# SPDX-License-Identifier: GPL-2.0-only
#
# Kernel modules for printserver target (RT5350 / Hiker X9).
# Same SoC as ramips/rt305x; only modules relevant to rt305x are listed.

OTHER_MENU:=Other modules

I2C_RALINK_MODULES:= \
	CONFIG_I2C_RALINK:drivers/i2c/busses/i2c-ralink

define KernelPackage/i2c-ralink
	$(call i2c_defaults,$(I2C_RALINK_MODULES),59)
	TITLE:=Ralink I2C Controller
	DEPENDS:=+kmod-i2c-core @TARGET_printserver
endef

define KernelPackage/i2c-ralink/description
	Kernel modules for enable ralink i2c controller (RT305x/RT5350).
endef

$(eval $(call KernelPackage,i2c-ralink))

define KernelPackage/dma-ralink
	SUBMENU:=Other modules
	TITLE:=Ralink GDMA Engine
	DEPENDS:=@TARGET_printserver
	KCONFIG:= \
		CONFIG_DMADEVICES=y \
		CONFIG_RALINK_GDMA
	FILES:= \
		$(LINUX_DIR)/drivers/dma/virt-dma.ko \
		$(LINUX_DIR)/drivers/dma/ralink-gdma.ko
	AUTOLOAD:=$(call AutoLoad,52,ralink-gdma)
endef

define KernelPackage/dma-ralink/description
	Kernel modules for enable ralink gdma engine (RT305x/RT5350).
endef

$(eval $(call KernelPackage,dma-ralink))
