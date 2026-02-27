# External 10 MHz clock
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports ext_clk_10_i]
create_clock -period 100.01 -name ext_clk_10_i -waveform {0.00 50.00} -add [get_ports ext_clk_10_i]

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

# UART
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports uart_tx_o]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports uart_rx_i]
