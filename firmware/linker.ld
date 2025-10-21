ENTRY(_start)

PHDRS {
  text PT_LOAD FLAGS(5); /* rx */
  data PT_LOAD FLAGS(6); /* rw */
}

SECTIONS {
  .text : {
    *(.text*)
    *(.rodata*) 
  } :text

  .data : {
    *(.data*)
  } :data

  .bss : {
    *(.bss*)
    *(COMMON)
  } :data
}
