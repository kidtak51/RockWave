######################################################################
# Project: RockWave
# File Created: 2019/01/14 08:24
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/01/27 07:06
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project RockWave
######################################################################
# Description:
#    Test for Common module
######################################################################

INCDIR = ../../HDL_SRC/CORE/
SRCDIR = ../../HDL_SRC/Common/

##### Synchronizer
# testbench = synchronizer_tb
# testmodule = ../../HDL_SRC/Board_Common/synchronizer.v

##### Refclk
# testbench = refclk_tb
# testmodule = ../../HDL_SRC/Board_Common/refclk.v

##### dfilter
testbench = dfilter_tb

##### dfilter
# testbench = register_tb
allVerilogFiles := $(wildcard $(SRCDIR)*.v)#
##### rst
 testbench = rst_tb
 testmodule = ../../HDL_SRC/Board_Common/rst.v

INCDIR = ../../HDL_SRC/CORE/



all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(allVerilogFiles)
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 


