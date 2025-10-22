#ifndef FIRMWARE_LCD_H
#define FIRMWARE_LCD_H

#include <stddef.h>
#include <stdint.h>

typedef enum LcdInstr {
    LcdInstr_Clear = 0x1, // 0b0000'0001
    LcdInstr_ResetCursor = 0x2, // 0b0000'0010
    LcdInstr_SetCursorOpts = 0xF, // 0b0000'FFFF
} LcdInstr;

void lcd_send_instr(LcdInstr instr);

void lcd_print_char(char c);

void lcd_print(const char *s);

void lcd_print_sized(const char *s, size_t size);

void lcd_print_int(int n);

#endif
