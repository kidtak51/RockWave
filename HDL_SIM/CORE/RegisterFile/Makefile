######################################################################
# Project: RockWave
# File Created: 2018/11/25 06:07
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2018/11/27 04:08
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project RockWave
######################################################################
# Description:
#    TestBench for reg_rw
######################################################################

INCDIR = ../../../HDL_SRC/CORE/
SRCDIR = ../../../HDL_SRC/CORE/RegisterFile
testbench = register_file_tb
testmodule = $(SRCDIR)/register_file.v $(SRCDIR)/reg_rw.v 

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule)
	vvp $(testbench)
	rm  $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 
