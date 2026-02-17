# Printserver profile: Hiker X9
# 参考 ramips/rt305x 的默认包，补全 base 与 router 类型默认包，避免 APK 构建时 base-files.version 等为空。
# 若 printserver 目标在 OpenWrt 中为 subtarget，请将此文件放到对应 profiles 目录并被 include。

define Profile/hikerx9
	NAME:=Hiker X9
	# 与 include/target.mk 一致的基础包 + router 类型包 + ramips 风格扩展（参考 rt305x）
	PACKAGES:=\
		base-files \
		ca-bundle \
		dropbear \
		fstools \
		libc \
		libgcc \
		libustream-mbedtls \
		logd \
		mtd \
		netifd \
		uci \
		uclient-fetch \
		urandom-seed \
		urngd \
		procd-ujail \
		dnsmasq \
		firewall4 \
		nftables \
		kmod-nft-offload \
		odhcp6c \
		odhcpd-ipv6only \
		ppp \
		ppp-mod-pppoe \
		kmod-leds-gpio \
		kmod-gpio-button-hotplug
endef

$(eval $(call Profile,hikerx9))
