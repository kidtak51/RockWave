######################################################################
# Project: top_core
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2019/01/24 21:46
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2018  Project top_core
######################################################################
# Description:
# 
######################################################################

SRCDIR = ../../../HDL_SRC/CORE/
testbench = top_core_tb.v
#testmodule0 = ./_top/top_core.v
#testmodule0 = ./core_general.vh
#testmodule1 = ./Fetch/top_fetch.v
#testmodule2 = ./instruction_decode/instruction_decode.v
#testmodule3 = ./MemoryAccess/top_memoryaccess.v
#testmodule4 = ./RegisterFile/register_file.v
#testmodule5 = ./StateMachine/statemachine.v
#testmodule6 = ./Execute/top_execute.v
testmodule7 = ./Execute/writeback.v
allVerilogFiles := $(wildcard $(SRCDIR)*/*.v)#


all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(SRCDIR) $(testbench) $(allVerilogFiles)
	vvp $(testbench).test

wave:
	gtkwave *.vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
