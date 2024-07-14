#include <stdio.h>
#include <utils.h>
#include <common.h>
#include <memory.h>
#include <top.h>

#define CYCLE 1

int reset_flag;

void difftest_step(uint32_t pc);
void reset_difftest();

static int sim_time = 0;

extern "C" void set_npc_state(int state, int info){
  npc_state.state = state;
  npc_state.halt_pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
  npc_state.halt_ret = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__rf[10];
  if (state == 3) {
    if (info == 0) printf("decode error\n");
    if (info == 1) printf("mem error\n");
    if (info == 2) printf("csr error\n");
  }
}

void cycle(){
  top->clock = 0;
  // printf("m_trace %d\n", m_trace);
  // top->inst = pmem_read(top->pc,4);
  // printf("pc : %08x\n", top->rootp->top__DOT__pc);
  top->eval();
  m_trace->dump(sim_time);
  sim_time++;
  top->clock = 1;
  top->eval();
  m_trace->dump(sim_time);
  sim_time++;
  return;
}

void reset() {
  top->reset = 1;
  cycle();
  top->reset = 0;
}


static void trace_and_difftest(uint32_t pre_pc) {
  difftest_step(pre_pc);
}


void execute(uint64_t n, int type) {
  uint32_t pre_pc;
  for (;n > 0; n --) {
    pre_pc = top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
    if (type) {
      reset_flag = 0;
      do{
	if (top->rootp->ysyxSoCFull__DOT__asic__DOT____Vcellinp__cpu__reset) reset_flag = 1;
        cycle();
      } while(!top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__WBU_valid);
    }
    else {do{cycle();} while(0);}
    // if (reset_flag) {reset_difftest();}
    // else if (type) trace_and_difftest(pre_pc);
    if (npc_state.state != NPC_RUNNING) break;
  }
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n, int type) {
  // g_print_step = (n < MAX_INST_TO_PRINT);
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }


  execute(n, type);

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;
    case NPC_ABORT:
    case NPC_END: 
      Log("npc: %s at pc = " FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          npc_state.halt_pc);
    case NPC_QUIT:;
  }
}
