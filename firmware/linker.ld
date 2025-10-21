ENTRY(_start)

MEMORY {
  INSTR (rx) : ORIGIN = 0x00000000, LENGTH = 1024
  DATA  (rw) : ORIGIN = 0x00000000, LENGTH = 1024
}

SECTIONS {
  .text : {
    *(.text._start) /* Ensure _start at 0x0 */
    *(.text*)

    . = ALIGN(4);
    _etext = .;
  } > INSTR

  .data : AT(ORIGIN(.text) + SIZEOF(.text)) {
    _srodata = .;

    *(.rodata*) 

    _erodata = .;
    . = ALIGN(4);
    _sdata = .;

    *(.data*)

    ._edata = .;
    . = ALIGN(4);
    ._sbss = .;

    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;
  } > DATA

  __stack_top = ORIGIN(DATA) + LENGTH(DATA);
}
