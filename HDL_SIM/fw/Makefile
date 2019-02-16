######################################################################
# Project: core_tb
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2019/02/05 21:41
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2018  Project top_core
######################################################################
# Description:
# 
######################################################################

SRCDIR = ../../HDL_SRC/CORE/
testbench = core_tb.v
allVerilogFiles := $(wildcard $(SRCDIR)*/*.v)#
hexFiles := $(wildcard *.hex)#

all: wave
iverilog: wave

define F
	iverilog -o $(1).test -I $(SRCDIR) -D INST_ROM_FILE_NAME=\"$(1)\" $(testbench) $(allVerilogFiles)

	vvp $(1).test>>allResult_tmp.txt

endef

wave:
	$(foreach x,$(hexFiles),$(call F,$(x)))
	grep result allResult_tmp.txt>allResult.txt
	rm allResult_tmp.txt
