.text
.global _start

LCD_DATA = 0
LCD_OPTS = 4
LCD_ENABLE = 8

LCD_CLEAR = 0b00000001
LCD_RETURN = 0b00000010
LCD_SET = 0b00000111

_start:
    sw      zero, LCD_OPTS(zero) # write instruction

    li      s1, 1

    li      s0, LCD_CLEAR
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, LCD_RETURN
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, LCD_SET
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 0b10 # write data
    sw      s0, LCD_OPTS(zero)

    li      s0, 'H'
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'e'
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'l'
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'o'
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, ','
    sw      s0, LCD_DATA(zero)
    sw      s1, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, ' '
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'w'
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'o'
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'r'
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'l'
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, 'd'
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

    li      s0, '!'
    sw      s0, LCD_DATA(zero)
    sw      s4, LCD_ENABLE(zero)
    sw      zero, LCD_ENABLE(zero)

