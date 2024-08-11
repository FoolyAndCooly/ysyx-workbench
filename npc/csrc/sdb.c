#include <common.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <top.h>

static int is_batch_mode = false;
void cpu_exec(uint64_t n, int type);
void reg_display();
void reset();
uint32_t expr(char *e, bool *success);
extern "C" int pmem_read(int addr, int len);

static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1, 1);
  return 0;
}

static int cmd_q(char *args) {
  return -1;
}

static int cmd_cyc(char *args) {
   if (args != NULL) {
    cpu_exec(atoi(args), 0);
  } else {
    cpu_exec(1, 0);
  }
  return 0;
}

static int cmd_si(char *args) {
  printf("%08x\n", top->rootp->ysyxSoCTop__DOT__dut__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc);
  if (args != NULL) {
    cpu_exec(atoi(args), 1);
  } else {
    cpu_exec(1, 1);
  }
  return 0;
}

static int cmd_p(char *args) {
  bool* success = NULL;
  printf("%x\n", expr(args, success));
  return 0;
}

static int cmd_help(char *args);

static int cmd_info(char *args) {
  if (*args == 'r') {
    reg_display();
  }
  return 0;
}

static int cmd_x(char *args) {
  int n = atoi(strtok(args, " "));
  bool* success = NULL;
  uint32_t start = expr(strtok(NULL, " "), success);
  printf("start: 0x%08x\n", start);
  for (int i = 0; i < n; i++) {
    printf("0x%08x\n", pmem_read(start + 4 * i, 4));
  }
  return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "run single command", cmd_si },
  { "info", "print statement", cmd_info },
  { "x", "scan memory", cmd_x},
  { "p", "compute expr", cmd_p},
  { "cyc", "per cycle", cmd_cyc},
 // { "w", "watch point", cmd_w},
 // { "d", "delete watch point", cmd_d}

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  reset();
  if (is_batch_mode) {
    cmd_c(NULL);
    // int n = 3;
    // while (n--) cmd_cyc(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) {npc_state.state = NPC_QUIT; return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

