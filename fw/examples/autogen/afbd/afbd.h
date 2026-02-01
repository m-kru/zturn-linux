#ifndef _AFBD_AFBD_H_
#define _AFBD_AFBD_H_

#if defined(__KERNEL__) && defined(__linux__)
	#include <linux/types.h>
#else
	#include <stddef.h>
	#include <stdint.h>
#endif

typedef struct {
	// Single read
	int (*read)(const uint16_t addr, uint32_t * const data);
	// Single write
	int (*write)(const uint16_t addr, const uint32_t data);
	// Block read
	int (*readb)(const uint16_t addr, uint32_t * buf, size_t count);
	// Block write
	int (*writeb)(const uint16_t addr, const uint32_t * buf, size_t count);
	// Optional custom data used as required to implement the interface.
	// For example, a memory-mapped interface may store memory pointer here.
	void *data;
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
