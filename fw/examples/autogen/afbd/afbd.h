#ifndef _AFBD_AFBD_H_
#define _AFBD_AFBD_H_

#if defined(__KERNEL__) && defined(__linux__)
	#include <linux/types.h>
#else
	#include <stddef.h>
	#include <stdint.h>
#endif

typedef struct afbd_iface afbd_iface_t;

struct afbd_iface {
	// Single read
	int (*read)(afbd_iface_t * const iface, const uint16_t addr, uint32_t * const data);
	// Single write
	int (*write)(afbd_iface_t * const iface, const uint16_t addr, const uint32_t data);
	// Block read
	int (*readb)(afbd_iface_t * const iface, const uint16_t addr, uint32_t * buf, size_t count);
	// Block write
	int (*writeb)(afbd_iface_t * const iface, const uint16_t addr, const uint32_t * buf, size_t count);
	// Optional custom data used as required to implement the interface.
	// For example, a memory-mapped interface may store memory pointer here.
	void *data;
};

#define afbd_read(elem, data) (afbd_ ## elem ## _read(AFBD_IFACE, data))
#define afbd_write(elem, data) (afbd_ ## elem ## _write(AFBD_IFACE, data))

#ifdef AFBD_SHORT_MACROS
	#undef afbd_read
	#undef afbd_write
	#define read(elem, data) (afbd_ ## elem ## _read(AFBD_IFACE, data))
	#define write(elem, data) (afbd_ ## elem ## _write(AFBD_IFACE, data))
#endif

#endif // _AFBD_AFBD_H_
