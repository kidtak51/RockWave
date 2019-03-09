######################################################################
# Project: GPIO
# File Created: 2019/01/31 05:21
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/03/03 12:18
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2019  Project GPIO
######################################################################
# Description:
# 
######################################################################

testbench = top_gpio_tb

SRCDIR = ../../../HDL_SRC/
INCDIR = ../../../HDL_SRC/CORE/

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))#


all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(INCDIR) $(testbench).v $(allVerilogFiles)
	vvp -N $(testbench).test
	rm $(testbench).test

wave:
	gtkwave *.vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
