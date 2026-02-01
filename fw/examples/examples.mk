EXAMPLES_VERSION = 0.0
EXAMPLES_SITE_METHOD = local
EXAMPLES_SITE = $(TOPDIR)/../../fw/examples
EXAMPLES_LICENSE = BSD-3-Clause


ifeq ($(BR2_PACKAGE_EXAMPLES_GPIO_APP),y)
define EXAMPLES_BUILD_GPIO_APP
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/gpio
endef
define EXAMPLES_INSTALL_GPIO_APP
	$(INSTALL) -D -m 0755 $(@D)/gpio/build/ex-gpio $(TARGET_DIR)/usr/bin/ex-gpio
endef
endif

ifeq ($(BR2_PACKAGE_EXAMPLES_GPIO_DRIVER),y)
EXAMPLES_MODULE_SUBDIRS += gpio/driver
endif


define EXAMPLES_BUILD_CMDS
	$(EXAMPLES_BUILD_GPIO_APP)
endef

define EXAMPLES_INSTALL_TARGET_CMDS
	$(EXAMPLES_INSTALL_GPIO_APP)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
