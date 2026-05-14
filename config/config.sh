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

BUILDROOT_VERSION=2026.02.1

LINUX_URL="org-3189299@github.com:Xilinx/linux-xlnx.git"
# Linux branch or tag name to be downloaded.
LINUX_BRANCH=xlnx_rebase_v6.6_LTS
# The value of the LINUX_DIR_NAME must match the name of the directory downloaded from the LINUX_URL.
LINUX_DIR_NAME=linux-xlnx

#
# Derived variables
#

# The variable name is KERNELDIR, not KDIR or KERNEL_DIR, to keep compatibility with Buildroot.
KERNELDIR="$BUILD_DIR/$LINUX_DIR_NAME"
