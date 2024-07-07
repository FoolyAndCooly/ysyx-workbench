#include <memory.h>
#include <device.h>

#define MSIZE 0x40000000

static uint8_t pmem[MSIZE] = {
  0x93, 0x01, 0x60, 0x00, // addi
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x73, 0x00, 0x10, 0x00, // ebreak
};

uint64_t get_time();
uint8_t* guest_to_host(uint32_t paddr) {return pmem + paddr - CONFIG_MBASE; }

extern "C" void flash_read(int32_t addr, int32_t *data) { assert(0); }
extern "C" void mrom_read(int32_t addr, int32_t *data) {
  *data = *(uint32_t*)(guest_to_host(addr & ~0x3));
}

extern "C" int pmem_read(int addr, int len) {
  // printf("read 0x%08x\n", (uint32_t)addr);
  // printf("read 0x%08x   val: 0x0%08x\n", (uint32_t)addr, *(uint32_t*)(guest_to_host(addr & ~0x3u)));
  int offset = (uint32_t)addr - RTC_ADDR;
  if (offset == 0 || offset == 4) {
    uint64_t us =  get_time();
    if (offset == 0) return us;
    else return us >> 32;
  }
  switch (len) {
    case 1: return *(uint8_t *)(guest_to_host(addr));
    case 2: return *(uint16_t*)(guest_to_host(addr));
    case 4: return *(uint32_t*)(guest_to_host(addr));
    default: return 0;
  }
}

extern "C" void pmem_write(int waddr, char mask, int data) {
  // printf("write %08x, data %08x\n", waddr, data);
  uint8_t* addr = guest_to_host(waddr);
  if ((uint32_t)waddr == SERIAL_PORT) {putchar((char)data);}
  switch (mask) {
    case 1: *(uint8_t  *)addr = data; return;
    case 3: *(uint16_t *)addr = data; return;
    case 15: *(uint32_t *)addr = data; return;
  }
}
