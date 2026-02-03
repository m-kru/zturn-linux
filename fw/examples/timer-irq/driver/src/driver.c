#include <linux/eventfd.h>
#include <linux/err.h>
#include <linux/fs.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/mod_devicetable.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/uaccess.h>

#include "afbd/afbd.h"
#include "afbd/mmap-iface.h"
#include "afbd/timer.h"
#define AFBD_IFACE &afbd_iface

static afbd_iface_t afbd_iface;

#define DEV_NAME "ex-timer-irq"

#define TIMER_FREQ 50000000

#define SET_EVENTFD _IOW('a', '1', int)
struct eventfd_ctx *efd_ctx = NULL;

static bool opened = false;
static void __iomem *memory;

static long dev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	int user_fd;

	if (cmd == SET_EVENTFD) {
		if (copy_from_user(&user_fd, (int __user *)arg, sizeof(int)))
			return -EFAULT;

		// Release old context if it exists
		if (efd_ctx)
			eventfd_ctx_put(efd_ctx);

		// Get the context from the user's FD
		efd_ctx = eventfd_ctx_fdget(user_fd);
		if (IS_ERR(efd_ctx))
			return PTR_ERR(efd_ctx);

		pr_info("%s: eventfd context registered\n", DEV_NAME);
	}
	return 0;
}

static int dev_open(struct inode *inodep, struct file *filep)
{
	if (opened) {
		pr_info("%s: can'open device more than once\n", DEV_NAME);
		return 1;
	}
	pr_info("%s: opening\n", DEV_NAME);
	return 0;
}

static int dev_release(struct inode *inodep, struct file *filep)
{
	if (efd_ctx) {
		eventfd_ctx_put(efd_ctx);
		efd_ctx = NULL;
	}

	pr_info("%s: closing\n", DEV_NAME);
	return 0;
}

static ssize_t dev_write(struct file *filep, const char *buffer, size_t len, loff_t *offset)
{
	if (len != 4)
		return -EINVAL;

	uint32_t period_in_ms;
	if (copy_from_user(&period_in_ms, buffer, 4))
		return -EFAULT;

	const uint32_t period_in_ticks = period_in_ms * (TIMER_FREQ / 1000);
	if (period_in_ticks > 0) {
		pr_info("%s: starting timer with period %u ticks\n", DEV_NAME, period_in_ticks);
		afbd_timer_start(&afbd_iface, period_in_ticks);
	} else {
		pr_info("%s: stopping timer\n", DEV_NAME);
		afbd_timer_stop(&afbd_iface);
	}

	return 4;
}

static struct file_operations fops = {
	.unlocked_ioctl = dev_ioctl,
	.open = dev_open,
	.read = NULL,
	.write = dev_write,
	.release = dev_release,
};

static struct miscdevice misc_device = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = DEV_NAME,
	.fops = &fops,
};

static irqreturn_t irq_handler(int irq, void *dev_id)
{
	if (efd_ctx)
		eventfd_signal(efd_ctx, 1);

	return IRQ_HANDLED;
}

static int driver_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;

	dev_info(dev, "probing ...\n");

	memory = devm_platform_ioremap_resource(pdev, 0);
	if (IS_ERR(memory)) {
		dev_err(dev, "failed to map IO memory\n");
		return PTR_ERR(memory);
	}

	afbd_iface = afbd_mmap_iface(memory);

	int ret = misc_register(&misc_device);
	if (ret) {
		dev_err(&pdev->dev, "could not register misc device\n");
		return ret;
	}

	int irq = platform_get_irq(pdev, 0);
	if (irq < 0) {
		dev_err(&pdev->dev, "couldn't get irq");
		return irq;
	}
	dev_info(&pdev->dev, "assigned Linux IRQ number: %d\n", irq);

	ret = devm_request_irq(
		&pdev->dev, irq, irq_handler, IRQF_TRIGGER_RISING, DEV_NAME, NULL
	);

	dev_info(dev, "device successfully initialized at 0x%px\n", memory);
	return 0;
}

static int driver_remove(struct platform_device *pdev)
{
	misc_deregister(&misc_device);
	dev_info(&pdev->dev, "device successfully\n");
	return 0;
}

static const struct of_device_id dt_ids[] = {
	{ .compatible = "ex-timer-irq", },
	{ }
};
MODULE_DEVICE_TABLE(of, dt_ids);

static struct platform_driver plat_driver = {
	.probe = driver_probe,
	.remove = driver_remove,
	.driver = {
		.name  = DEV_NAME,
		.owner = THIS_MODULE,
		.of_match_table = dt_ids,
	},
};

module_platform_driver(plat_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("mkru");
MODULE_DESCRIPTION("An example gpio driver.");
