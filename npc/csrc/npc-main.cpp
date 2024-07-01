#include <verilated.h>
#include <VysyxSoCFull.h>
#include <verilated_vcd_c.h>

extern VysyxSoCFull* top;
extern VerilatedVcdC* m_trace;

void init_monitor(int, char*[]);
void sdb_mainloop();
int is_exit_status_bad();

int sim_time = 0;
VysyxSoCFull* top = NULL;
VerilatedVcdC* m_trace = NULL;

int main(int argc, char* argv[]) {
  Verilated::commandArgs(argc, argv);
  setvbuf(stdout, NULL, _IONBF, 0);
  top = new VysyxSoCFull;

  m_trace = new VerilatedVcdC;
  Verilated::traceEverOn(true);
  top->trace(m_trace, 5);
  m_trace->open("waveform.vcd");
  
  init_monitor(argc, argv);
  sdb_mainloop();

  m_trace->close();
  return is_exit_status_bad();
}
