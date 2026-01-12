#!/usr/bin/env bash

set -e

printHelp() {
	printf \
"Firmware commands:
  setup-buildroot  Setup buildroot for work
Gateware commands:
  gw  Build gateware.
Other commands:
  boot-bin  Generate boot.bin file.
  help      Print help message.
"
}

if [ $# -lt 1 ]; then
	printHelp
	exit 1
fi

cmd=$1
shift

case $cmd in
"boot-bin")
	bootgen -arch zynq -image config/zturn.bif -w on -o build/boot.bin
	;;
"gw")
	hbs run zturn::top
	;;
"help")
	printHelp
	;;
"setup-buildroot")
	./scripts/setup-buildroot.sh
	;;
*)
	printf "invalid command '%s'\n" "$cmd"
	exit 1
	;;
esac
