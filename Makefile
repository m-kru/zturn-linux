default: help

.PHONY: help
help:
	@echo "Firmware targets:"
	@echo "  setup-buildroot  Setup buildroot for work"
	@echo "Gateware targets:"
	@echo "  gw  Build gateware."
	@echo "Other targets:"
	@echo "  boot-bin  Generate boot.bin file."
	@echo "  help      Print help message."

# Firmware targets

.PHONY: setup-buildroot
setup-buildroot:
	./scripts/setup-buildroot.sh

# Gateware targets

.PHONY: gw
gw:
	hbs run zturn::top

# Other targets:

.PHONY: boot-bin
boot-bin:
	bootgen -arch zynq -image config/zturn.bif -w on -o build/boot.bin
