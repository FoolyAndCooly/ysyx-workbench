#ifdef SOC
#define PC top->rootp->ysyxSoCTop__DOT__dut__DOT__asic__DOT__cpu__DOT__cpu__DOT__pcg__DOT__pc
#define GPR10 top->rootp->ysyxSoCTop__DOT__dut__DOT__asic__DOT__cpu__DOT__cpu__DOT__rf__DOT__rf[10]
#define GPRi top->rootp->ysyxSoCTop__DOT__dut__DOT__asic__DOT__cpu__DOT__cpu__DOT__rf__DOT__rf[i]
#define NEXT top->rootp->ysyxSoCTop__DOT__dut__DOT__asic__DOT__cpu__DOT__cpu__DOT__WBU_valid
#define RESET top->rootp->reset
#else
#define PC top->rootp->npc__DOT__cpu__DOT__pcg__DOT__pc
#define GPR10 top->rootp->npc__DOT__cpu__DOT__rf__DOT__rf[10]
#define GPRi top->rootp->npc__DOT__cpu__DOT__rf__DOT__rf[i]
#define NEXT top->rootp->npc__DOT__cpu__DOT__WBU_valid
#define RESET top->rootp->reset
#endif

