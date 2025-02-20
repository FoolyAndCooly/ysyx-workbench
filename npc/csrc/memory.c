#include <memory.h>
#include <device.h>

#define MSIZE 0x10000000

#define BLOCK_SIZE 4
#define DATA_SIZE BLOCK_SIZE>>2

struct block{
  uint32_t data[DATA_SIZE];
  int valid;
  uint32_t tag;
};

static block cache[0x100] = {};

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

static uint16_t sdram[4][8192][512][4];

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

extern "C" void sdram_read(char ba, short row, short col, short* data, short id) {
  *data = sdram[ba][row][col][id];
  // if (ba == 0 && row == 0x1f && col == 0x01aa && (id == 0 | id == 1)) printf("read: ba: %d, row: %d, col: %d, id : %d, data: %hx\n", ba, row, col, id, *data);
}

extern "C" void sdram_write(char ba, short row, short col, short data, short dqm, short id) {
  uint16_t mask = (!(dqm & 0x1) ? 0x00ff : 0x0) | (!(dqm & 0x2) ? 0xff00 : 0x0);
  sdram[ba][row][col][id] = (data & mask) | (sdram[ba][row][col][id] & ~mask);
  // if (ba == 0 && row == 0x1f && col == 0x01aa && (id == 0 | id == 1)) printf("write: ba: %d, row: %d, col: %d, id: %d, data: %hx\n", ba, row, col, id, sdram[ba][row][col][id]);
}

extern "C" void flash_read(int32_t addr, int32_t *data) {
  // printf("read %08x\n", addr);
  *data = *(uint32_t*)(flash_guest_to_host(addr & ~0x3));
}
extern "C" void mrom_read(int32_t addr, int32_t *data) {
  *data = *(uint32_t*)(guest_to_host(addr & ~0x3));
}

extern "C" int pmem_read(int raddr) {
  int addr = raddr & ~0x3;
  // printf("read %08x\n", raddr);
  // int offset = (uint32_t)addr - RTC_ADDR;
  // if (offset == 0 || offset == 4) {
  //   uint64_t us =  get_time();
  //   if (offset == 0) return us;
  //   else return us >> 32;
  // }
  return *(uint32_t*)(guest_to_host(addr));
}

extern "C" void pmem_write(int waddr, char wstrb, int data) {
  // printf("write %08x, wstrb %08x, data %08x\n", waddr, wstrb, data);
  uint8_t* addr = guest_to_host(waddr & ~0x3);
  if ((uint32_t)waddr == SERIAL_PORT) {putchar((char)data);}
  for (int i=0; i < 4; i++) {
      *(addr + i) = ((wstrb>>i) & 0x1) ? ((data >> (i<<3)) & 0xff) : *(addr + i);
  }
}
