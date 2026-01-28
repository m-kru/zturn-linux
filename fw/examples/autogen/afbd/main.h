#ifndef _AFBD_main_H_

#include "afbd.h"

extern const uint32_t afbd_main_ID;
int afbd_main_ID_read(const afbd_iface_t * const iface, uint32_t * const data);

int afbd_main_write_read_test_read(const afbd_iface_t * const iface, uint32_t * const data);
int afbd_main_write_read_test_write(const afbd_iface_t * const iface, uint32_t const data);

int afbd_main_led_red_read(const afbd_iface_t * const iface, uint8_t * const data);
int afbd_main_led_red_write(const afbd_iface_t * const iface, uint8_t const data);

#endif // _AFBD_main_H_
