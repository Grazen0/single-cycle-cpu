.text
.global _start

_start:
    addi    s0, zero, 5
    addi    s1, zero, 8
    sw      s0, 0(s1)
