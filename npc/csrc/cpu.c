#include <verilated.h>
#include <stdio.h>
#include <utils.h>
#include <common.h>
#include <memory.h>
#include <top.h>

#define IRING_LEN 16

void difftest_step(uint32_t pc);

static uint32_t iringbuf[IRING_LEN];
static int iring_point = 0;

static void iring_step(){
  iring_point = (iring_point + 1) % IRING_LEN;
}

static void iring_display(){
  for (int i = 0; i < IRING_LEN; i++) {
    printf("0x%08x\n",iringbuf[iring_point]);
    iring_step();
  }
}

extern "C" void set_npc_state(int state){
  npc_state.state = state;
  npc_state.halt_pc = top->pc;
  npc_state.halt_ret = top->rootp->top__DOT__rf__DOT__rf[10];
}

void init_top() {
  top->pc = CONFIG_MBASE;
  top->clk = 0;
}

void exec_once(){
  top->clk = 0;
  top->inst = pmem_read(top->pc,4);
  // printf("inst: %08x\n", top->inst);
  // printf("pc : %08x\n", top->pc);
  top->eval();
  top->clk = 1;
  top->eval();
  return;
}

static void trace_and_difftest(uint32_t pre_pc) {
  //IFDEF(CONFIG_DIFFTEST, difftest_step());
  iringbuf[iring_point] = top->inst;
  iring_step();
  difftest_step(pre_pc);
}


void execute(uint64_t n) {
  uint32_t pre_pc;
  for (;n > 0; n --) {
    pre_pc = top->pc;
    exec_once();
    // trace_and_difftest(pre_pc);
    if (npc_state.state != NPC_RUNNING) break;
  }
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n) {
  // g_print_step = (n < MAX_INST_TO_PRINT);
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }


  execute(n);

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_ABORT: iring_display();
    case NPC_END: 
      Log("npc: %s at pc = " FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          npc_state.halt_pc);
      // printf("0x%08x\n", top->inst);
    case NPC_QUIT:;
  }
}
