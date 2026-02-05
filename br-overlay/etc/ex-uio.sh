#!/bin/sh

# MDEV variable $MDEV is the current node (e.g., uio0)
# Check the name attribute in sysfs
UIO_NAME=$(cat /sys/class/uio/"$MDEV"/name)

if [ "$UIO_NAME" = "ex-uio" ]; then
  ln -sf /dev/"$MDEV" /dev/ex-uio
fi
