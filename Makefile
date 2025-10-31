# Hiker Feed Makefile
# This file is required for OpenWrt feed system

include $(TOPDIR)/rules.mk

all:

install:
	# Install target files into OpenWrt build tree
	$(INSTALL_DIR) $(TOPDIR)/target/linux/ramips/dts
	$(INSTALL_DATA) ./target/linux/ramips/dts/*.dts $(TOPDIR)/target/linux/ramips/dts/
	
	$(INSTALL_DIR) $(TOPDIR)/target/linux/ramips/image
	$(INSTALL_DATA) ./target/linux/ramips/image/*.mk $(TOPDIR)/target/linux/ramips/image/
	
	# Add hiker.mk include to rt305x.mk if not present
	@if [ -f $(TOPDIR)/target/linux/ramips/image/rt305x.mk ]; then \
		if ! grep -q "include hiker.mk" $(TOPDIR)/target/linux/ramips/image/rt305x.mk; then \
			echo "" >> $(TOPDIR)/target/linux/ramips/image/rt305x.mk; \
			echo "# Hiker RT5350 Devices" >> $(TOPDIR)/target/linux/ramips/image/rt305x.mk; \
			echo "include hiker.mk" >> $(TOPDIR)/target/linux/ramips/image/rt305x.mk; \
		fi; \
	fi

clean:

.PHONY: all install clean

