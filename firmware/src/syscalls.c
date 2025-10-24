#include "syscalls.h"
#include "lcd.h"
#include "sys/types.h"
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/stat.h>

#undef errno
extern int errno;

void _exit(void)
{
    while (1) {
    }
}

int close(const int file)
{
    return -1;
}

int fork(void)
{
    errno = EAGAIN;
    return -1;
}

int fstat(const int file, struct stat *const st)
{
    st->st_mode = S_IFCHR;
    return 0;
}

int isatty(const int file)
{
    return 1;
}

int lseek(const int file, const int ptr, const int dir)
{
    return 0;
}

int open(const char *name, const int flags, const int mode)
{
    return -1;
}

int read(const int file, char *const ptr, const int len)
{
    return 0;
}

caddr_t sbrk(const int incr)
{
    extern void _end;
    static caddr_t heap_end;

    if (heap_end == NULL)
        heap_end = &_end;

    const caddr_t prev_heap_end = heap_end;
    heap_end += incr;

    lcd_print("New heap end: ");
    lcd_print_hex((uint32_t)heap_end);
    lcd_print_char('\n');

    return prev_heap_end;
}

int write(const int file, char *const ptr, const int len)
{
    lcd_print_sized(ptr, len);
    return len;
}
