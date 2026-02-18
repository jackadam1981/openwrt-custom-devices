# SPDX-License-Identifier: GPL-2.0-only
#
# Based on OpenWrt ramips image Makefile, adapted for printserver.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += LOADER_TYPE LOADER_FLASH_OFFS LZMA_TEXT_START
DEVICE_VARS += NETGEAR_BOARD_ID NETGEAR_HW_ID
DEVICE_VARS += NETGEAR_ENC_MODEL NETGEAR_ENC_REGION NETGEAR_ENC_HW_ID_LIST NETGEAR_ENC_MODEL_LIST
DEVICE_VARS += BUFFALO_TAG_PLATFORM BUFFALO_TAG_VERSION BUFFALO_TAG_MINOR
DEVICE_VARS += SEAMA_SIGNATURE SEAMA_MTDBLOCK
DEVICE_VARS += SERCOMM_HWNAME SERCOMM_HWID SERCOMM_HWVER SERCOMM_SWVER
DEVICE_VARS += SERCOMM_PAD JCG_MAXSIZE

loadaddr-y := 0x80000000

ldrplatform-y := ralink

ldrflashstart-y := 0x1c000000

LOADADDR := $(loadaddr-y)
LOADER_PLATFORM := $(ldrplatform-y)
LOADER_FLASH_START := $(ldrflashstart-y)

KERNEL_DTB = kernel-bin | append-dtb | lzma

define Build/loader-common
	rm -rf $@.src
	$(MAKE) -C lzma-loader \
		PKG_BUILD_DIR="$@.src" \
		TARGET_DIR="$(dir $@)" LOADER_NAME="$(notdir $@)" \
		BOARD="$(BOARDNAME)" PLATFORM="$(LOADER_PLATFORM)" \
		LZMA_TEXT_START=$(LZMA_TEXT_START) \
		LOADADDR=$(LOADADDR) \
		SUBTARGET=$(SUBTARGET) \
		$(1) compile loader.$(LOADER_TYPE)
	mv "$@.$(LOADER_TYPE)" "$@"
	rm -rf $@.src
endef

define Build/loader-kernel
	$(call Build/loader-common,LOADER_DATA="$@")
endef

define Device/Default
	PROFILES = Default
	BLOCKSIZE := 64k
	KERNEL := $(KERNEL_DTB) | uImage lzma
	KERNEL_LOADADDR := $(loadaddr-y)
	LZMA_TEXT_START := 0x81800000
	SOC := $(DEFAULT_SOC)
	DEVICE_DTS_DIR := ../dts
	DEVICE_DTS = $$(SOC)_$(1)
	IMAGES := sysupgrade.bin
	COMPILE :=
	sysupgrade_bin := append-kernel | append-rootfs | pad-rootfs
	IMAGE/sysupgrade.bin := append-kernel | append-rootfs | pad-rootfs | check-size | append-metadata
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))

