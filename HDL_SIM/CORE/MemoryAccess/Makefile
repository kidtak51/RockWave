######################################################################
# Project: RockWave
# File Created: 2018/11/25 06:07
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/01/06 05:28
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project RockWave
######################################################################
# Description:
#    TestBench for top_memoryaccess
######################################################################

# testbench = ram_tb
# testmodule = ../../../HDL_SRC/CORE/MemoryAccess/ram.v

# testbench = memoryaccess_tb
# testmodule = ../../../HDL_SRC/CORE/MemoryAccess/top_memoryaccess.v

testbench = top_memoryaccess_tb
testmodule = ../../../HDL_SRC/CORE/MemoryAccess/top_memoryaccess.v ../../../HDL_SRC/CORE/MemoryAccess/ram.v

INCDIR = ../../../HDL_SRC/CORE/

all: iverilog wave

iverilog:
	iverilog -o $(testbench) -I $(INCDIR) $(testbench).v $(testmodule)
	vvp $(testbench)
	rm $(testbench)

wave:
	gtkwave *.vcd $(testbench).gtkw -a $(testbench).gtkw 
