.text
.global _start

LCD_DATA = 0
LCD_OPTS = 1
LCD_ENABLE = 2

LCD_CLEAR = 0b00000001
LCD_RETURN = 0b00000010
LCD_SET = 0b00001110

_start:
    li      x1, 0x28
    sb      x1, 0(zero)
    li      x1, 0xAF
    sb      x1, 1(zero)
    li      x1, 0x1234
    sh      x1, 2(zero)

    lw      x1, 0(zero)
    lh      x1, 0(zero)

1:
    j       1b

    li      t0, 0b00           # write instruction
    sw      t0, LCD_OPTS(zero)

    li      t0, 0b00           # write data
    sw      t0, LCD_OPTS(zero)

loop:
    j       loop

print_str:
    lb      t0, 0(a0)
    beq     t0, zero, 1f

    sb      t0, LCD_DATA(zero)

    li      t1, 1
    sb      t1, LCD_ENABLE(zero)
    sb      zero, LCD_ENABLE(zero)

    addi    a0, a0, 1
    j       print_str

1:
    ret

.data
hello: .asciz "Hello, world!"
