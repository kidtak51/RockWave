OUTPUT_ARCH( "riscv" )
ENTRY(_start)

_estack = 0x90000FFF;

MEMORY {
    RAM  ( rw): ORIGIN = 0x90000000, LENGTH =  4K /* Data RAM Area */
    ROM  (xr ): ORIGIN = 0x80000000, LENGTH =  4K /* Inst ROM Area */
}
SECTIONS
{
  .text.init : { *(.text.init) } > ROM
  . = ALIGN(4);
  .tohost : { *(.tohost) } > ROM
  . = ALIGN(4);
  .text : { *(.text) } > ROM
  .data : { *(.data) }>RAM
  __bss_start = .;
  .bss : { *(.bss) }>RAM
  _end = .;
}

