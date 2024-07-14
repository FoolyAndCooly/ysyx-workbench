#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <common.h>
#define CONFIG_MBASE     0x20000000
#define CONFIG_FLASHBASE 0x30000000

uint8_t* guest_to_host(uint32_t paddr);

extern "C" int pmem_read(int addr, int len);
extern "C" void pmem_write(int waddr, char len, int data);

#endif
