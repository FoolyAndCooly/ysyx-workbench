#include <am.h>
#include <npc.h>

#define WIDTH 480
#define FB_ADDR   0x21000000
#define SYNC_ADDR 0x211ffff0

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x, y = ctl->y, w = ctl->w, h = ctl->h;
  for (int i = 0; i < h; i++) {
    for (int j = 0; j < w; j++) {
      int posx = x + j;
      int posy = y + i;
      outl(FB_ADDR | (((posy << 10) | posx) << 2), *((uint32_t*)ctl->pixels + i * w + j));
    }
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}
