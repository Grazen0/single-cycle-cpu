#ifndef FIRMWARE_LCD_H
#define FIRMWARE_LCD_H

#include <stdint.h>

typedef enum LcdInstr : uint8_t {
    LcdInstr_Clear = 0x1, // 0b0000'0001
    LcdInstr_ResetCursor = 0x2, // 0b0000'0010
    LcdInstr_SetCursorOpts = 0xF, // 0b0000'FFFF
} LcdInstr;

void lcd_send_instr(uint8_t data);

void lcd_print_char(char c);

void lcd_print(const char *restrict s);

#endif
