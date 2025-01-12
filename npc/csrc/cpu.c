#include <stdio.h>
#include <utils.h>
#include <common.h>
#include <memory.h>
#include <top.h>
#include <getport.h>

#define ACCESS_TIME  3
#define FLASH_MISS_PENALTY 1403
#define SDRAM_MISS_PENALTY 27

#ifdef SOC
#include <nvboard.h>
#endif

#define CYCLE 1

#define DEFINE_COUNT_FUNCTION(name)                \
    extern "C" void name##_count(uint32_t addr) {  \
        cnt[name][total]++;                              \
        if (in_fsbl(addr)) cnt[name][fsbl]++;    \
	if (in_ssbl(addr)) cnt[name][ssbl]++;    \
        if (in_client(addr)) cnt[name][client]++;    \
    }

#define DEFINE_DISPLAY_FUNCTION(name) \
    void name##_display() { \
        printf(#name "_cnt: %lld, " #name "_fsbl_cnt: %lld, " #name "_ssbl_cnt: %lld, "#name "_client_cnt: %lld\n", \
               cnt[name][total], cnt[name][fsbl], cnt[name][ssbl], cnt[name][client]); \
    }

static long long cycle_cnt;
static long long inst_cnt;

enum CounterType {ifu, exu, lsu,
                  ali, lsi, cfi, csr,
		  hit, miss, 
		  COUNTER_TYPE_COUNT};
enum MediumType { total, fsbl, ssbl, client, MEDIUM_TYPE_COUNT};
static long long cnt[COUNTER_TYPE_COUNT][MEDIUM_TYPE_COUNT];


static int lsu_flag;
static int lsu_delay;
static double lsu_ave;
static double lsu_fsbl_ave;
static double lsu_ssbl_ave;
static double lsu_client_ave;

int in_fsbl(uint32_t addr){ 
  return addr >= 0x30000000 && addr < 0x40000000;
}

int in_ssbl(uint32_t addr){
  return addr >= 0xa0000000 && addr < 0xa00000b4;
}

int in_client(uint32_t addr){
  return addr >= 0xa00000b4 && addr < 0xc0000000;
}

DEFINE_COUNT_FUNCTION(hit)
DEFINE_COUNT_FUNCTION(miss)

void cache_display(){
  double hp_fsbl = (double)cnt[hit][fsbl]/(cnt[hit][fsbl] + cnt[miss][fsbl]);
  double mp_fsbl = (double)cnt[miss][fsbl]/(cnt[hit][fsbl] + cnt[miss][fsbl]);
  double hp_ssbl = (double)cnt[hit][ssbl]/(cnt[hit][ssbl] + cnt[miss][ssbl]);
  double mp_ssbl = (double)cnt[miss][ssbl]/(cnt[hit][ssbl] + cnt[miss][ssbl]);
  double hp_client = (double)cnt[hit][client]/(cnt[hit][client] + cnt[miss][client]);
  double mp_client = (double)cnt[miss][client]/(cnt[hit][client] + cnt[miss][client]);
  double amat_fsbl = ACCESS_TIME + (1-hp_fsbl) * FLASH_MISS_PENALTY;
  double amat_ssbl = ACCESS_TIME + (1-hp_ssbl) * SDRAM_MISS_PENALTY;
  double amat_client = ACCESS_TIME + (1-hp_client) * SDRAM_MISS_PENALTY;
  long long  fsbl_cnt = cnt[hit][fsbl] + cnt[miss][fsbl];
  long long  ssbl_cnt = cnt[hit][ssbl] + cnt[miss][ssbl];
  long long  client_cnt = cnt[hit][client] + cnt[miss][client];
  double amat = (amat_fsbl * fsbl_cnt + amat_ssbl * ssbl_cnt + amat_client * client_cnt) / (fsbl_cnt + ssbl_cnt + client_cnt);
  printf("fsbl: hit probability: %f, miss probability: %f\n", hp_fsbl, mp_fsbl);
  printf("ssbl: hit probability: %f, miss probability: %f\n", hp_ssbl, mp_ssbl);
  printf("client: hit probability: %f, miss probability: %f\n", hp_client, mp_client);
  printf("fsbl_AMAT: %f, ssbl_AMAT: %f, client_AMAT: %f, total_AMAT: %f\n", amat_fsbl, amat_ssbl, amat_client, amat);
}

DEFINE_COUNT_FUNCTION(ifu)
DEFINE_COUNT_FUNCTION(exu)

extern "C" void lsu_begin(){lsu_delay = 0; lsu_flag = 1;}
extern "C" void lsu_end(uint32_t addr){
  lsu_flag = 0; 
  if (in_fsbl(addr))
    lsu_fsbl_ave = (cnt[lsu][fsbl] * lsu_fsbl_ave + lsu_delay) / (cnt[lsu][fsbl] + 1);
  if (in_ssbl(addr))
    lsu_ssbl_ave = (cnt[lsu][ssbl] * lsu_ssbl_ave + lsu_delay) / (cnt[lsu][ssbl] + 1);
  if (in_client(addr))
    lsu_client_ave = (cnt[lsu][client] * lsu_client_ave + lsu_delay) / (cnt[lsu][client] + 1);
  lsu_ave = (cnt[lsu][total] * lsu_ave + lsu_delay) / (cnt[lsu][total] + 1);
  cnt[lsu][total]++;
  if (in_fsbl(addr)) cnt[lsu][fsbl]++;
  if (in_ssbl(addr)) cnt[lsu][ssbl]++;
  if (in_client(addr)) cnt[lsu][client]++;
}

DEFINE_DISPLAY_FUNCTION(ifu)
DEFINE_DISPLAY_FUNCTION(exu)
DEFINE_DISPLAY_FUNCTION(lsu)

void lsu_delay_display(){printf("lsu_delay: %f, lsu_fsbl_delay: %f, lsu_ssbl_delay: %f, lsu_client_delay: %f\n", lsu_ave, lsu_fsbl_ave, lsu_ssbl_ave, lsu_client_ave);}

DEFINE_COUNT_FUNCTION(ali);
DEFINE_COUNT_FUNCTION(lsi);
DEFINE_COUNT_FUNCTION(cfi);
DEFINE_COUNT_FUNCTION(csr);

DEFINE_DISPLAY_FUNCTION(ali);
DEFINE_DISPLAY_FUNCTION(lsi);
DEFINE_DISPLAY_FUNCTION(cfi);
DEFINE_DISPLAY_FUNCTION(csr);


void difftest_step(uint32_t pc);
void reset_difftest();

static int sim_time = 0;

void ipc_display(){
  printf("cycle: %lld, inst: %lld, CPI: %f, IPC: %f\n", cycle_cnt, inst_cnt, (double)cycle_cnt/inst_cnt, (double)inst_cnt/cycle_cnt);
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

static int nextval = 0;
extern "C" void next(int valid) {
  nextval = valid;
}

void cycle(){
  top->clock = 0;
  top->eval();
#ifdef TRACE
  m_trace->dump(sim_time);
  sim_time++;
#endif
  top->clock = 1;
  top->eval();
#ifdef TRACE
  m_trace->dump(sim_time);
  sim_time++;
#endif
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

/* type 0 : run a cycle type 1: run a inst */
void execute(uint64_t n, int type) {
  uint32_t pre_pc;
  int reset_flag = 0;
  for (;n > 0; n --) {
    pre_pc = PC;
    if (type) {
      do{
        cycle();
#ifdef DIFFTEST
        if (RESET) reset_flag = 1;
#endif
#ifdef SOC
	nvboard_update();
#endif
      } while(!nextval);
    }
    else {
      do{
        cycle(); 
#ifdef SOC
	nvboard_update();
#endif
      } while(0);}
    inst_cnt++;
#ifdef DIFFTEST
    if (reset_flag) {reset_difftest();}
    else if (type) trace_and_difftest(pre_pc);
#endif
    if (npc_state.state != NPC_RUNNING) break;
  }
}

void cpu_exec(uint64_t n, int type) {
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
