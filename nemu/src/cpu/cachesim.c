#include <stdio.h>
#include <stdint.h>
#define OFFSET_MASK 0x3
#define INDEX_MASK 0x3c
#define TAG_SHIFT 6

struct block{
  int valid;
  uint32_t tag;
};

static struct block cache[0x100] = {};
static long long hit_cnt;
static long long miss_cnt;

unsigned char cache_check(uint32_t index, uint32_t tag) {
  unsigned char ret = 0;
  if (cache[index].tag == tag && cache[index].valid) {
    ret = 1;
    hit_cnt++;
  } else {
    ret = 0;
    miss_cnt++;
  }
  return ret;
}

void cache_write(uint32_t index, uint32_t tag) {
  cache[index].valid = 1;
  cache[index].tag = tag;
}

void docache(uint32_t pc) {
  uint32_t index = pc & INDEX_MASK;
  uint32_t tag = pc >> TAG_SHIFT;
  if (!cache_check(index, tag)){cache_write(index, tag);}
}

void cache_display(){
  printf("hit probability: %f, miss probability: %f\n", (double)hit_cnt/(hit_cnt + miss_cnt), (double)miss_cnt/(hit_cnt + miss_cnt));
}
