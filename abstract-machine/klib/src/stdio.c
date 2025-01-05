#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

char buf_printf[2048];
char buf_myitoa[256];
char buf_itox[256];
char buf_vsprintf[1024];

int printf(const char *fmt, ...) {
  int ret=-1;
  char *p = buf_printf;
  va_list ap;
  va_start(ap, fmt);
  ret=vsprintf(p, fmt, ap);
  va_end(ap);
  while(*p){putch(*p);p++;}
  return ret;
  }
void myitoa(char* str,uint32_t num){
  char* buf = buf_myitoa;
  int i=0,j=0;
  do{
    buf[i++]=num%10+'0';
    num/=10;
  } while(num);
  i--;
  for(;i>=0;i--){
    str[j++]=buf[i];
  }
  str[j]='\0';
}
void itox(char* str,uint32_t num){
  char* buf = buf_itox;
  char map[16]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
  int i=0,j=0;
  do{
    buf[i++]=map[num%16];
    num/=16;
  } while(num);
  i--;
  for(;i>=0;i--){
    str[j++]=buf[i];
  }
  str[j]='\0';
}
int vsprintf(char *out, const char *fmt, va_list ap) {
  int i;
  char *t;
  char c;
  t=out;
  char *s, *buff = buf_vsprintf;
  while(*fmt != '\0'){
  if(*fmt != '%'){*out++ = *fmt;}
  else{
    switch(*++fmt){
      case 'd':
      	i=va_arg(ap,uint32_t);
      	myitoa(buff,i);
      	*out='\0';
      	strcat(out,buff);
      	out=out+strlen(buff);
      	break;
      case 'c':
      	c=(char)va_arg(ap,int);
      	*out=c;
      	out++;
      	break;
      case 's':
      	s=va_arg(ap,char *);
      	*out = '\0';
      	strcat(out,s);
      	out=out+strlen(s);
      	break;
      case 'x':
      	i=va_arg(ap,uint32_t);
      	itox(buff,i);
      	*out='\0';
      	strcat(out,buff);
      	out=out+strlen(buff);
      	break;
      case 'p':
      	i=va_arg(ap, uint32_t);
      	itox(buff,i);
      	*out='\0';
      	strcat(out,buff);
      	out=out+strlen(buff);
      }
    }
  fmt++;
  }
  *out='\0';
  return out-t; 
  //panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  int ret = -1;
  va_start(ap, fmt);
  ret = vsprintf(out , fmt, ap);
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
