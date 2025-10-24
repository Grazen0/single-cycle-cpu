#include "lcd.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

void start(void)
{
    lcd_send_instr(LcdInstr_Clear);
    lcd_send_instr(LcdInstr_ResetCursor);
    lcd_send_instr(LcdInstr_SetCursorOpts);

    volatile char *arr = malloc(sizeof(*arr) * 10);

    arr[0] = 'H';
    arr[1] = 'e';
    arr[2] = 'l';
    arr[3] = 'l';
    arr[4] = 'o';
    arr[5] = '\0';

    lcd_print(arr);

    // printf("a");
}
