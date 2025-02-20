#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
//  int i;
//  int w = 400;  // TODO: get the correct width
//  int h = 300;  // TODO: get the correct height
//  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
//  for (i = 0; i < w * h; i ++) fb[i] = i;
//  outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t vgactl = inl(VGACTL_ADDR);
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = vgactl >> 16, .height = (uint16_t)vgactl,
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  uint32_t vgactl = inl(VGACTL_ADDR);
  int width = vgactl >> 16;
  int x = ctl->x, y = ctl->y, w = ctl->w, h = ctl->h;
  for (int i = 0; i < h; i++) {
    for (int j = 0; j < w; j++) {
      int pos = (y + i) * width + (x + j);
      outl(FB_ADDR + pos * 4, *((uint32_t*)ctl->pixels + i * w + j));
    }
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
