#!/usr/bin/env bash

set -eu

# shellcheck source=/dev/null
source ./config/config.sh

#
# Utility functions
#

die() {
  echo >&2 "$*"
  exit 1
}

#
# Commands
#

declare -A HELP


HELP["help"]="Print help message."
help() {
  if [ $# -eq 0 ]; then
    printf "Usage:\n  %s <command> [args]\n\nAvailable commands:\n" "$0"

    local tmp=""
    for cmd in "${!HELP[@]}"; do
      local help=${HELP[$cmd]}
      read -r help <<< "$help"
      tmp+="  $cmd!$help"$'\n'
    done

    tmp=$(column -s "!" -t <<< "$tmp" | sort -k1,1)
    echo "$tmp"

    return
  fi

  readonly cmd=$1
  if [[ ! -v HELP["$cmd"] ]]; then
    die "invalid command '$cmd'"
  fi

  printf "%b\n" "${HELP["$cmd"]}"
}


HELP["dtso"]="Generate DTS overlay."
dtso() {
  ./scripts/dts-gen.py "$BUILD_DIR/afbd/reg.json" > "$BUILD_DIR/system.dtso"
}


HELP["dtbo"]="Compile DTS overlay."
dtbo() {
  dtc -@ -I dts -O dtb -o "$BUILD_DIR/system.dtbo" "$BUILD_DIR/system.dtso"
}


HELP["gw"]="Build gateware."
gw() {
  hbs run zturn::top
}


HELP["gw-rm"]="Remove \$BUILD_DIR/gw directory."
gw_rm() {
  rm -rf "$BUILD_DIR/gw"
}


HELP["bootbin"]="Generate boot.bin file to the \$BUILD_DIR directory."
bootbin() {
  bootgen -arch zynq -image config/zturn.bif -w on -o "$BUILD_DIR/boot.bin"
}


HELP["sd-cp"]="Copy provided file to the provided SD card partition.
\nUsage:
  ./do sd-cp args partition\n
The command automatically mounts and unmounts the partition using the pmount command.
The args are passed as is to the cp command.

Example:
  do sd-cp $BUILD_DIR/boot.bin sda1"
sd_cp() {
  if [ $# -lt 1 ]; then
    die "missing partition argument"
  fi

  readonly part=${!#}
  pmount "/dev/$part"
  set -- "${@:1:$#-1}"
  cp "$@" "/media/$part"
  pumount "/dev/$part"
}


HELP["sd-cp-all"]="Copy all required files to the provided SD card partition.
\nUsage:
  ./do sd-cp args partition\n
The command automatically mounts and unmounts the partition using the pmount command.
The args are passed as is to the cp command.

Example:
  do sd-cp-all $BUILD_DIR/boot.bin sda1"
sd_cp_all() {
  if [ $# -lt 1 ]; then
    die "missing partition argument"
  fi

  readonly part=${!#}
  pmount "/dev/$part"
  set -- "${@:1:$#-1}"

  cp "$@" "$BUILD_DIR/boot.bin" "/media/$part"
  cp "$@" "$BUILD_DIR/boot.scr" "/media/$part"
  cp "$@" "$BUILD_DIR/system.dtbo" "/media/$part"

  cp "$@" "$KERNELDIR/arch/arm/boot/zImage" "/media/$part"
  cp "$@" "$KERNELDIR/arch/arm/boot/dts/xilinx/zynq-zturn-v5.dtb" "/media/$part"

  cp "$@" "$BUILDROOT_DIR/output/images/rootfs.cpio" "/media/$part"

  pumount "/dev/$part"
}




HELP["br"]="Cd to Buildroot directory and execute args.
\nUsage:
  ./do br args

If the Buildroot directory does not exist, it first calls the 'br-setup' command."
br() {
  if [ $# -lt 1 ]; then
    die "missing args, check './do help br'"
  fi

  if [ ! -d "$BUILDROOT_DIR" ]; then
    br_setup
  fi

  cd "$BUILDROOT_DIR"
  "$@"

  cd "$PROJECT_DIR"
}


HELP["br-setup"]="Set up Buildroot for rootfs compilation in the \$BUILD_DIR directory.
\nThe command automatically links .config to the valid configuration.
The command does not start any compilation implicitly.
You must explicitly cd to the Buildroot diretory and call make."
br_setup() {
  local url_branch_dir="${BUILDROOT_URL//\//_}/$BUILDROOT_BRANCH"

  mkdir -p "$CACHE_DIR"
  cd "$CACHE_DIR"
  if [ ! -e "$url_branch_dir/$BUILDROOT_DIR_NAME" ]; then
    mkdir -p "$url_branch_dir"
    cd "$url_branch_dir"
    git clone --branch "$BUILDROOT_BRANCH" --depth 1 "$BUILDROOT_URL"
  fi

  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  cp -r "$CACHE_DIR/$url_branch_dir/$BUILDROOT_DIR_NAME" .

  cd "$BUILDROOT_DIR_NAME"
  BR2_EXTERNAL="$PROJECT_DIR/br" BR2_DEFCONFIG="$PROJECT_DIR/config/buildroot.conf" make defconfig

  cd "$PROJECT_DIR"
}


HELP["git-rm-ignored"]="Remove only files ignored by git.
\nUsage:
  ./do git-rm-ignored [args]\n
The args are simply forwarded to the 'git clean -fdX' command."
git_rm_ignored() {
  git clean -fdX "$@"
}


HELP["bootscr"]="Compile boot script for U-Boot."
bootscr() {
  mkdir -p "$BUILD_DIR"
  mkimage -A arm -T script -C none -n 'Start script' -d fw/boot/boot.txt "$BUILD_DIR/boot.scr"
}


HELP["linux"]="Cd to Linux directory and execute args.
\nUsage:
  ./do linux args

The command sets up the Linux environment before executing args.
If the linux directory does not exist, it first calls the 'linux-setup' command."
linux() {
  if [ -z "${ARCH+x}" ]; then
    die "ARCH environment variable not set"
  fi

  if [ $# -lt 1 ]; then
    die "missing args, check './do help linux'"
  fi

  if [ ! -d "$KERNELDIR" ]; then
    linux_setup
  fi

  cd "$KERNELDIR"
  "$@"

  cd "$PROJECT_DIR"
}


HELP["linux-update-defconfig"]="Update Linux default configuration file (./config/kernel.conf).
The command runs 'make savedefconfig' in the Linux directory, and copies the defconfig file to the ./config directory."
linux_update_defconfig() {
  cd "$KERNELDIR"
  make savedefconfig
  cp defconfig "$PROJECT_DIR/config/kernel.conf"
  cd "$PROJECT_DIR"
}


HELP["linux-setup"]="Set up Linux for compilation in the \$BUILD_DIR directory.
The command does not start any compilation implicitly.
You must explicitly cd to the linux diretory and call make."
linux_setup() {
  local url_branch_dir="${LINUX_URL//\//_}/$LINUX_BRANCH"

  mkdir -p "$CACHE_DIR"
  cd "$CACHE_DIR"
  if [ ! -e "$url_branch_dir/$LINUX_DIR_NAME" ]; then
    mkdir -p "$url_branch_dir"
    cd "$url_branch_dir"
    git clone --branch "$LINUX_BRANCH" --depth 1 "$LINUX_URL"
  fi

  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  cp -r "$CACHE_DIR/$url_branch_dir/$LINUX_DIR_NAME" .

  # Attach project related drivers
  cd "$KERNELDIR/drivers"
  ln -s ../../../fw/examples/drivers/ zturn
  sed -i '2a source "drivers/zturn/Kconfig"' Kconfig
  echo "obj-y += zturn/" >> Makefile

  cd ..
  # shellcheck source=/dev/null
  source "$PROJECT_DIR/config/linux-env.sh"
  cp "$PROJECT_DIR/config/kernel.conf" .conf
  make olddefconfig

  cd "$PROJECT_DIR"
}


HELP["linux-mods-install"]="Install Linux modules to the Buildroot overlay directory.
The command does not trigger modules (re)compilation process."
linux_mods_install() {
  cd "$KERNELDIR"

  INSTALL_MOD_PATH="$PROJECT_DIR/br/overlay" make modules_install

  cd "$PROJECT_DIR"
}


HELP["uboot"]="Cd to U-Boot directory and execute args.
\nUsage:
  ./do uboot args

The command sets up the Linux (yes Linux) environment before executing args.
If the u-boot directory does not exist, it first calls the 'uboot-setup' command."
uboot() {
  if [ -z "${ARCH+x}" ]; then
    die "ARCH environment variable not set"
  fi

  if [ $# -lt 1 ]; then
    die "missing args, check './do help linux'"
  fi

  if [ ! -d "$UBOOT_DIR" ]; then
    uboot_setup
  fi

  cd "$BUILD_DIR/$UBOOT_DIR_NAME"
  # shellcheck source=/dev/null
  source "$PROJECT_DIR/config/linux-env.sh"
  "$@"

  cd "$PROJECT_DIR"
}



HELP["uboot-setup"]="Set up U-Boot for compilation in the \$BUILD_DIR directory.
The command does not start any compilation implicitly.
You must explicitly cd to the u-boot diretory and call make."
uboot_setup() {
  local url_branch_dir="${UBOOT_URL//\//_}/$UBOOT_BRANCH"

  mkdir -p "$CACHE_DIR"
  cd "$CACHE_DIR"
  if [ ! -e "$url_branch_dir/$UBOOT_DIR_NAME" ]; then
    mkdir -p "$url_branch_dir"
    cd "$url_branch_dir"
    git clone --branch "$UBOOT_BRANCH" --depth 1 "$UBOOT_URL"
  fi

  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  cp -r "$CACHE_DIR/$url_branch_dir/$UBOOT_DIR_NAME" .

  cd "$UBOOT_DIR_NAME"
  cp "$PROJECT_DIR/config/uboot.conf" .config
  make olddefconfig

  cd "$PROJECT_DIR"
}

#
# Start of script logic
#

if [ $# -lt 1 ]; then
  help "$@"
  exit 1
fi

cmd=$1
shift

if [[ ! -v HELP["$cmd"] ]]; then
  help
  exit 1
fi

readonly cmd_func="${cmd//-/_}"

if ! declare -F "$cmd_func" > /dev/null; then
  die "can't find function for command '$cmd'"
fi

$cmd_func "$@"
