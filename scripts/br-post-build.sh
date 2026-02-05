#!/usr/bin/env bash

# $1 is the path to the target filesystem (e.g., buildroot/output/target)

# Append  UIO rule to the end of the existing mdev.conf
if ! grep -q "ex-uio" "$1/etc/mdev.conf"; then
  echo "uio[0-9]* root:root 660 @/etc/ex-uio.sh" >> "$1/etc/mdev.conf"
fi
