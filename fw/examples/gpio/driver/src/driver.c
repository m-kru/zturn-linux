#include <linux/fs.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/of.h>
#include <linux/io.h>
#include <linux/err.h>
#include <linux/uaccess.h>
#include <linux/miscdevice.h>

#include "afbd/afbd.h"
#include "afbd/linux-mmap-iface.h"
#include "afbd/gpio.h"
#define AFBD_IFACE &afbd_iface

static afbd_iface_t afbd_iface;

#define DEV_NAME "ex-gpio"

//static int major;
static bool opened = false;

static void __iomem *memory;

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
	pr_info("%s: closing\n", DEV_NAME);
	return 0;
}

static ssize_t dev_read(struct file *filep, char *buffer, size_t len, loff_t *offset)
{
	if (len != 4)
		return -EINVAL;

	uint32_t switches = 0;
	int err = afbd_read(gpio_switches, (uint8_t*)&switches);
	if (err)
		return -EFAULT;

	err = copy_to_user(buffer, &switches, 4);
	if (err)
		return -EFAULT;

	return 4;
}

static ssize_t dev_write(struct file *filep, const char *buffer, size_t len, loff_t *offset)
{
	if (len != 4)
		return -EINVAL;

	uint32_t leds;
	if (copy_from_user(&leds, buffer, 4)) {
		return -EFAULT;
	}

	afbd_write(gpio_leds, leds);

	return 4;
}

static struct file_operations fops = {
	.open = dev_open,
	.read = dev_read,
	.write = dev_write,
	.release = dev_release,
};

static struct miscdevice misc_device = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = DEV_NAME,
	.fops = &fops,
};

static int driver_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;

	dev_info(dev, "probing ...\n");

	memory = devm_platform_ioremap_resource(pdev, 0);
	if (IS_ERR(memory)) {
		dev_err(dev, "failed to map IO memory\n");
		return PTR_ERR(memory);
	}

	afbd_iface = afbd_linux_mmap_iface(memory);

	const int ret = misc_register(&misc_device);
	if (ret) {
		dev_err(&pdev->dev, "could not register misc device\n");
		return ret;
	}

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
	{ .compatible = "ex-gpio", },
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
