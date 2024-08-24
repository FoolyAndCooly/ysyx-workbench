#include <stdio.h>
#include <utils.h>
#include <common.h>
#include <memory.h>
#include <top.h>
#include <getport.h>

#ifdef SOC
#include <nvboard.h>
#endif

#define CYCLE 1

int reset_flag;

static long long cycle_cnt;
static long long inst_cnt;
static long long ifu_cnt;
static long long exu_cnt;
static long long lsu_cnt;
static int lsu_flag;
static int lsu_delay;
static float lsu_ave;

extern "C" void ifu_count(){ifu_cnt++;}
extern "C" void exu_count(){exu_cnt++;}

extern "C" void lsu_begin(){lsu_delay = 0; lsu_flag = 1;}
extern "C" void lsu_end(){
  lsu_flag = 0; 
  lsu_ave = (lsu_cnt * lsu_ave + lsu_delay) / (lsu_cnt + 1);
  lsu_cnt++;
}

void ifu_display(){printf("ifu_cnt: %lld\n", ifu_cnt);}
void exu_display(){printf("exu_cnt: %lld\n", exu_cnt);}
void lsu_display(){printf("lsu_cnt: %lld\n", lsu_cnt);}
void lsu_delay_display(){printf("ave lsu_delay: %f\n", lsu_ave);}

void difftest_step(uint32_t pc);
void reset_difftest();

static int sim_time = 0;

void ipc_display(){
  printf("cycle: %lld, inst: %lld, IPC: %f\n", cycle_cnt, inst_cnt, (double)cycle_cnt / inst_cnt);
}

extern "C" void set_npc_state(int state, int info){
  npc_state.state = state;
  npc_state.halt_pc = PC;
  npc_state.halt_ret = GPR10;
  if (state == 3) {
    if (info == 0) printf("decode error\n");
    if (info == 1) printf("mem error\n");
    if (info == 2) printf("csr error\n");
  }
}

void cycle(){
  top->clock = 0;
  top->eval();
  m_trace->dump(sim_time);
  sim_time++;
  top->clock = 1;
  top->eval();
  m_trace->dump(sim_time);
  sim_time++;
  cycle_cnt++;
  if (lsu_flag) lsu_delay++;
  return;
}

void reset() {
  top->reset = 1;
  for (int i = 0; i < 16; i++) cycle();
  top->reset = 0;
  cycle_cnt = 0;
  inst_cnt = 0;
}


static void trace_and_difftest(uint32_t pre_pc) {
  difftest_step(pre_pc);
}


void execute(uint64_t n, int type) {
  uint32_t pre_pc;
  for (;n > 0; n --) {
    pre_pc = PC;
    if (type) {
      reset_flag = 0;
      do{
        cycle();
#ifdef SOC
	nvboard_update();
#endif
      } while(!NEXT);
    }
    else {
      do{
        cycle(); 
#ifdef SOC
	nvboard_update();
#endif
      } while(0);}
    inst_cnt++;
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
