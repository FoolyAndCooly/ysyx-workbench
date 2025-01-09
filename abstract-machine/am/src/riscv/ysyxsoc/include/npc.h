#define DEVICE_BASE 0xa0000000

#define SERIAL_PORT     (DEVICE_BASE + 0x000003f8)
#define RTC_ADDR        0x02000000
#define UART_RX_ADDR    0x10000000
#define KEYBOARD_ADDR   0x10011000
#define PSRAM_START 0x80000000
#define FLASH_START 0x30000000
#define SDRAM_END   (0xa0000000 + 0x01000000)
#define UART_START  0x10000000
#define LCR 3
#define LSB 0
#define MSB 1
#define FCR 2
#define IER 1
#define DEBUG2 12
#define FULL 16


#include <stdint.h>

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

