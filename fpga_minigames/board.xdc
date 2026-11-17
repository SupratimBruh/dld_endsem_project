## Template constraints. Replace every <PIN> with the pin from the EDGE Artix-7
## manual / schematic (package FTG256). I could not verify the pin numbers, so none are filled in.

## Clock (set period to match the oscillator: 50 MHz = 20.000 ns)
set_property PACKAGE_PIN <PIN> [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 20.000 -name sys_clk [get_ports clk]

## Slide switches sw[0]..sw[11]
# set_property PACKAGE_PIN <PIN> [get_ports {sw[0]}]
# ... repeat for sw[1] .. sw[11]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

## Push buttons btn[0]..btn[4]  (btn[4] = global reset)
# set_property PACKAGE_PIN <PIN> [get_ports {btn[0]}]
# ... repeat for btn[1] .. btn[4]
set_property IOSTANDARD LVCMOS33 [get_ports {btn[*]}]

## LEDs led[0]..led[11]  (delete unused ones from top.v if the board has fewer)
# set_property PACKAGE_PIN <PIN> [get_ports {led[0]}]
# ... repeat for led[1] .. led[11]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## 7-segment: seg[0]=a ... seg[6]=g ; an[0] = rightmost digit
# set_property PACKAGE_PIN <PIN> [get_ports {seg[0]}]
# ... repeat for seg[1] .. seg[6], an[0] .. an[3]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

## Buzzer
set_property PACKAGE_PIN <PIN> [get_ports buzzer]
set_property IOSTANDARD LVCMOS33 [get_ports buzzer]
