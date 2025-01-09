#include <am.h>
#include <npc.h>

#define DEBUG2 12

static int lut[256];

void __am_keyboard_init(){
  lut[0x76] = AM_KEY_ESCAPE;       
  lut[0x05] = AM_KEY_F1;
  lut[0x06] = AM_KEY_F2;
  lut[0x04] = AM_KEY_F3;
  lut[0x0c] = AM_KEY_F4;
  lut[0x03] = AM_KEY_F5;
  lut[0x0b] = AM_KEY_F6;
  lut[0x83] = AM_KEY_F7;
  lut[0x0a] = AM_KEY_F8;
  lut[0x01] = AM_KEY_F9;
  lut[0x09] = AM_KEY_F10;
  lut[0x78] = AM_KEY_F11;
  lut[0x07] = AM_KEY_F12;
  lut[0x0e] = AM_KEY_GRAVE;
  lut[0x16] = AM_KEY_1;
  lut[0x1e] = AM_KEY_2;
  lut[0x26] = AM_KEY_3;
  lut[0x25] = AM_KEY_4;
  lut[0x2e] = AM_KEY_5;
  lut[0x36] = AM_KEY_6;
  lut[0x3d] = AM_KEY_7;
  lut[0x3e] = AM_KEY_8;
  lut[0x46] = AM_KEY_9;
  lut[0x45] = AM_KEY_0;
  lut[0x4e] = AM_KEY_MINUS;
  lut[0x55] = AM_KEY_EQUALS;
  lut[0x66] = AM_KEY_BACKSPACE;
  lut[0x0d] = AM_KEY_TAB;
  lut[0x15] = AM_KEY_Q;
  lut[0x1d] = AM_KEY_W;
  lut[0x24] = AM_KEY_E;
  lut[0x2d] = AM_KEY_R;
  lut[0x2c] = AM_KEY_T;
  lut[0x35] = AM_KEY_Y;
  lut[0x3c] = AM_KEY_U;
  lut[0x43] = AM_KEY_I;
  lut[0x44] = AM_KEY_O;
  lut[0x4d] = AM_KEY_P;
  lut[0x54] = AM_KEY_LEFTBRACKET;
  lut[0x5b] = AM_KEY_RIGHTBRACKET;
  lut[0x5d] = AM_KEY_BACKSLASH;
  lut[0x58] = AM_KEY_CAPSLOCK;
  lut[0x1c] = AM_KEY_A;
  lut[0x1b] = AM_KEY_S;
  lut[0x23] = AM_KEY_D;
  lut[0x2b] = AM_KEY_F;
  lut[0x34] = AM_KEY_G;
  lut[0x33] = AM_KEY_H;
  lut[0x3b] = AM_KEY_J;
  lut[0x42] = AM_KEY_K;
  lut[0x4b] = AM_KEY_L;
  lut[0x4c] = AM_KEY_SEMICOLON;
  lut[0x52] = AM_KEY_APOSTROPHE;
  lut[0x5a] = AM_KEY_RETURN;
  lut[0x12] = AM_KEY_LSHIFT;
  lut[0x1a] = AM_KEY_Z;
  lut[0x22] = AM_KEY_X;
  lut[0x21] = AM_KEY_C;
  lut[0x2a] = AM_KEY_V;
  lut[0x32] = AM_KEY_B;
  lut[0x31] = AM_KEY_N;
  lut[0x3a] = AM_KEY_M;
  lut[0x41] = AM_KEY_COMMA;
  lut[0x49] = AM_KEY_PERIOD;
  lut[0x4a] = AM_KEY_SLASH;
  lut[0x59] = AM_KEY_RSHIFT;
  lut[0x14] = AM_KEY_LCTRL;
  lut[0x11] = AM_KEY_LALT;
  lut[0x29] = AM_KEY_SPACE;
}

void __am_uart_rx(AM_UART_RX_T *rx) {
  char data = inb(UART_RX_ADDR);
  // int count = inl(UART_RX_ADDR + DEBUG2) & 0x1f000;
  rx->data = (data == 0) ? 0xff : data;
}
void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  char data = inb(KEYBOARD_ADDR);
  if (data == 0xf0) {
    data = inb(KEYBOARD_ADDR);
    kbd->keydown = 0;
  } else {
    kbd->keydown = 1;
  }
  kbd->keycode = lut[(uint32_t)data];
}
