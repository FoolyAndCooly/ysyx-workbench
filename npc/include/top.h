#ifdef SOC
#include <VysyxSoCTop.h>
#include <VysyxSoCTop___024root.h>
#else
#include <Vnpc.h>
#include <Vnpc___024root.h>
#endif
#include <verilated.h>
#include <verilated_vcd_c.h>

#ifdef SOC
extern VysyxSoCTop* top;
#else
extern Vnpc* top;
#endif
extern VerilatedVcdC* m_trace;

#ifdef SOC
#define TOP VysyxSoCTop
#else
#define TOP Vnpc
#endif

