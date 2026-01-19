# RGB LED
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports led_red_o]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports led_green_o]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports led_blue_o]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports led_blue_o]

# Swtiches
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports switches_i[0]]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports switches_i[1]]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports switches_i[2]]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports switches_i[3]]
