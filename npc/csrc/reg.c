#include <stdint.h>
#include <cpu.h>
#include <top.h>

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

void reg_display() {
  for (int i = 0; i < 32; i++) {
    printf("%-8s0x%08x\n", regs[i], top->rootp->top__DOT__rf[i]);
  }
}

bool difftest_checkregs(CPU_state *ref_r, uint32_t pc) {
  for (int i = 0; i < 32; i++) {
    if (top->rootp->top__DOT__rf[i] != ref_r->gpr[i]) {
      printf("%d th reg is wrong\nref reg :0x%08x\ncpu reg :0x%08x\n",i,ref_r->gpr[i],top->rootp->top__DOT__rf[i]);
      // printf("pc: 0x%08x\n", pc);
      return false;
    }
  }
  // if (ref_r->pc != top->rootp->top__DOT__pc) {
    // printf("pc is wrong\nref pc : 0x%08x\ncpu pc : 0x%08x\n", ref_r->pc, top->rootp->top__DOT__pc);
    // printf("pc: 0x%08x\n", pc);
   // return false;
  // }
  return true;
}

uint32_t reg_str2val(const char *s, bool *success) {
  for (int i = 0; i < 32; i++) {
    if (strcmp(regs[i], s) == 0) {
      return top->rootp->top__DOT__rf[i];
    }
  }
  return 0;
}
