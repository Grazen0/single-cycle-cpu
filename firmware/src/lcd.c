#include "lcd.h"
#include <stdint.h>

#define LCD_DATA (*(volatile uint8_t *)0x8000'0000)
#define LCD_OPTS (*(volatile uint8_t *)0x8000'0001)
#define LCD_ENABLE (*(volatile uint8_t *)0x8000'0002)

static constexpr uint8_t LCD_WRITE_INSTR = 0b00;
static constexpr uint8_t LCD_WRITE_DATA = 0b10;

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
