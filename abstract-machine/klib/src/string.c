#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  size_t cnt = 0;
  while (*s) {
    cnt++;
    s++;
  }
  return cnt;
}

char *strcpy(char *dst, const char *src) {
  char* ret = dst;
  while (*src) {
    *dst = *src;
    dst++;
    src++;
  }
  *dst = '\0';
  return ret;
}

char *strncpy(char *dst, const char *src, size_t n) {
  char* ret = dst;
  for (int i = 0; i < n; i++) {
    if (*src) {
      *dst = *src;
      src++;
    } else {
      *dst = '\0';
    }
    dst++;
  }
  *dst = '\0';
  return ret;
}

char *strcat(char *dst, const char *src) {
  char* ret = dst;
  while (*dst) {
    dst++;
  }
  while (*src) {
    *dst = *src;
    dst++;
    src++;
  }
  *dst = '\0';
  return ret;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 == *s2 && *s1 && *s2) {
    s1++;
    s2++;
  }
  return *s1 - *s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  int cnt = 0;
  while (*s1 == *s2 && *s1 && *s2 && cnt < n) {
    s1++;
    s2++;
    cnt++;
  }
  return *s1 - *s2;
 
}

void *memset(void *s, int c, size_t n) {
  char* p = (char*)s;
  for (int i = 0; i < n; i++) {
    *p = c;
    p++;
  }
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  panic("Not implemented");
}

void *memcpy(void *out, const void *in, size_t n) {
  panic("Not implemented");
}

int memcmp(const void *s1, const void *s2, size_t n) { 
  char* p1 = (char*)s1;
  char* p2 = (char*)s2;
  while (--n && (*p1 == *p2)) {
    p1++;
    p2++;
  }

  return *p1 - *p2;
}

#endif
