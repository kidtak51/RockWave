######################################################################
# Project: RockWave
# File Created: 2018/11/25 06:07
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/02/12 06:52
# Modified By: Takuya Shono ( ta.shono+1@gmail.com )
######
# Copyright 2018 - 2018  Project RockWave
######################################################################
# Description:
#    TestBench for top_execute_tb
######################################################################

testbench =top_execute_tb
testmodule1 =../../../HDL_SRC/CORE/Execute/top_execute.v 
testmodule2 =../../../HDL_SRC/CORE/Execute/alu.v
testmodule3 =../../../HDL_SRC/CORE/Execute/comp.v

#testbench = alu_tb
#testmodule = ../../../HDL_SRC/CORE/Execute/alu.v

#testbench = comp_tb
#testmodule1 = ../../../HDL_SRC/CORE/Execute/comp.v

INCDIR = ../../../HDL_SRC/CORE/

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule1) $(testmodule2) $(testmodule3)
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 

