/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <stdlib.h>
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();
word_t paddr_read(paddr_t addr, int len);

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) {
  return -1;
}

static int cmd_p(char *args) {
  bool* success = NULL;
  printf("%x\n", expr(args, success));
  return 0;
}

static int cmd_si(char *args) {
  if (args != NULL) {
    cpu_exec(atoi(args));
  } else {
    cpu_exec(1);
  }
  return 0;
}

static int cmd_info(char *args) {
  if (*args=='r') {
    isa_reg_display();
  } else if (*args=='w'){
    WP* cur = get_head()->next;
    while (cur) {
      printf("NO: %d\nval:%u\nexpr: %s\n\n", cur->NO, cur->val, cur->expr_str);
      cur = cur->next;
    }
  }
  return 0;
}

static int cmd_x(char *args) {
  int n = atoi(strtok(args, " "));
  bool* success = NULL;
  uint32_t start = expr(strtok(NULL, " "), success);
  printf("start: %u\n", start);
  for (int i = 0; i < n; i++)
    printf("0x%08x\n", paddr_read(start, 4));

  return 0;
}

static int cmd_w(char* args) {
  WP* p = new_wp();
  bool* success = NULL;
  p->val = expr(args, success);
  strcpy(p->expr_str, args);
  return 0;
}

static int cmd_d(char* args) {
  WP *p = get_head()->next;
  int no = atoi(args);
  while (p) {
    if (p->NO == no) {
      free_wp(p);
    }
    p = p->next;
  }
  p = p->next;
  return 0;
}

static int cmd_help(char *args);

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
  { "w", "watch point", cmd_w},
  { "d", "delete watch point", cmd_d}

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
  if (is_batch_mode) {
    cmd_c(NULL);
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

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) {nemu_state.state = NEMU_QUIT; return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
