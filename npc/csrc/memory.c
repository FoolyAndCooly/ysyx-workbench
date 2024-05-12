#include <memory.h>
#include <device.h>

#define MBASE 0x80000000
#define MSIZE 0x40000000

static uint8_t pmem[MSIZE] = {
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x73, 0x00, 0x10, 0x00,
};

uint64_t get_time();
uint8_t* guest_to_host(uint32_t paddr) {return pmem + paddr - MBASE; }

extern "C" int pmem_read(int addr, int len) {
  printf("read 0x%08x\n", (uint32_t)addr);
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

extern "C" void pmem_write(int waddr, char len, int data) {
  uint8_t* addr = guest_to_host(waddr);
  printf("write 0x%08x  val: 0x%08x\n", (uint32_t)waddr, data);
  if ((uint32_t)waddr == SERIAL_PORT) {putchar((char)data);}
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
  }
}
