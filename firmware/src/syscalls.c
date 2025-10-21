#include "syscalls.h"
#include <stdint.h>

static uintptr_t heap_end;

void init_heap(void) {
  uintptr_t tmp;
  __asm__ volatile("lui %0, %%hi(_end)\n"
                   "addi %0, %0, %%lo(_end)\n"
                   : "=r"(tmp)
                   :
                   :);
  heap_end = tmp;
}
