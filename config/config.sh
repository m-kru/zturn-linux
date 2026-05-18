# shellcheck shell=bash

#
# Project constant variables
#

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

#
# User configuration variables
#

BUILD_DIR="$PROJECT_DIR/build"

CACHE_DIR="$PROJECT_DIR/cache"

BUILDROOT_URL="https://gitlab.com/buildroot.org/buildroot/"
# Buildroot branch or tag name to be downloaded.
BUILDROOT_BRANCH=2026.02.1
BUILDROOT_DIR_NAME=buildroot

LINUX_URL="org-3189299@github.com:Xilinx/linux-xlnx.git"
# Linux branch or tag name to be downloaded.
LINUX_BRANCH=xlnx_rebase_v6.6_LTS
# The value of the LINUX_DIR_NAME must match the name of the directory downloaded from the LINUX_URL.
LINUX_DIR_NAME=linux-xlnx

UBOOT_URL="https://github.com/u-boot/u-boot"
# U-boot branch or tag name to be downloaded.
UBOOT_BRANCH=v2026.04
UBOOT_DIR_NAME=u-boot

#
# Derived variables
#

BUILDROOT_DIR="$BUILD_DIR/$BUILDROOT_DIR_NAME"

# The variable name is KERNELDIR, not KDIR or KERNEL_DIR, to keep compatibility with Buildroot.
KERNELDIR="$BUILD_DIR/$LINUX_DIR_NAME"

UBOOT_DIR="$BUILD_DIR/$UBOOT_DIR_NAME"
