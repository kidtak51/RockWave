######################################################################
# Project: WriteBack
# File Created: 2019/01/23 12:29
# Author: Takuya Shono ( ta.shono+1@gmail.com )
######
# Last Modified: 2019/01/23 12:29
# Modified By: Takuya Shono ( ta.shono+1@gmail.com )
######
# Copyright 2018 - 2019  Project WriteBack
######################################################################
# Description:test writeback
# 
######################################################################

testbench =writeback_tb
testmodule1 =../../../HDL_SRC/CORE/WriteBack/writeback.v 

INCDIR = ../../../HDL_SRC/CORE/

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule1) 
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 

