#include "syscalls.h"
#include "lcd.h"
#include <errno.h>
#include <stddef.h>
#include <sys/stat.h>

#undef errno
extern int errno;

void _exit(void)
{
    while (true) {
    }
}

int _close(const int file)
{
    return -1;
}

int _fork(void)
{
    errno = EAGAIN;
    return -1;
}

int _isatty(const int file)
{
    return 1;
}

int _fstat(const int file, struct stat *const st)
{
    st->st_mode = __S_IFCHR;
    return 0;
}

int _lseek(const int file, const int ptr, const int dir)
{
    return 0;
}

int _open(const char *name, const int flags, const int mode)
{
    return -1;
}

int _read(const int file, char *const ptr, const int len)
{
    return 0;
}

char *_sbrk(const int incr)
{
    register char *stack_ptr __asm__("sp");

    extern char __bss_end;
    static char *heap_end;

    if (heap_end == NULL)
        heap_end = &__bss_end;

    if (heap_end + incr > stack_ptr) {
        // Heap and stack collision, abort everything
        lcd_send_instr(LCD_CLEAR);
        lcd_print("HS collision");

        while (true) {
        }
    }

    char *const prev_heap_end = heap_end;
    heap_end += incr;

    return prev_heap_end;
}

int _write(const int file, char *const ptr, const int len)
{
    lcd_print_sized(ptr, len);
    return len;
}
