ENTRY(_start)

MEMORY {
  DATA (rwx) : ORIGIN = 0x00000000, LENGTH = 20K
}

SECTIONS {
  .text : {
    *(.text._start) /* Ensure _start at 0x0 */
    *(.text*)
    *(.rodata*) 

    . = ALIGN(4);
    _etext = .;
  } > DATA

  .data : {
    . = ALIGN(4);
    _sdata = .;

    *(.data*)

    . = ALIGN(4);
    _edata = .;
  } > DATA

  .bss : {
    . = ALIGN(4);
    _sbss = .;

    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;
  } > DATA

  _end = .;
  __stack_top = ORIGIN(DATA) + LENGTH(DATA);
}
