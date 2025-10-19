.text
.global _start

LCD_DATA = 0
LCD_OPTS = 4
LCD_ENABLE = 8

LCD_CLEAR = 0b00000001
LCD_RETURN = 0b00000010
LCD_SET = 0b00000111

_start:
    li      s1, LCD_DATA
    li      s2, LCD_OPTS
    li      s3, LCD_ENABLE
    li      s4, 1

    li      s0, 0b00 # write instruction
    sw      s0, 0(s2)

    li      s0, LCD_CLEAR
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, LCD_RETURN
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, LCD_SET
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 0b10 # write data
    sw      s0, 0(s2)

    li      s0, 'H'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'e'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'l'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'o'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, ','
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, ' '
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'w'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'o'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'r'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'l'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, 'd'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

    li      s0, '!'
    sw      s0, 0(s1)
    sw      s4, 0(s3)
    sw      zero, 0(s3)

