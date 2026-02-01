#ifndef _AFBD_gpio_H_
#define _AFBD_gpio_H_

#include "afbd.h"

int afbd_gpio_switches_read(const afbd_iface_t * const iface, uint8_t * const data);

int afbd_gpio_led_blue_read(const afbd_iface_t * const iface, uint8_t * const data);
int afbd_gpio_led_blue_write(const afbd_iface_t * const iface, uint8_t const data);

#endif // _AFBD_gpio_H_
