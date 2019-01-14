######################################################################
# Project: RockWave
# File Created: 2019/01/14 08:24
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/01/14 10:49
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project RockWave
######################################################################
# Description:
#    Test for Common module
######################################################################

##### Synchronizer
# testbench = synchronizer_tb
# testmodule = ../../HDL_SRC/Common/synchronizer.v

##### Refclk
testbench = refclk_tb
testmodule = ../../HDL_SRC/Common/refclk.v

INCDIR = ../../HDL_SRC/CORE/

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule)
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 
