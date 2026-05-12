EXAMPLES_VERSION = 0.0
EXAMPLES_SITE_METHOD = local
EXAMPLES_SITE = $(TOPDIR)/../../fw/examples
EXAMPLES_LICENSE = BSD-3-Clause

ifeq ($(BR2_PACKAGE_EXAMPLES_UIO),y)
define EXAMPLES_BUILD_UIO
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/uio
endef
define EXAMPLES_INSTALL_UIO
	$(INSTALL) -D -m 0755 $(@D)/uio/build/ex-uio $(TARGET_DIR)/usr/bin/ex-uio
endef
endif

ifeq ($(BR2_PACKAGE_EXAMPLES_GPIO),y)
define EXAMPLES_BUILD_GPIO
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/gpio
endef
define EXAMPLES_INSTALL_GPIO
	$(INSTALL) -D -m 0755 $(@D)/gpio/build/ex-gpio $(TARGET_DIR)/usr/bin/ex-gpio
endef
endif

ifeq ($(BR2_PACKAGE_EXAMPLES_TIMER_IRQ),y)
define EXAMPLES_BUILD_TIMER_IRQ
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/timer-irq
endef
define EXAMPLES_INSTALL_TIMER_IRQ
	$(INSTALL) -D -m 0755 $(@D)/timer-irq/build/ex-timer-irq $(TARGET_DIR)/usr/bin/ex-timer-irq
endef
endif

define EXAMPLES_BUILD_CMDS
	$(EXAMPLES_BUILD_UIO)
	$(EXAMPLES_BUILD_GPIO)
	$(EXAMPLES_BUILD_TIMER_IRQ)
endef

define EXAMPLES_INSTALL_TARGET_CMDS
	$(EXAMPLES_INSTALL_UIO)
	$(EXAMPLES_INSTALL_GPIO)
	$(EXAMPLES_INSTALL_TIMER_IRQ)
endef

$(eval $(generic-package))
