#include "syscalls.h"
#include "lcd.h"
#include "sys/types.h"
#include <errno.h>
#include <stddef.h>
#include <sys/stat.h>

static char *heap_end;

void init_heap(void)
{
    char *tmp;
    __asm__ volatile("lui %0, %%hi(_end)\n"
                     "addi %0, %0, %%lo(_end)\n"
                     : "=r"(tmp)
                     :
                     :);
    heap_end = tmp;
}

void _exit(int code)
{
    while (1) {
    }
}

int close(int file)
{
    return -1;
}

static char *__env[1] = {0};
static char **environ = __env;

extern int errno;

int execve(char *name, char **argv, char **env)
{
    errno = ENOMEM;
    return -1;
}

int fork(void)
{
    errno = EAGAIN;
    return -1;
}

int fstat(int file, struct stat *st)
{
    st->st_mode = S_IFCHR;
    return 0;
}

int getpid(void)
{
    return 1;
}

int isatty(int file)
{
    return 1;
}

int kill(int pid, int sig)
{
    errno = EINVAL;
    return -1;
}

int link(char *old, char *new)
{
    errno = EMLINK;
    return -1;
}

int lseek(int file, int ptr, int dir)
{
    return 0;
}

int open(const char *name, int flags, int mode)
{
    return -1;
}

int read(int file, char *ptr, int len)
{
    return 0;
}

caddr_t sbrk(int incr)
{
    char *prev_heap_end = heap_end;
    heap_end += incr;

    lcd_print("Heap end: ");
    lcd_print_int((int)heap_end);
    lcd_print_char('\n');

    return (caddr_t)prev_heap_end;
}

int unlink(char *name)
{
    errno = ENOENT;
    return -1;
}

int wait(int *status)
{
    errno = ECHILD;
    return -1;
}

int write(int file, char *ptr, int len)
{
    lcd_print_sized(ptr, len);
    return len;
}
