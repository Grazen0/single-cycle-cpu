ENTRY(_start)

MEMORY {
  INSTR (rx) : ORIGIN = 0x00000000, LENGTH = 20K
  DATA  (rw) : ORIGIN = 0x00000000, LENGTH = 20K
}

SECTIONS {
  . = 0x00000000;

  .text : {
    *(.text._start) /* Ensure _start at 0x0 */
    *(.text*)
    _etext = .;
  } > INSTR

  . = _etext;

  .data : AT(ORIGIN(INSTR) + LENGTH(INSTR)) {
    _sdata = .;

    *(.rodata*) 
    . = ALIGN(4);
    *(.data*)

    . = ALIGN(4);
    _edata = .;
    _sbss = .;

    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;
  } > DATA

  _end = .;
  __stack_top = ORIGIN(DATA) + LENGTH(DATA);
}
