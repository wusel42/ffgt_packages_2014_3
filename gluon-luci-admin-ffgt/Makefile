# Copyright (C) 2013 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-admin-ffgt
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-luci-admin-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci based simple administration interface for mesh nodes, FFGT version
  DEPENDS:=+gluon-luci-core +gluon-config-mode-ffgt
  PROVIDES:=gluon-luci-admin
endef

define Package/gluon-luci-admin-ffgt/description
	Luci based config mode
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-luci-admin-ffgt/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-luci-admin-ffgt))
