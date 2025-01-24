#include <common.h>
#include <cpu.h>
#include <difftest.h>
#include <dlfcn.h>
#include <memory.h>
#include <top.h>
#include <getport.h>

static char *ref_so_file;
static long img_size;
static int port;

void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, int direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, int direction) = NULL;
int  (*ref_difftest_exec)(void) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;

enum {DIFFTEST_TO_DUT, DIFFTEST_TO_REF};
bool difftest_checkregs(CPU_state *ref_r, uint32_t pc);
void reg_display();

void reset_difftest() {
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy = (void(*)(uint32_t, void *, size_t, int))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void(*)(void *, int))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec = (int(*)())dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = (void(*)(uint64_t))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);
#ifndef SOC
  ref_difftest_memcpy(CONFIG_MBASE, guest_to_host(CONFIG_MBASE), img_size, DIFFTEST_TO_REF);
#else
  ref_difftest_memcpy(CONFIG_MBASE, flash_guest_to_host(0), img_size, DIFFTEST_TO_REF);
#endif
  CPU_state cpu;
  for (int i = 0; i < 32; i++) {
    cpu.gpr[i] = GPRi;
  }
#ifdef SOC
  cpu.pc = 0x30000000;
#else
  cpu.pc = 0x80000000;
#endif
  ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);
}

void init_difftest(char *arg_ref_so_file, long arg_img_size, int arg_port) {
  ref_so_file = arg_ref_so_file;
  img_size = arg_img_size;
  port = arg_port;
  assert(ref_so_file != NULL);
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  void (*ref_difftest_init)(int) = (void(*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port);
  reset_difftest();
}

static void checkregs(CPU_state *ref, uint32_t pc) {
  if (!difftest_checkregs(ref, pc)) {
    npc_state.state = NPC_ABORT;
    npc_state.halt_pc = pc;
    reg_display();
  }
}

int difftest_step(uint32_t pc) {
  CPU_state ref_r;
  int ret = ref_difftest_exec();
  ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);

  checkregs(&ref_r, pc);
  return ret;
}
