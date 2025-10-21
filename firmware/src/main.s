.section .text._start
.global _start

_start:
    lui sp, %hi(__stack_top)
    addi sp, sp, %lo(__stack_top)

    call    start

1:
    j       1b
