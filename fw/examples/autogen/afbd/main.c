#include "afbd.h"

const uint32_t afbd_main_ID = 0x896b0683;
int afbd_main_ID_read(afbd_iface_t * const iface, uint32_t * const data)
{
	return iface->read(iface, 0, data);
};

int afbd_main_write_read_test_read(afbd_iface_t * const iface, uint32_t * const data)
{
	return iface->read(iface, 1, data);
};

int afbd_main_write_read_test_write(afbd_iface_t * const iface, uint32_t const data)
{
	return iface->write(iface, 1, data);
};

int afbd_main_led_red_read(afbd_iface_t * const iface, uint8_t * const data)
{
	uint32_t aux;
	const int err = iface->read(iface, 2, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x1;
	return 0;
};

int afbd_main_led_red_write(afbd_iface_t * const iface, uint8_t const data)
{
	return iface->write(iface, 2, (data << 0));
};
