.section .text._start
.global _start

_start:
    la      a0, _sidata
    la      a1, _sdata
    la      a2, _edata
1:
    beq     a1, a2, 2f
    lw      t0, 0(a0)
    sw      t0, 0(a1)
    addi    a0, a0, 4
    addi    a1, a1, 4
    j       1b
2:

# Zero .bss
    la      a0, _sbss
    la      a1, _ebss
3:
    beq     a0, a1, 4f
    sw      x0, 0(a0)
    addi    a0, a0, 4
    j       3b
4:

    la      gp, __global_pointer$
    la      sp, __stack_top

    call    __libc_init_array
    call    start

    j       .
