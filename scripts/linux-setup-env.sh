# shellcheck shell=bash

export ARCH=arm
export CROSS_COMPILE=arm-none-linux-gnueabihf-
export PATH=/opt/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-linux-gnueabihf/bin:$PATH

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# shellcheck source=/dev/null
source "$(dirname "$SCRIPT_DIR")/config/config.sh"

export "KERNELDIR=$KERNELDIR"
