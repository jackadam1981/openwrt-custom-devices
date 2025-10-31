# Target files installer for Hiker RT5350
# This package installs DTS and image Makefile into OpenWrt build tree

include $(TOPDIR)/rules.mk

PKG_NAME:=hiker-target
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/hiker-target
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Hiker RT5350 target files installer
  DEPENDS:=@TARGET_ramips_rt305x
  PKGARCH:=all
endef

define Package/hiker-target/description
  Installs Hiker RT5350 device tree and image Makefile
endef

define Build/Compile
	# Nothing to compile
endef

define Package/hiker-target/install
	# This is a build-time only package
	# Actual files are installed via Build/Prepare
endef

define Build/Prepare
	# Install all DTS files
	$(CP) ./files/rt5350_hiker_hiker*.dts $(TOPDIR)/target/linux/ramips/dts/
	
	# Install hiker.mk
	$(CP) ./files/hiker.mk $(TOPDIR)/target/linux/ramips/image/
	
	# Add include to rt305x.mk if not present
	@if ! grep -q "include hiker.mk" $(TOPDIR)/target/linux/ramips/image/rt305x.mk 2>/dev/null; then \
		echo "" >> $(TOPDIR)/target/linux/ramips/image/rt305x.mk; \
		echo "# Hiker RT5350 Devices" >> $(TOPDIR)/target/linux/ramips/image/rt305x.mk; \
		echo "include hiker.mk" >> $(TOPDIR)/target/linux/ramips/image/rt305x.mk; \
		echo "Added hiker.mk to rt305x.mk"; \
	fi
endef

$(eval $(call BuildPackage,hiker-target))

