set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

### This file is a general .xdc for the HBE200
### To use it in a project:
### - uncomment the lines corresponding to used pins
### - rename the used ports (in each line, after get_ports) according to the top level signal names in the project


## Clock Signal
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK100MHZ]


## LEDs
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports { led_calib }];
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports { led_pass }];
set_property -dict { PACKAGE_PIN W20 IOSTANDARD LVCMOS33 } [get_ports { led_fail }];


## Buttons
set_property -dict { PACKAGE_PIN T6 IOSTANDARD LVCMOS33 } [get_ports { fpga_rst }];
set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS33 } [get_ports { mcu_rst }];


## UART
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { uart0_txd }];
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { uart0_rxd }];
