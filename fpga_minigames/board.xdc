## EDGE Artix-7 FPGA Development Board (XC7A35T-1FTG256C)
## Vivado part: xc7a35tftg256-1
## Pin assignments based on the EDGE Artix 7 Master XDC, rev 2.1.

## Configuration bank voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## 50 MHz oscillator (Y2)
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports {clk}]

## Slide switches. sw[0] is the rightmost physical switch.
set_property -dict { PACKAGE_PIN L5 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]  ;# SW3
set_property -dict { PACKAGE_PIN L4 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]  ;# SW4
set_property -dict { PACKAGE_PIN M4 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]  ;# SW5
set_property -dict { PACKAGE_PIN M2 IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]  ;# SW6
set_property -dict { PACKAGE_PIN M1 IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]  ;# SW7
set_property -dict { PACKAGE_PIN N3 IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]  ;# SW8
set_property -dict { PACKAGE_PIN N2 IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]  ;# SW9
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]  ;# SW10
set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]  ;# SW11
set_property -dict { PACKAGE_PIN P4 IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]  ;# SW12
set_property -dict { PACKAGE_PIN T8 IOSTANDARD LVCMOS33 } [get_ports {sw[10]}] ;# SW13
set_property -dict { PACKAGE_PIN R8 IOSTANDARD LVCMOS33 } [get_ports {sw[11]}] ;# SW15

## Push buttons (pressed = logic 1). btn[4] is the center button/reset.
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {btn[0]}] ;# Top
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {btn[1]}] ;# Bottom
set_property -dict { PACKAGE_PIN M12 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {btn[2]}] ;# Left
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {btn[3]}] ;# Right
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {btn[4]}] ;# Center

## User LEDs (logic 1 = on)
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]  ;# D3
set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]  ;# D4
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]  ;# D5
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]  ;# D6
set_property -dict { PACKAGE_PIN L3 IOSTANDARD LVCMOS33 } [get_ports {led[4]}]  ;# D8
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } [get_ports {led[5]}]  ;# D9
set_property -dict { PACKAGE_PIN K3 IOSTANDARD LVCMOS33 } [get_ports {led[6]}]  ;# D10
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports {led[7]}]  ;# D11
set_property -dict { PACKAGE_PIN K5 IOSTANDARD LVCMOS33 } [get_ports {led[8]}]  ;# D12
set_property -dict { PACKAGE_PIN P6 IOSTANDARD LVCMOS33 } [get_ports {led[9]}]  ;# D13
set_property -dict { PACKAGE_PIN R7 IOSTANDARD LVCMOS33 } [get_ports {led[10]}] ;# D14
set_property -dict { PACKAGE_PIN R6 IOSTANDARD LVCMOS33 } [get_ports {led[11]}] ;# D15

## Seven-segment display: seg[0]=A through seg[6]=G; segment outputs are active low.
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}] ;# A
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}] ;# B
set_property -dict { PACKAGE_PIN H5 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}] ;# C
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}] ;# D
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}] ;# E
set_property -dict { PACKAGE_PIN J4 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}] ;# F
set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}] ;# G

## Digit enables are active high. an[0] is the rightmost digit.
set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS33 } [get_ports {an[0]}] ;# DISP4, rightmost
set_property -dict { PACKAGE_PIN G5 IOSTANDARD LVCMOS33 } [get_ports {an[1]}] ;# DISP3
set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVCMOS33 } [get_ports {an[2]}] ;# DISP2
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVCMOS33 } [get_ports {an[3]}] ;# DISP1, leftmost

## On-board buzzer (enable jumper J12 on pins 1-2)
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS33 } [get_ports {buzzer}]
