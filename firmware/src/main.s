.text
.global _start

LCD_BASE = 0x80000000
LCD_DATA = 0
LCD_OPTS = 1
LCD_ENABLE = 2

LCD_CLEAR = 0b00000001
LCD_RETURN = 0b00000010
LCD_SET = 0b00001111

_start:
    li      t1, 1
    li      t2, LCD_BASE

    li      t0, 0b00 # write instruction
    sb      t0, LCD_OPTS(t2)

    li      t0, LCD_CLEAR
    sb      t0, LCD_DATA(t2)
    sb      t1, LCD_ENABLE(t2)
    sb      zero, LCD_ENABLE(t2)

    li      t0, LCD_RETURN
    sb      t0, LCD_DATA(t2)
    sb      t1, LCD_ENABLE(t2)
    sb      zero, LCD_ENABLE(t2)

    li      t0, LCD_SET
    sb      t0, LCD_DATA(t2)
    sb      t1, LCD_ENABLE(t2)
    sb      zero, LCD_ENABLE(t2)

    li      t0, 0b10 # write data
    sb      t0, LCD_OPTS(t2)

    li      a0, 0
    call    print

1:
    j       1b

print:
    li      t1, 1
    li      t2, LCD_BASE

1:
    lb      t0, 0(a0)
    beq     t0, zero, 2f

    sb      t0, LCD_DATA(t2)
    sb      t1, LCD_ENABLE(t2)
    sb      zero, LCD_ENABLE(t2)

    addi    a0, a0, 1
    j       1b

2:
    ret

.data
.asciz "Hello, world!"
