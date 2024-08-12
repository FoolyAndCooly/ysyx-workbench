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

#include <common.h>
//#define TEST

void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();
void cache_display();
word_t expr(char *e, bool *success);

int main(int argc, char *argv[]) {
  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

#ifdef TEST
  FILE* fp = fopen("./tools/gen-expr/input","r");
  if (fp == NULL) {
    printf("Cannot open file");
    return 1;
  }
  char line[65536+128];
  char expr_str[65536+128];
  uint32_t ans, line_num=0;
  bool* success = NULL;
  while (fgets(line, sizeof(line), fp)) {
    line[strcspn(line, "\n")] = 0;
    line_num++;
    char* ans_str = strtok(line, " ");
    strcpy(expr_str, line + strlen(ans_str) + 1);
    ans = atoi(ans_str);
    word_t res = expr(expr_str, success);
    if (ans == res) {
      printf("the %d line answer is right.\n", line_num);
    } else {
      printf("the %d line is WRONG!\n", line_num);
      printf("right ans: %d, wrong ans: %d\n%s\n", ans, res, expr_str);
    }
  }
#else
  /* Start engine. */
  engine_start();
#endif
  cache_display();
  return is_exit_status_bad();
}
