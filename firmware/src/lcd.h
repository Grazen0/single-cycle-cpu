#ifndef FIRMWARE_LCD_H
#define FIRMWARE_LCD_H

#include <stddef.h>
#include <stdint.h>

typedef enum LcdInstr : uint8_t {
    LCD_CLEAR = 0b0000'0001,
    LCD_RETURN_HOME = 0b0000'0010,
} LcdInstr;

#define LCD_DISPLAY_CONTROL(opts) ((LcdInstr)(0b1000 | opts))

#define LCD_DC_DISPLAY 0b100
#define LCD_DC_CURSOR 0b010
#define LCD_DC_BLINK 0b001

void lcd_send_instr(LcdInstr instr);

void lcd_print_char(char c);

void lcd_print(const char *s);

void lcd_print_sized(const char *s, size_t size);

void lcd_print_int(int n);

void lcd_print_hex(uint32_t n);

#endif
