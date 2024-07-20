#include <am.h>
#include <klib-macros.h>
#include <npc.h>
#include <string.h>
#include <assert.h>

#define PSRAM_START 0x80000000
#define FLASH_START 0x30000000
#define UART_START  0x10000000
#define LCR 3
#define LSB 0
#define MSB 1
#define FCR 2
#define IER 1
#define DEBUG2 12
#define FULL 16

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
  int count;
  do {asm volatile ("lw %0, 0(%1)": "=r" (count) : "r" (UART_START + DEBUG2));}
  while (count >= FULL);
  asm volatile ("sb %0, 0(%1)":: "r" (ch), "r" (UART_START): "memory");
}

void halt(int code) {
  asm volatile("mv a0, %0; ebreak" : : "r"(code));
  while (1);
}

void uart_init(){
  asm volatile("sb %0, 0(%1)":: "r"(0x83), "r"(UART_START + LCR): "memory");
  asm volatile("sb %0, 0(%1)":: "r"(0x00), "r"(UART_START + MSB): "memory");
  asm volatile("sb %0, 0(%1)":: "r"(0x01), "r"(UART_START + LSB): "memory");
  asm volatile("sb %0, 0(%1)":: "r"(0x03), "r"(UART_START + LCR): "memory");
  asm volatile("sb %0, 0(%1)":: "r"(0xc0), "r"(UART_START + FCR): "memory");
  asm volatile("sb %0, 0(%1)":: "r"(0x0f), "r"(UART_START + IER): "memory");
}

void bootloader(){
  uint32_t inst;
  uint32_t len = &_erodata - FLASH_START + 1;
  for (int i = 0; i <= len; i += 4) {
    asm volatile ("lw %0, 0(%1)": "=r" (inst) : "r" (FLASH_START + i));
    asm volatile ("sw %0, 0(%1)":: "r" (inst) , "r" (PSRAM_START + i): "memory");
  }
}

void _trm_init() {
  memcpy(&_sdata, &_erodata + 1, &_edata - &_sdata);
  uart_init();
  // bootloader();
  int ret = main(mainargs);
  halt(ret);
}
