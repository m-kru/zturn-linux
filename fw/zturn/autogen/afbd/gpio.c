#include "afbd.h"

int afbd_gpio_switches_read(const afbd_iface_t * const iface, uint8_t * const data) {
	uint32_t aux;
	const int err = iface->read(1024, &aux);
	if (err)
		return err;
	*data = (aux >> 1) & 0xf;
	return 0;
};

int afbd_gpio_led_blue_read(const afbd_iface_t * const iface, uint8_t * const data) {
	uint32_t aux;
	const int err = iface->read(1024, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x1;
	return 0;
};

int afbd_gpio_led_blue_write(const afbd_iface_t * const iface, uint8_t const data) {
	return iface->write(1024, (data << 0));
 };
