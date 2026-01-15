#!/usr/bin/env bash

set -eu

#
# Configuration variables
#

BUILDROOT_VERSION=2025.02.9

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
declare -A COMMAND


HELP["help"]="Print help message."
COMMAND["help"]="help"

help() {
  if [ $# -eq 0 ]; then
    printf "Usage:\n  %s <command> [args]\n\nAvailable commands:\n" "$0"

    local tmp=""
    for cmd in "${!COMMAND[@]}"; do
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


HELP["gw"]="Build gateware."
COMMAND["gw"]="gw"

gw() {
  hbs run zturn::top
}


HELP["gw-rm"]="Remove build/gw directory."
COMMAND["gw-rm"]="gw_rm"

gw_rm() {
  rm -rf build/gw
}


HELP["bootbin"]="Generate boot.bin file to the build directory."
COMMAND["bootbin"]="bootbin"

bootbin() {
  bootgen -arch zynq -image config/zturn.bif -w on -o build/boot.bin
}


HELP["bootbin-cp"]="Copy build/boot.bin to the provided partition.
\nUsage:
  ./do bootbin-cp partition\n
The command automatically mounts and unmounts the partition using the pmount command."
COMMAND["bootbin-cp"]="bootbin_cp"

bootbin_cp() {
  if [ $# -lt 1 ]; then
    die "missing partition argument"
  fi

  readonly part=$1
  pmount "/dev/$part"
  cp build/boot.bin "/media/$part"
  pumount "/dev/$part"
}


HELP["buildroot-setup"]="Set up buildroot for Linux and rootfs compilation in the build directory.
\nThe command automatically links .config to the valid configuration.
The command does not start any compilation implicitly.
You must explicitly cd to the buildroot diretory and call make."
COMMAND["buildroot-setup"]="buildroot_setup"

buildroot_setup() {
  local buildroot_tar="buildroot-$BUILDROOT_VERSION.tar.gz"
  local buildroot_dir="buildroot-$BUILDROOT_VERSION"

  mkdir -p cache
  cd cache
  if [ ! -e $buildroot_tar ]; then
    wget "https://buildroot.org/downloads/$buildroot_tar"
  fi
  cd ..

  mkdir -p build
  cd build
  if [ ! -d $buildroot_dir ]; then
    tar -xvf ../cache/$buildroot_tar
  fi

  cd $buildroot_dir
  ln -s -f ../../config/buildroot .config
}

HELP["git-rm-ignored"]="Remove only files ignored by git.
\nUsage:
  ./do git-rm-ignored [args]\n
The args are simply forwarded to the 'git clean -fdX' command."
COMMAND["git-rm-ignored"]="git_rm_ignored"

git_rm_ignored() {
  git clean -fdX "$@"
}

HELP["bootscr"]="Compile boot script for U-Boot."
COMMAND["bootscr"]="bootscr"

bootscr() {
  mkdir -p build
  mkimage -A arm -T script -C none -n 'Start script' -d fw/boot/boot.txt build/boot.scr
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

if [[ ! -v COMMAND["$cmd"] ]]; then
  die "invalid command '$cmd'"
fi

"${COMMAND[$cmd]}" "$@"
