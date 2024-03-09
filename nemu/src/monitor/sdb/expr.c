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
#include <string.h>
#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

word_t paddr_read(paddr_t addr, int len);
word_t isa_reg_str2val(const char *s, bool *success);

enum {
  TK_NOTYPE = 256, TK_EQ, TK_NEQ, TK_AND, TK_NUM, TK_P, TK_MINUS, TK_REG, TK_HNUM,

  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"\\-", '-'},
  {"\\*", '*'},
  {"/"  , '/'},
  {"\\(", '('},
  {"\\)", ')'},
  {"==", TK_EQ},// equal
  {"!=", TK_NEQ},
  {"&&", TK_AND},
  {"0[xX][0-9a-fA-F]+", TK_HNUM},
  {"[0-9]+", TK_NUM},
  {"\\$[a-zA-Z]*[0-9]*", TK_REG},
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[1024];
} Token;

static Token tokens[1024] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

#define judge(k, type) ( k == 0 || \
type == '+' || type == '-' || type == '*' || type == '/' || \
type == TK_EQ || type == TK_NEQ || type == TK_AND || \
type == '(' || type == TK_MINUS)

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;
  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;
	int type = rules[i].token_type;
        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;
	if (substr_len >= 1023) {
	  printf("number is too long\n");
	  return false;
	}

        switch (rules[i].token_type) {
	  case TK_NOTYPE: 
	    break;
	  case TK_REG:
	  case TK_HNUM:
	  case TK_NUM:
	    strncpy(tokens[nr_token].str, substr_start, substr_len);
	  case '-':
	    if ((rules[i].token_type == '-') && judge(nr_token, tokens[nr_token - 1].type)) {
	      type = TK_MINUS;
	    }
	  case '*':
	    if (rules[i].token_type == '*' && judge(nr_token, tokens[nr_token - 1].type)) {
	      type = TK_P;
	    }
	  default:
	    tokens[nr_token].type = type;
	    nr_token++;
        }
        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

int priority(int type) {
  switch (type) {
    case TK_AND:
      return 7;
    case TK_EQ:
    case TK_NEQ:
      return 6;
    case '+':
    case '-':
      return 5;
    case '*':
    case '/':
      return 4;
    case TK_MINUS:
      return 3;
    case TK_P:
      return 3;
  }
  return -1;
}

bool check(int p, int q) {
  int cnt = 0;
  if (tokens[p].type == '(' && tokens[q].type == ')') {
    for (int i = p; i <= q; i++) {
      if (tokens[i].type == '(') {
	cnt++;
      } else if (tokens[i].type == ')') {
	cnt--;
      }
      if (cnt < 0) {
	assert(0);
      }
      if (cnt == 0 && i != q) {
	return false;
      }
    }
    if (cnt != 0) {
      assert(0);
    }
    return true;
  }
  return false;
}



int find_op(int p, int q) {
  int cnt = 0;
  int ret=-1, max_priority=0;
  for (int i = q; i >= p; i--) {
    if (tokens[i].type == ')') {
      cnt++;
    } else if (tokens[i].type == '(') {
      cnt--;
    } else {
      if (!cnt) {
        if (priority(tokens[i].type) > max_priority) {
	  ret = i;
	  max_priority = priority(tokens[i].type);
	}
      }
    }
  }
  return ret;
}

word_t eval(int p, int q) {

  if (p > q) {
    assert(0);
  }
  else if (p == q) {
    if (tokens[p].type == TK_NUM) {
      return (uint32_t)atoi(tokens[p].str);
    } else if (tokens[p].type == TK_REG){
      bool* success = NULL;
      return (uint32_t)isa_reg_str2val(tokens[p].str + 1, success);
    } else {
      uint32_t number;
      sscanf(tokens[p].str, "%x", &number);
      return number;
    }
  }
  else if (check(p,q) == true) {
    return eval(p + 1, q - 1);
  }
  else {
    int op = find_op(p, q);
    if (op - 1 >= p){
      uint32_t val1 = eval(p, op - 1);
      uint32_t val2 = eval(op + 1, q);
      switch (tokens[op].type) {
        case '+': return val1 + val2;
        case '-': return val1 - val2;
        case '*': return val1 * val2;
        case '/': return val1 / val2;
        case TK_EQ: return val1 == val2;
        case TK_NEQ: return val1 != val2;
        case TK_AND: return val1 && val2;
        default: assert(0);
      }
    } else {
      uint32_t val = eval(op + 1, q);
      switch (tokens[op].type) {
        case TK_MINUS: return -val;
	case TK_P: return paddr_read(val, 4);
      }
    }
  }
  return 0;
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  word_t ret = eval(0, nr_token-1);
  memset(tokens, 0, sizeof(tokens));
  return ret;
}
