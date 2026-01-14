#!/usr/bin/env bash

set -eu

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


HELP["gw"]="Builds gateware."
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


HELP["bootbin-cp"]="Copy build/boot.bin to the provided partition.\n
Usage:
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


HELP["buildroot-setup"]="Sets up buildroot for Linux and rootfs compilation in the build directory.\n
The command automatically links .config to the valid configuration.
The command does not start any compilation implicitly.
You must explicitly cd to the buildroot diretory and call make."
COMMAND["buildroot-setup"]="buildroot_setup"

buildroot_setup() {
  scripts/setup-buildroot.sh
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
