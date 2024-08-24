#include <top.h>

#ifdef SOC
#include <nvboard.h>
#endif

extern TOP* top;
extern VerilatedVcdC* m_trace;

#ifdef SOC
void nvboard_bind_all_pins(VysyxSoCTop* top);
#endif

void ifu_display();
void exu_display();
void lsu_display();
void lsu_delay_display();
void cache_display();
void ipc_display();

void init_monitor(int, char*[]);
void sdb_mainloop();
int is_exit_status_bad();

int sim_time = 0;
TOP* top = NULL;
VerilatedVcdC* m_trace = NULL;

int main(int argc, char* argv[]) {
  Verilated::commandArgs(argc, argv);
  setvbuf(stdout, NULL, _IONBF, 0);
  top = new TOP;

#ifdef SOC
  nvboard_bind_all_pins(top);
  nvboard_init();
#endif

  m_trace = new VerilatedVcdC;
  Verilated::traceEverOn(true);
  top->trace(m_trace, 5);
  m_trace->open("waveform.vcd");
  init_monitor(argc, argv);
  sdb_mainloop();
  m_trace->close();

  ipc_display();
  ifu_display();
  exu_display();
  lsu_display();
  lsu_delay_display();
  cache_display();

  return is_exit_status_bad();
}
