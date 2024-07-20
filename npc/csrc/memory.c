#include <memory.h>
#include <device.h>

#define MSIZE 0x10000000

static uint8_t pmem[MSIZE] = {
  0x93, 0x01, 0x60, 0x00, // addi
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x73, 0x00, 0x10, 0x00, // ebreak
};

static uint8_t flash_mem[MSIZE] = {
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x73, 0x00, 0x10, 0x00, // ebreak
};

static uint8_t sram_mem[MSIZE] = {};

uint64_t get_time();
uint8_t* guest_to_host(uint32_t paddr) {return pmem + paddr - CONFIG_MBASE; }
uint8_t* flash_guest_to_host(uint32_t paddr) {return flash_mem + paddr; }
uint8_t* sram_guest_to_host(uint32_t paddr) {return sram_mem + paddr; }

extern "C" void sram_read(int32_t addr, int32_t *data) {
  *data = *(uint32_t*)(sram_guest_to_host(addr & ~0x3));
  // printf("read %08x: %08x\n", addr, *data);
}

extern "C" void sram_write(int32_t addr, int32_t data, int32_t len) {
  uint8_t* waddr = sram_guest_to_host(addr);
  switch (len) {
    case 1: *(uint8_t  *)waddr = data; break;
    case 2: *(uint16_t *)waddr = data; break;
    case 4: *(uint32_t *)waddr = data; break;
  }
  // printf("write %08x: %08x %d\n", addr, data, len);
}

extern "C" void flash_read(int32_t addr, int32_t *data) {
  *data = *(uint32_t*)(flash_guest_to_host(addr & ~0x3));
  // printf("read %08x: %08x\n", addr, *data);
}
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
