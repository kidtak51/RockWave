######################################################################
# Project: StateMachine
# File Created: 2019/01/21 24:46
# Author: Takuya Shono ( ta.shono+1@gmail.com )
######
# Last Modified: 2019/01/21 24:47
# Modified By: Takuya Shono ( ta.shono+1@gmail.com )
######
# Copyright 2018 - 2019  Project StateMachine
######################################################################
# Description:
# 
######################################################################

testbench =statemachine_tb
testmodule =../../../HDL_SRC/CORE/StateMachine/statemachine.v 

INCDIR = ../../../HDL_SRC/CORE/

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule)
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 

