#include "syscalls.h"
#include "lcd.h"
#include <errno.h>
#include <stddef.h>
#include <sys/stat.h>

#undef errno
extern int errno;

static char *heap_end;

void init_heap(void)
{
    char *tmp;
    asm volatile("lui %0, %%hi(_end)\n"
                 "addi %0, %0, %%lo(_end)\n"
                 : "=r"(tmp)
                 :
                 :);
    heap_end = tmp;
}

void _exit(void)
{
    while (1) {
    }
}

int _close(const int file)
{
    return -1;
}

int fork(void)
{
    errno = EAGAIN;
    return -1;
}

int _fstat(const int file, struct stat *const st)
{
    st->st_mode = S_IFCHR;
    return 0;
}

int _isatty(const int file)
{
    return 1;
}

int _lseek(int file, int ptr, int dir)
{
    return 0;
}

int open(const char *name, int flags, int mode)
{
    return -1;
}

int _read(const int file, char *const ptr, const int len)
{
    return 0;
}

void *_sbrk(const int incr)
{
    char *prev_heap_end = heap_end;
    heap_end += incr;

    lcd_print("Heap end: ");
    lcd_print_int((int)heap_end);
    lcd_print_char('\n');

    return prev_heap_end;
}

int _write(const int file, const char *const ptr, const int len)
{
    lcd_print_sized(ptr, len);
    return len;
}
