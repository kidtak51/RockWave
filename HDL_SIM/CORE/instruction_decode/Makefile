######################################################################
# Project: instruction_decode
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2018/12/19 12:12
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2018  Project instruction_decode
######################################################################
# Description:
# 
######################################################################

INCDIR = ../../../HDL_SRC/CORE/
testbench = instruction_decode_tb
testmodule = ../../../HDL_SRC/CORE/instruction_decode/instruction_decode.v

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule)
	vvp $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 
