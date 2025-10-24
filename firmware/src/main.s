.section .text._start
.global _start

_start:
    la      sp, 0x31B14
    call    start
1:
    j       1b
