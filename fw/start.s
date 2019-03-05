	.section	.text.init	;
	.align 6
	.global _start		;
_start:
# Set Stack Pointer
	la sp,_estack

# Clear bss section
	la a0, __bss_start
	la a1, _end
	bgeu a0, a1, clearend
loop:
	sw zero, (a0)
	addi a0, a0, 4
	bltu a0, a1, loop
clearend:
	j main
	
