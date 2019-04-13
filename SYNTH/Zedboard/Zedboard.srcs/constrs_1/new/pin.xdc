set_property PACKAGE_PIN Y9 [get_ports clk]
# GPIO
set_property PACKAGE_PIN T22 [get_ports {gpio_pin_out[0]}]; # LD0
set_property PACKAGE_PIN T21 [get_ports {gpio_pin_out[1]}]
set_property PACKAGE_PIN U22 [get_ports {gpio_pin_out[2]}]
set_property PACKAGE_PIN U21 [get_ports {gpio_pin_out[3]}]
set_property PACKAGE_PIN V22 [get_ports {gpio_pin_out[4]}]
set_property PACKAGE_PIN W22 [get_ports {gpio_pin_out[5]}]
set_property PACKAGE_PIN U19 [get_ports {gpio_pin_out[6]}]
set_property PACKAGE_PIN U14 [get_ports {gpio_pin_out[7]}]; # LD7
set_property PACKAGE_PIN F22 [get_ports {gpio_pin_in[0]}];  # SW0
set_property PACKAGE_PIN G22 [get_ports {gpio_pin_in[1]}];  # SW1
set_property PACKAGE_PIN H22 [get_ports {gpio_pin_in[2]}];  # SW2
set_property PACKAGE_PIN F21 [get_ports {gpio_pin_in[3]}];  # SW3
set_property PACKAGE_PIN H19 [get_ports {gpio_pin_in[4]}];  # SW4
set_property PACKAGE_PIN H18 [get_ports {gpio_pin_in[5]}];  # SW5
set_property PACKAGE_PIN H17 [get_ports {gpio_pin_in[6]}];  # SW6
set_property PACKAGE_PIN M15 [get_ports {gpio_pin_in[7]}];  # SW7
set_property PACKAGE_PIN T18 [get_ports {gpio_pin_in[8]}];  # BTNU
set_property PACKAGE_PIN P16 [get_ports {gpio_pin_in[9]}];  # BTNC
set_property PACKAGE_PIN N15 [get_ports {gpio_pin_in[10]}]; # BTNL
set_property PACKAGE_PIN R16 [get_ports {gpio_pin_in[11]}]; # BTND
set_property PACKAGE_PIN R18 [get_ports {gpio_pin_in[12]}]; # BTNR

# VGA
set_property PACKAGE_PIN AA19 [get_ports hsync];
set_property PACKAGE_PIN Y19  [get_ports vsync];
set_property PACKAGE_PIN V20  [get_ports {rdata[0]}];
set_property PACKAGE_PIN U20  [get_ports {rdata[1]}];
set_property PACKAGE_PIN V19  [get_ports {rdata[2]}];
set_property PACKAGE_PIN V18  [get_ports {rdata[3]}];
set_property PACKAGE_PIN AB22 [get_ports {gdata[0]}];
set_property PACKAGE_PIN AA22 [get_ports {gdata[1]}];
set_property PACKAGE_PIN AB21 [get_ports {gdata[2]}];
set_property PACKAGE_PIN AA21 [get_ports {gdata[3]}];
set_property PACKAGE_PIN Y21  [get_ports {bdata[0]}];
set_property PACKAGE_PIN Y20  [get_ports {bdata[1]}];
set_property PACKAGE_PIN AB20 [get_ports {bdata[2]}];
set_property PACKAGE_PIN AB19 [get_ports {bdata[3]}];


set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports rdata]
set_property IOSTANDARD LVCMOS33 [get_ports gdata]
set_property IOSTANDARD LVCMOS33 [get_ports bdata]
set_property IOSTANDARD LVCMOS33 [get_ports gpio_pin_out]
set_property IOSTANDARD LVCMOS25 [get_ports gpio_pin_in]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_false_path -through localbus/rst_n -through U_top_vgacontroller/rst_n
