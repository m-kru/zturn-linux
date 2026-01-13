#!/usr/bin/env bash

set -eu

function help_help() {
	printf \
"Firmware commands:
  setup-buildroot  Setup buildroot for work.
Gateware commands:
  gw  Build gateware.
Other commands:
  cp-bootbin  Copy boot.bin to the provided partition.
  bootbin     Generate boot.bin file.
  help        Print help message.
"
}

function help_cp_bootbin() {
	printf "cp-bootbin partition

Copies build/boot.bin to the provided partition.
The command automatically mounts and unmounts the partition using the pmount command.\n"
}

function help_setup_buildroot() {
	printf \
"Sets up buildroot for Linux and rootfs compilation in the build directory.
The command automatically links .config to the valid configuration.
The command does not start any compilation implicitly.
You must explicitly cd to the buildroot diretory and call make.\n"
}

function help_cmd() {
	if [ $# -eq 0 ]; then
		help_help
		return
	fi

	case $1 in
	"cp-bootbin")
		help_cp_bootbin
		;;
	"help")
		help_help
		;;
	"setup-buildroot")
		help_setup_buildroot
		;;
	*)
		printf "no extended help message command '%s'\n" "$1"
		exit 1
		;;
	esac
}

function cp_bootbin() {
	if [ $# -lt 1 ]; then
		printf "missing partition argument\n"
		exit 1
	fi
	readonly part=$1
	pmount "/dev/$part"
	cp build/boot.bin "/media/$part"
	pumount "/dev/$part"
}

# Start of script logic

if [ $# -lt 1 ]; then
	help_help
	exit 1
fi

cmd=$1
shift

case $cmd in
"cp-bootbin")
	cp_bootbin "$@"
	;;
"bootbin")
	bootgen -arch zynq -image config/zturn.bif -w on -o build/boot.bin
	;;
"gw")
	hbs run zturn::top
	;;
"help")
	help_cmd "$@"
	;;
"setup-buildroot")
	./scripts/setup-buildroot.sh
	;;
*)
	printf "invalid command '%s'\n" "$cmd"
	exit 1
	;;
esac
