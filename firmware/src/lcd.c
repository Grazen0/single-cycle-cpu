#include "lcd.h"
#include <stddef.h>
#include <stdint.h>

#define LCD_DATA (*(volatile uint8_t *)0x80000000)
#define LCD_OPTS (*(volatile uint8_t *)0x80000001)
#define LCD_ENABLE (*(volatile uint8_t *)0x80000002)

static const uint8_t LCD_WRITE_INSTR = 0b00;
static const uint8_t LCD_WRITE_DATA = 0b10;

static inline void lcd_send(const uint8_t data)
{
    LCD_DATA = data;
    LCD_ENABLE = 1;
    LCD_ENABLE = 0;
}

void lcd_send_instr(const LcdInstr instr)
{
    LCD_OPTS = LCD_WRITE_INSTR;
    lcd_send(instr);
}

void lcd_print_char(const char c)
{
    LCD_OPTS = LCD_WRITE_DATA;
    lcd_send(c);
}

void lcd_print(const char *restrict s)
{
    LCD_OPTS = LCD_WRITE_DATA;

    while (*s != '\0')
        lcd_send(*s++);
}

void lcd_print_sized(const char *s, const size_t size)
{
    LCD_OPTS = LCD_WRITE_DATA;

    for (size_t i = 0; i < size; ++i)
        lcd_send(*s++);
}

void lcd_print_int(int n)
{
    if (n == 0) {
        lcd_print_char('0');
        return;
    }

    LCD_OPTS = LCD_WRITE_DATA;

    long long value = n;

    if (n < 0) {
        value = -value;
        lcd_send('-');
    }

    static const size_t MAX_DIGITS = 20;

    uint8_t digits[MAX_DIGITS];
    size_t i = 0;

    while (value != 0) {
        digits[i] = value % 10;
        value /= 10;
        ++i;
    }

    for (int j = 0; j < i; ++j)
        lcd_send('0' + digits[i - 1 - j]);
}
