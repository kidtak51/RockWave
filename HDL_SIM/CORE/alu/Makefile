######################################################################
# Project: RockWave
# File Created: 2018/11/25 06:07
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/01/14 15:58
# Modified By: Takuya Shono ( ta.shono+1@gmail.com )
######
# Copyright 2018 - 2018  Project RockWave
######################################################################
# Description:
#    TestBench for alu_tb
######################################################################

testbench = alu_tb
testmodule = ../../../HDL_SRC/CORE/alu/alu.v

INCDIR = ../../../HDL_SRC/CORE/

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule)
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 
