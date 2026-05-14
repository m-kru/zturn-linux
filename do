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


HELP["gw-rm"]="Remove $BUILD_DIR/gw directory."
gw_rm() {
  rm -rf "$BUILD_DIR/gw"
}


HELP["bootbin"]="Generate boot.bin file to the $BUILD_DIR directory."
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


HELP["br"]="Cd to Buildroot directory and execute args.
\nUsage:
  ./do br args

If the Buildroot directory does not exist, it first calls the 'br-setup' command."
br() {
  if [ $# -lt 1 ]; then
    die "missing args, check './do help br'"
  fi

  if [ ! -d "./$BUILD_DIR/buildroot-$BUILDROOT_VERSION" ]; then
    br_setup
  fi

  cd "$BUILD_DIR/buildroot-$BUILDROOT_VERSION"
  "$@"

  cd "$PROJECT_DIR"
}


HELP["br-setup"]="Set up Buildroot for rootfs compilation in the $BUILD_DIR directory.
\nThe command automatically links .config to the valid configuration.
The command does not start any compilation implicitly.
You must explicitly cd to the Buildroot diretory and call make."
br_setup() {
  local buildroot_tar="buildroot-$BUILDROOT_VERSION.tar.gz"
  local buildroot_dir="buildroot-$BUILDROOT_VERSION"

  mkdir -p cache
  cd cache
  if [ ! -e "$buildroot_tar" ]; then
    wget "https://buildroot.org/downloads/$buildroot_tar"
  fi
  cd ..

  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"

  if [ ! -d "$buildroot_dir" ]; then
    tar -xvf "../cache/$buildroot_tar"
  fi

  cd "$buildroot_dir"
  BR2_EXTERNAL=../../br BR2_DEFCONFIG=../../config/buildroot.conf make defconfig

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
  if [ $# -lt 1 ]; then
    die "missing args, check './do help linux'"
  fi

  if [ ! -d "$BUILD_DIR/$LINUX_DIR" ]; then
    linux_setup
  fi

  cd "$BUILD_DIR/$LINUX_DIR"
  # shellcheck source=/dev/null
  source ../../scripts/linux-setup-env.sh
  "$@"

  cd "$PROJECT_DIR"
}


HELP["linux-update-defconfig"]="Update Linux default configuration file (./config/linux.conf).
The command runs 'make savedefconfig' in the Linux directory, and copies the defconfig file to the ./config directory."
linux_update_defconfig() {
  cd "$BUILD_DIR/$LINUX_DIR"
  make savedefconfig
  cp defconfig ../../config/linux.conf
  cd "$PROJECT_DIR"
}

HELP["linux-setup"]="Set up Linux for compilation in the $BUILD_DIR directory.
The command does not start any compilation implicitly.
You must explicitly cd to the linux diretory and call make."
linux_setup() {
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  git clone --branch "$LINUX_BRANCH" --depth 1 "$LINUX_URL"

  # Attach project related drivers
  cd "$LINUX_DIR/drivers"
  ln -s ../../../fw/examples/drivers/ zturn
  sed -i '2a source "drivers/zturn/Kconfig"' Kconfig
  echo "obj-y += zturn/" >> Makefile

  cd ..
  # shellcheck source=/dev/null
  source ../../scripts/linux-setup-env.sh
  make xilinx_zynq_defconfig
  ./scripts/kconfig/merge_config.sh .config ../../config/linux.conf

  cd "$PROJECT_DIR"
}

HELP["linux-mods-install"]="Install Linux modules to the Buildroot overlay directory.
The command does not trigger modules (re)compilation process."
linux_mods_install() {
  cd "$BUILD_DIR/$LINUX_DIR"

  INSTALL_MOD_PATH="$PROJECT_DIR/br/overlay" make modules_install

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
