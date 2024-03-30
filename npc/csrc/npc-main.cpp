#include <verilated.h>
#include <Vtop.h>
extern Vtop* top;
void init_top();
void init_monitor(int, char*[]);
void sdb_mainloop();
int is_exit_status_bad();

Vtop* top = NULL;
int main(int argc, char* argv[]) {
  top = new Vtop;
  init_top();

  init_monitor(argc, argv);
  sdb_mainloop();
  return is_exit_status_bad();
}
