#include "afbd.h"

int afbd_gpio_switches_read(afbd_iface_t * const iface, uint8_t * const data)
{
	uint32_t aux;
	const int err = iface->read(iface, 0, &aux);
	if (err)
		return err;
	*data = (aux >> 1) & 0xf;
	return 0;
};

int afbd_gpio_leds_read(afbd_iface_t * const iface, uint8_t * const data)
{
	uint32_t aux;
	const int err = iface->read(iface, 0, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x1;
	return 0;
};

int afbd_gpio_leds_write(afbd_iface_t * const iface, uint8_t const data)
{
	return iface->write(iface, 0, (data << 0));
};
