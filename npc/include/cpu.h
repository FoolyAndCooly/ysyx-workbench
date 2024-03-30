#ifndef __CPU_H__
#define __CPU_H_

#include <common.h>

typedef struct {
  uint32_t gpr[32];
  uint32_t pc;
} CPU_state;

#endif
