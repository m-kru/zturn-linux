#if defined(__KERNEL__)
	#include <linux/io.h>
#else
	#include <stdatomic.h>
#endif

#include "linux-mmap-iface.h"

static int afbd_linux_mmap_iface_read(afbd_iface_t *const iface, const uintptr_t addr, uint32_t *const data)
{
#if defined(__KERNEL__)
	*data = ioread32((uint32_t __iomem *)iface->data + addr);
#else
	#error "unimplemented"
#endif
	return 0;
}

static int afbd_linux_mmap_iface_write(afbd_iface_t *const iface, const uintptr_t addr, const uint32_t data)
{
#if defined(__KERNEL__)
	iowrite32(data, (uint32_t __iomem *)iface->data + addr);
#else
	#error "unimplemented"
#endif
	return 0;
}

static int afbd_linux_mmap_iface_readb(afbd_iface_t *const iface, const uintptr_t addr, uint32_t *buf, size_t count)
{
	for (size_t i = 0; i < count; i++)
		iface->read(iface, addr + i, &buf[i]);

	return count;
}

static int afbd_linux_mmap_iface_writeb(afbd_iface_t *const iface, const uintptr_t addr, const uint32_t *buf, size_t count)
{
	for (size_t i = 0; i < count; i++)
		iface->write(iface, addr + i, buf[i]);

	return count;
}

afbd_iface_t afbd_linux_mmap_iface(void *const iomem)
{
	return (afbd_iface_t){
		read: afbd_linux_mmap_iface_read,
		write: afbd_linux_mmap_iface_write,
		readb: afbd_linux_mmap_iface_readb,
		writeb: afbd_linux_mmap_iface_writeb,
		data: iomem
	};
}
