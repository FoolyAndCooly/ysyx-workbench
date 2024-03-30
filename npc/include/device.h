#include <sys/time.h>
#include <time.h>

#define DEVICE_BASE 0xa0000000

#define SERIAL_PORT (DEVICE_BASE + 0x000003f8)
#define RTC_ADDR (DEVICE_BASE + 0x00000048)
