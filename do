#!/usr/bin/env bash

set -eu

die() {
  echo >&2 "$*"
  exit 1
}

help() { #doc: Print help message
  if [ $# -eq 0 ]; then
    printf "Usage:\n  %s <command> [args]\n\nAvailable commands:\n" "$0"
    LANG=en_US.UTF_8
    grep -E '^\w.+\(\) { #doc' "$0" \
      | sed -e 's|() { #doc: |!|g' \
      | sed -e 's|^|  |' \
      | column -s"!" -t
    return
  fi

  local cmd=${1//-/_}
  local cmd_help="${cmd}_help"

  if [[ ! -v $cmd_help ]]; then
    echo "no help for '$1'"
    return
  fi

  printf "%b" "${!cmd_help}"
}

# shellcheck disable=SC2034
gw_help="Builds gateware.\n"

gw() { #doc: Build gateware
  hbs run zturn::top
}

# shellcheck disable=SC2034
bootbin_help="Generates boot.bin file to the build directory.\n"

bootbin() { #doc: Generate boot.bin file
  bootgen -arch zynq -image config/zturn.bif -w on -o build/boot.bin
}

# shellcheck disable=SC2034
cp_bootbin_help="cp-bootbin partition\n
Copies build/boot.bin to the provided partition.
The command automatically mounts and unmounts the partition using the pmount command.\n"

cp_bootbin() { #doc: Copy build/boot.bin to the provided partition
  if [ $# -lt 1 ]; then
    die "missing partition argument"
  fi

  readonly part=$1
  pmount "/dev/$part"
  cp build/boot.bin "/media/$part"
  pumount "/dev/$part"
}

# shellcheck disable=SC2034
setup_buildroot_help="Sets up buildroot for Linux and rootfs compilation in the build directory.
The command automatically links .config to the valid configuration.
The command does not start any compilation implicitly.
You must explicitly cd to the buildroot diretory and call make.\n"

# Start of script logic

if [ $# -lt 1 ]; then
  help "$@"
  exit 1
fi

cmd=$1
shift

func="$cmd"
func=${func//-/_}

if ! declare -f "$func" > /dev/null; then
  die "invalid command '$cmd'"
fi

$func "$@"
