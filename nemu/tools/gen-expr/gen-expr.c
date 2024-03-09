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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>
#define MAX_NUM 10000
#define OP_NUM 4
#define MAX_BLANK 5
#define MAX_BUF 65536
#define choose(x) (rand() % x)

// this should be enough
static char buf[MAX_BUF] = {};
static char* p = buf; // a pointer of 'buf'
static char code_buf[MAX_BUF + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"#include <stdint.h>\n"
"int main() { "
"  unsigned result = (uint32_t)0 + %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static void gen_num() {
  sprintf(p, "%d", choose(MAX_NUM));
  p += strlen(p);
}

static void gen(char ch) {
  *p++ = ch;
}

static void gen_rand_op() {
  char set[OP_NUM] = {'+', '-', '*', '/'};
  *p++ = set[choose(OP_NUM)];
}

static void gen_minus() {
  if (choose(2)) {
    *p++ = '-';
  }
}

static void gen_blank() {
  int n = choose(MAX_BLANK);
  for (int i = 0; i < n; i++) {
    *p++ = ' ';
  }
}

static void gen_rand_expr() {
  if (p >= buf + MAX_BUF) {
    p = buf;
    gen_rand_expr();
  }
  switch (choose(3)) {
    case 0: gen_minus(); gen_num(); break;
    case 1: gen('('); gen_blank(); gen_rand_expr(); gen_blank(); gen(')'); break;
    case 2: gen_rand_expr(); gen_blank(); gen_rand_op(); gen_blank(); gen_rand_expr(); break;
  }
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    p = buf;
    memset(buf, 0, sizeof(buf));
    gen_rand_expr();
    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc -O2 -Werror /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
