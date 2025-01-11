#include <top.h>

#ifdef SOC
#include <nvboard.h>
#endif

extern TOP* top;
#ifdef TRACE
extern VerilatedVcdC* m_trace;
#endif

#ifdef SOC
void nvboard_bind_all_pins(VysyxSoCTop* top);
#endif

void ifu_display();
void exu_display();
void lsu_display();
void ali_display();
void lsi_display();
void cfi_display();
void csr_display();

void lsu_delay_display();
void cache_display();
void ipc_display();

void init_monitor(int, char*[]);
void sdb_mainloop();
int is_exit_status_bad();

int sim_time = 0;
TOP* top = NULL;
#ifdef TRACE
VerilatedVcdC* m_trace = NULL;
#endif

int main(int argc, char* argv[]) {
  Verilated::commandArgs(argc, argv);
  setvbuf(stdout, NULL, _IONBF, 0);
  top = new TOP;

#ifdef SOC
  nvboard_bind_all_pins(top);
  nvboard_init();
#endif

#ifdef TRACE
  printf("trace on\n");
  m_trace = new VerilatedVcdC;
  Verilated::traceEverOn(true);
  top->trace(m_trace, 5);
  m_trace->open("waveform.vcd");
#endif
  init_monitor(argc, argv);
  sdb_mainloop();
#ifdef TRACE
  m_trace->close();
#endif

  ipc_display();
  ifu_display();
  exu_display();
  lsu_display();
  ali_display();
  lsi_display();
  cfi_display();
  csr_display();

  lsu_delay_display();
  cache_display();

  return is_exit_status_bad();
}
