#include <verilated.h>
#include <VysyxSoCFull.h>
extern VysyxSoCFull* top;
void reset();
void init_monitor(int, char*[]);
void sdb_mainloop();
int is_exit_status_bad();

extern "C" void flash_read(int32_t addr, int32_t *data) { assert(0); }
extern "C" void mrom_read(int32_t addr, int32_t *data) {
  *data = 0x00100073;
}

VysyxSoCFull* top = NULL;
int main(int argc, char* argv[]) {
  Verilated::commandArgs(argc, argv);
  top = new VysyxSoCFull;
  reset();

  init_monitor(argc, argv);
  sdb_mainloop();
  return is_exit_status_bad();
}
