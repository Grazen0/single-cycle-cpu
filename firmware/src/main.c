#include "lcd.h"
#include "syscalls.h"
#include <stddef.h>
#include <stdio.h>

void start(void)
{
    lcd_print("start\n");
    lcd_print_int(532);

    init_heap();

    extern void __libc_init_array();
    __libc_init_array();

    lcd_send_instr(LcdInstr_Clear);
    lcd_send_instr(LcdInstr_ResetCursor);
    lcd_send_instr(LcdInstr_SetCursorOpts);

    printf("Hello, world!");
}
