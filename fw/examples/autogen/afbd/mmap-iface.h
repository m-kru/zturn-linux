#ifndef _AFBD_MMAP_IFACE_H_
#define _AFBD_MMAP_IFACE_H_

#if defined(__KERNEL__) && defined(__linux__)
	#include <linux/types.h>
#else
	#include <stddef.h>
	#include <stdint.h>
#endif

#include "afbd.h"

// Initializes are return. afbd interface
// Mem is a pointer to the memory-mapped IO.
afbd_iface_t afbd_mmap_iface(void *mem);

#endif // _AFBD_MMAP_IFACE_H_
