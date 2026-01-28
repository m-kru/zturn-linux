ZTURN_VERSION = 0.0
ZTURN_SITE_METHOD = local
ZTURN_SITE = $(TOPDIR)/../../fw/zturn
ZTURN_LICENSE = BSD-3-Clause


ifeq ($(BR2_PACKAGE_ZTURN_GPIO),y)
define ZTURN_BUILD_GPIO
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/gpio
endef

define ZTURN_INSTALL_GPIO
	$(INSTALL) -D -m 0755 $(@D)/gpio/zturn-gpio $(TARGET_DIR)/usr/bin/zturn-gpio
endef
endif


define ZTURN_BUILD_CMDS
	$(ZTURN_BUILD_GPIO)
endef

define ZTURN_INSTALL_TARGET_CMDS
	$(ZTURN_INSTALL_GPIO)
endef

$(eval $(generic-package))
