#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  char buf[1024] = {0};
  char *p = buf;
  va_list ap;
  va_start(ap, fmt);
  int ret = vsprintf(buf, fmt, ap);
  va_end(ap);
  while (*p) {
    putch(*p);
    p++;
  }
  return ret;
}

static void itoa (char* str, uint64_t num){
  char* pre = str;
  char t;
  while (num) {
    *str = '0' + num % 10;
    str++;
    num = num / 10;
  }
  *str = '\0';
  str--;
  while (pre < str) {
    t = *pre;
    *pre = *str;
    *str = t;
    pre++;
    str--;
  }
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char* pre = out;
  char buf[1024];
  while (*fmt) {
    if (*fmt == '%') {
      fmt++;
      switch (*fmt) {
        case 'd':
	  itoa(buf, va_arg(ap, uint32_t));
	  break;
	case 's':
	  strcpy(buf, va_arg(ap, char*));
	  break;
	case 'l': // %ld
	  fmt++;
	  if (*fmt == 'd') {
	    itoa(buf, va_arg(ap, uint32_t));
	    break;
	  }
	default: assert(0);
      }
      strcpy(out, buf);
      out += strlen(buf);
      fmt++;
    } else {
      *out = *fmt;
      out++;
      fmt++;
    }
  }
  *out = '\0';
  return out - pre;
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int ret = vsprintf(out, fmt, ap);
  va_end(ap);
  return ret;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
