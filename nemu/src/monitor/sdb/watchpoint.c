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

#include "sdb.h"

#define NR_WP 32

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
    wp_pool[i].val = 0;
  }

  head = (WP*)malloc(sizeof(WP));
  head->NO = -1;
  head->next = NULL;
  free_ = (WP*)malloc(sizeof(WP));
  free_->NO = -1;
  free_->next = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */
WP* new_wp(){
  WP* ret;
  if (free_->next) {
    ret = free_->next;
    free_->next = ret->next;
  } else {
    assert(0);
  }
  ret->next = head->next;
  head->next = ret;
  return ret;
}

void free_wp(WP *wp) {
  WP* pre = head;
  WP* cur = head->next;
  while (cur) {
    if (cur == wp) {
      pre->next = cur->next;
      break;
    }
    pre = cur;
    cur = cur->next;
  }
  wp->next = free_->next;
  free_->next = wp;
}

WP* get_head(){
  return head;
}
