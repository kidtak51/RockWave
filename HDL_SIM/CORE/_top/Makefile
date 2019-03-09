######################################################################
# Project: top_core
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2019/03/05 04:43
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project top_core
######################################################################
# Description:
# 
######################################################################

testbench = top_zedboard_tb

SRCDIR = ../../../HDL_SRC/
INCDIR = ../../../HDL_SRC/CORE/

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))
TOPMODULE = ../../../SYNTH/Zedboard/top_zedboard.v

all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(INCDIR) $(testbench).v $(allVerilogFiles) $(TOPMODULE)
	vvp $(testbench).test

wave:
	gtkwave *.vcd $(testbench).test.gtkw -a $(testbench).test.gtkw
