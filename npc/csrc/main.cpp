#include <verilated.h>
#include <Vtop.h>
#include <stdio.h>
#include "../include/utils.h"

#define MBASE 0x80000000
#define MSIZE 0x00010000

static int error = 0;
static int quit = 0;
static char *img_file = NULL;

extern "C" void trap(char e){quit = 1; error = e;}

static uint8_t pmem[MSIZE] = {
  0x93, 0x01, 0x60, 0x00,
  0x93, 0x01, 0x60, 0x00,
  0x73, 0x00, 0x10, 0x00,
};

uint8_t* guest_to_host(uint32_t paddr) {return pmem + paddr - MBASE; }

extern "C" int pmem_read(int addr) {
  return *(uint32_t*)(guest_to_host(addr & ~0x3u));
}

extern "C" void pmem_write(int waddr, char len, int data) {
  uint8_t* addr = guest_to_host(waddr & ~0x3u);
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;

  }
}

static long load_img() {
  if (img_file == NULL) {
    printf("No image is given. Use the default build-in image.\n");
    return 4096; // built-in image size
  }

  FILE *fp = fopen(img_file, "rb");
  if (fp == NULL) printf("cannot open file\n");

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(pmem, size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;
}

void init(Vtop* top) {
  top->pc = MBASE;
  top->clk = 0;
}

void step(uint32_t n, Vtop* top){
  
  for (int i = 0; i < n; i++) {

    top->clk = 0;
    top->inst = pmem_read(top->pc);
    printf("inst: %08x\n", top->inst);
    top->eval();
    top->clk = 1;
    top->eval();
    if (quit) {
    if (error) printf(ANSI_FMT("HIT BAD TRAP\n", ANSI_FG_RED));
    else printf(ANSI_FMT("HIT GOOD TRAP\n", ANSI_FG_GREEN));
    return;
    }
  }
  return;
}

int main(int argc, char* argv[]) {
  img_file = argv[1];
  load_img();
  Vtop* top = new Vtop;
  init(top);
  step(-1, top);
}
