#ifndef _AFBD_AFBD_H_
#define _AFBD_AFBD_H_

#include <stddef.h>
#include <stdint.h>

typedef struct {
	int (*read)(const uint16_t addr, uint32_t * const data);
	int (*write)(const uint16_t addr, const uint32_t data);
	int (*readb)(const uint16_t addr, uint32_t * buf, size_t count);
	int (*writeb)(const uint16_t addr, const uint32_t * buf, size_t count);
} afbd_iface_t;

#define afbd_read(elem, data) (afbd_ ## elem ## _read(AFBD_IFACE, data))
#define afbd_write(elem, data) (afbd_ ## elem ## _write(AFBD_IFACE, data))

#ifdef AFBD_SHORT_MACROS
	#undef afbd_read
	#undef afbd_write
	#define read(elem, data) (afbd_ ## elem ## _read(AFBD_IFACE, data))
	#define write(elem, data) (afbd_ ## elem ## _write(AFBD_IFACE, data))
#endif

#endif // _AFBD_AFBD_H_
