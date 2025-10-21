#include "lcd.h"
#include "syscalls.h"
#include <stddef.h>

void start(void)
{
    init_heap();

    lcd_send_instr(LcdInstr_Clear);
    lcd_send_instr(LcdInstr_ResetCursor);
    lcd_send_instr(LcdInstr_SetCursorOpts);

    lcd_print("Hello, world!");
}
