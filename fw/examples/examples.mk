EXAMPLES_VERSION = 0.0
EXAMPLES_SITE_METHOD = local
EXAMPLES_SITE = $(TOPDIR)/../../fw/examples
EXAMPLES_LICENSE = BSD-3-Clause


ifeq ($(BR2_PACKAGE_EXAMPLES_GPIO),y)
define EXAMPLES_BUILD_GPIO
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/gpio
endef

define EXAMPLES_INSTALL_GPIO
	$(INSTALL) -D -m 0755 $(@D)/gpio/build/ex-gpio $(TARGET_DIR)/usr/bin/ex-gpio
endef
endif


define EXAMPLES_BUILD_CMDS
	$(EXAMPLES_BUILD_GPIO)
endef

define EXAMPLES_INSTALL_TARGET_CMDS
	$(EXAMPLES_INSTALL_GPIO)
endef

$(eval $(generic-package))
