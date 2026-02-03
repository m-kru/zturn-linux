#include "afbd.h"

int afbd_timer_counter_read(afbd_iface_t * const iface, uint32_t * const data)
{
	return iface->read(iface, 2, data);
};

int afbd_timer_start(afbd_iface_t * const iface, const uint32_t period)
{
	return iface->write(iface, 0, period << 0);
};

int afbd_timer_stop(afbd_iface_t * const iface)
{
	return iface->write(iface, 1, 0);
};

