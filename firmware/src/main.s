.section .text._start
.global _start

_start:
    li      sp, 1024
    call    start

1:
    j       1b
