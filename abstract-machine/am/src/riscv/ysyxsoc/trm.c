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

extern char _sssbl_virt;
extern char _essbl_virt;
extern char _sssbl_phys;
extern char _stext_virt;
extern char _etext_virt;
extern char _stext_phys;
extern char _srodata_virt;
extern char _erodata_virt;
extern char _srodata_phys;
extern char _sdata_virt;
extern char _edata_virt;
extern char _sdata_phys;

extern char _heap_start;
extern char _stack_top;
extern char _pmem_start;

int main(const char *args);
void _trm_init(void) __attribute__((section("._trm_init")));
void bootload(void *out, const void *in, size_t n) __attribute__((section(".bootload")));
void _fsbl(void) __attribute__((section(".fsbl")));
void _ssbl(void) __attribute__((section(".ssbl")));


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

void bootload(void *out, const void *in, size_t n) {
  char* p1 = (char*)out;
  char* p2 = (char*)in;
  for (int i = 0; i < n; i++) {
    *p1 = *p2;
    p1++;
    p2++;
  }
}

void _fsbl() {
  bootload(&_sssbl_virt, &_sssbl_phys, &_essbl_virt - &_sssbl_virt);
  _ssbl();
}

void _ssbl() {
  bootload(&_stext_virt, &_stext_phys, &_etext_virt - &_stext_virt);
  bootload(&_srodata_virt, &_srodata_phys, &_erodata_virt - &_srodata_virt);
  bootload(&_sdata_virt, &_sdata_phys, &_edata_virt - &_sdata_virt);
  _trm_init();
}

void _trm_init() {
  // memcpy(&_sdata, &_erodata + 1, &_edata - &_sdata);
  uart_init();
  int ret = main(mainargs);
  halt(ret);
}
