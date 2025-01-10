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
  size_t n1 = n & 0x3;
  size_t n4 = n >> 2;
  uint8_t c1 = (uint8_t)c;
  uint32_t c4 = (c<<24)|(c<<16)|(c<<8)|c;
  uint32_t* p4 = (uint32_t*)s;
  for (int i = 0; i < n4; i++) {
    *p4 = c4;
    p4++;
  }
  uint8_t* p1 = (uint8_t*)p4;
  for (int i = 0; i < n1; i++) {
    *p1 = c1;
    p1++;
  }
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  void* ret = dst;
  char* p1 = (char*)dst;
  char* p2 = (char*)src;
  if (p1 < p2) {
    memcpy(dst, src, n);
  } else {
    p1 += n - 1;
    p2 += n - 1;
    for (int i = 0; i < n; i++) {
      *p1 = *p2;
      p1--;
      p2--;
    }
  }
  return ret;
}

void *memcpy(void *out, const void *in, size_t n) {
  void* ret = out;
  char* p1 = (char*)out;
  char* p2 = (char*)in;
  for (int i = 0; i < n; i++) {
    *p1 = *p2;
    p1++;
    p2++;
  }
  return ret;
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
