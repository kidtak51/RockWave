######################################################################
# Project: RockWave
# File Created: 2019/02/17 07:27
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/03/16 10:12
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2019  Project RockWave
######################################################################
# Description:
# 
######################################################################
target = vga

all:
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c $(target).c -o $(target).o
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c start.s -o start.o
	riscv64-unknown-elf-gcc -T link.ld -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -o $(target) start.o $(target).o
	riscv64-unknown-elf-objcopy -O binary $(target) night.bin
	riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data $(target) > night.dump
	hexdump -v -e '1/4 "%08x" "\n"' night.bin > night.hex
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > night.coe;hexdump -v -e '1/4 "%08x" ",\n"' night.bin >> night.coe ; echo "00000000" >> night.coe;
	
