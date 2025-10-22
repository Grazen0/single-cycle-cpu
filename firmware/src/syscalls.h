#ifndef FIRMWARE_SYSCALLS_H
#define FIRMWARE_SYSCALLS_H

void init_heap(void);

int write(int file, char *ptr, int len);

#endif
