#include <verilated.h>
#include <VysyxSoCTop.h>
#include <verilated_vcd_c.h>
#include <nvboard.h>

extern VysyxSoCTop* top;
extern VerilatedVcdC* m_trace;

void nvboard_bind_all_pins(VysyxSoCTop* top);

void ifu_display();
void exu_display();
void lsu_display();
void lsu_delay_display();
void cache_display();
void init_monitor(int, char*[]);
void sdb_mainloop();
void ipc_display();
int is_exit_status_bad();

int sim_time = 0;
VysyxSoCTop* top = NULL;
VerilatedVcdC* m_trace = NULL;

int main(int argc, char* argv[]) {
  Verilated::commandArgs(argc, argv);
  setvbuf(stdout, NULL, _IONBF, 0);
  top = new VysyxSoCTop;

  nvboard_bind_all_pins(top);
  nvboard_init();

  m_trace = new VerilatedVcdC;
  Verilated::traceEverOn(true);
  top->trace(m_trace, 5);
  m_trace->open("waveform.vcd");
  init_monitor(argc, argv);
  sdb_mainloop();
  ipc_display();
  m_trace->close();

  ifu_display();
  exu_display();
  lsu_display();
  lsu_delay_display();
  cache_display();
  return is_exit_status_bad();
}
