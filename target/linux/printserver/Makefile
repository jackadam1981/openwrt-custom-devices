# SPDX-License-Identifier: GPL-2.0-only
#
# Print server target (e.g. Hiker X9 / RT5350)
# Same ARCH/kernel as ramips/rt305x; subtarget hikerx9 uses rt305x kernel.

include $(TOPDIR)/rules.mk

ARCH:=mipsel
BOARD:=printserver
BOARDNAME:=Print Server (RT5350 etc.)
SUBTARGETS:=hikerx9
FEATURES:=squashfs gpio

KERNEL_PATCHVER:=6.12

define Target/Description
	Build firmware images for print server boards (e.g. Hiker X9 / RT5350).
endef

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += kmod-leds-gpio kmod-gpio-button-hotplug

$(eval $(call BuildTarget))
