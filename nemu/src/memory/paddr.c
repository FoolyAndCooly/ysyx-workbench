/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#ifndef CONFIG_SOC
#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif
#else
static uint8_t flash[FLASH_SIZE] PG_ALIGN = {};

static uint8_t sdram[SDRAM_SIZE] PG_ALIGN = {};
#endif

uint8_t* guest_to_host(paddr_t paddr) { 
  uint8_t* ret = NULL;
#ifndef CONFIG_SOC
  ret = pmem + paddr - CONFIG_MBASE;
#else
  if (in_flash(paddr)) ret = flash + paddr - FLASH_BASE;
  if (in_sdram(paddr)) ret = sdram + paddr - SDRAM_BASE;
#endif
  return ret;
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

#ifndef CONFIG_TARGET_SHARE
static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
  addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}
#endif

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
#ifndef CONFIG_SOC
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
#else
  IFDEF(CONFIG_MEM_RANDOM, memset(flash, rand(), FLASH_SIZE));
  IFDEF(CONFIG_MEM_RANDOM, memset(sdram, rand(), SDRAM_SIZE));
#endif
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

word_t paddr_read(paddr_t addr, int len) {
  IFDEF(CONFIG_MTRACE, printf("read %x, len: %d, data: %x\n", addr, len, pmem_read(addr, len)));
#ifndef CONFIG_SOC
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
#else
  if (in_flash(addr) | in_sdram(addr)) return pmem_read(addr, len);
#endif
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  #ifndef CONFIG_TARGET_SHARE 
  out_of_bound(addr);
  #endif
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  IFDEF(CONFIG_MTRACE,printf("write %x, len: %d, data: %x\n", addr, len, data));
#ifndef CONFIG_SOC
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
#else
  if (in_flash(addr) | in_sdram(addr)) { pmem_write(addr, len, data); return; }
#endif
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  #ifndef CONFIG_TARGET_SHARE
  out_of_bound(addr);
  #endif
}
