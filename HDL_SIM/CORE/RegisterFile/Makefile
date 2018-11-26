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

testbench = reg_rw_tb
testmodule = ../../../HDL_SRC/CORE/RegisterFile/reg_rw.v


$(testbench): $(testbench).v $(testmodule)
	iverilog -o $(testbench) $(testbench).v $(testmodule)
	vvp $(testbench)
