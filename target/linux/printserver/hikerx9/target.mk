#
# Print server subtarget: Hiker X9 (RT5350)
# Kernel/config aligned with ramips/rt305x.
#

SUBTARGET:=hikerx9
BOARDNAME:=Hiker X9 (RT5350)
FEATURES+=usb ramdisk small_flash
CPU_TYPE:=24kc

DEFAULT_PROFILE:=hikerx9
DEFAULT_PACKAGES += kmod-rt2800-soc wpad-basic-mbedtls swconfig

define Target/Description
	Build firmware images for Hiker X9 print server (RT5350).
endef
