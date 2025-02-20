#include <am.h>
#include <klib-macros.h>
#include <npc.h>
#include <string.h>
#include <assert.h>

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

extern char __fsymtab_start;
extern char _sdata_extra_phys;
extern char __am_apps_data_end;


extern char _heap_start;
extern char _stack_top;
extern char _pmem_start;

int main(const char *args);
void _trm_init(void) __attribute__((section("._trm_init")));
void bootload(void *out, const void *in, size_t n) __attribute__((section(".bootload")));
void _fsbl(void) __attribute__((section(".fsbl")));
void _ssbl(void) __attribute__((section(".ssbl")));


Area heap = RANGE(&_heap_start, SDRAM_END);
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
  uint32_t* p1 = (uint32_t*)out;
  uint32_t* p2 = (uint32_t*)in;
  n = n >> 2;
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
#ifdef __fsymtab_start
  bootload(&__fsymtab_start, &_sdata_extra_phys, &__am_apps_data_end - &__fsymtab_start);
#endif
  bootload(&_sdata_virt, &_sdata_phys, &_edata_virt - &_sdata_virt);
  _trm_init();
}

void _trm_init() {
  uart_init();
  int ret = main(mainargs);
  halt(ret);
}
