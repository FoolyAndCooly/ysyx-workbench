#include <am.h>
#include <klib-macros.h>
#include <npc.h>
#include <string.h>
#include <assert.h>

extern char _sdata;
extern char _erodata;
extern char _edata;
extern char _heap_start;
extern char _stack_top;
int main(const char *args);

extern char _pmem_start;

Area heap = RANGE(&_heap_start, &_stack_top);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
  uint32_t addr = 0x10000000;
  asm volatile ("sb %0, 0(%1)":: "r" (ch), "r" (addr): "memory");
}

void halt(int code) {
  asm volatile("mv a0, %0; ebreak" : : "r"(code));
  while (1);
}

void _trm_init() {
  memcpy(&_sdata, &_erodata, &_edata - &_sdata);
  int ret = main(mainargs);
  halt(ret);
}
