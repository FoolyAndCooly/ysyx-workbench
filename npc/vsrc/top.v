module top(
  input clk
);
  
  reg IFU_valid, IFU_ready, IDU_ready, IDU_valid, EXU_ready, EXU_valid, WBU_ready, WBU_valid;

  reg [31:0] res;
  reg [31:0] pc;
  wire [31:0] src1, src2;
  wire [31:0] imm;
  wire PCAsrc, PCBsrc;
  reg [31:0] inst;
  wire [2:0] CSRctr;

  wire [2:0] memop0;
  wire [31:0] awaddr0, wdata0;
  wire awready0, awvalid0;
  reg arready0, arvalid0, memfinish0;
  Ifu ifu(
  .clk(clk),
  .WBU_valid(WBU_valid),
  .IDU_ready(IDU_ready),
  .IFU_valid(IFU_valid),
  .IFU_ready(IFU_ready),
  .pc(pc),
  .inst(inst),
  .memop(memop0),
  .awaddr(awaddr0),
  .wdata(wdata0),
  .awready(awready0),
  .awvalid(awvalid0),
  .arready(arready0),
  .arvalid(arvalid0),
  .memfinish(memfinish0)); 

  wire syn_WBU_IFU;
  assign syn_WBU_IFU = WBU_valid & IFU_ready;

  wire dm_arvalid, dm_awvalid, dm_arready, dm_awready, dm_memfinish;
  wire [31:0] dm_data_out, dm_araddr, dm_awaddr, dm_wdata;
  wire [2:0] dm_memop;
  wire uart_awready, uart_awvalid, uart_memfinish;
  wire [31:0] arbiter_awaddr, arbiter_wdata;

  Uart uart(
  .clk(clk),
  .awaddr(arbiter_awaddr),
  .awvalid(uart_awvalid),
  .awready(uart_awready),
  .memfinish(uart_memfinish),
  .wdata(arbiter_wdata)
  );

  Arbiter arbiter(
  .clk(clk),
  .MemOp0(memop0),
  .data_out0(inst),
  .araddr0(pc),
  .arvalid0(syn_WBU_IFU),
  .arready0(arready0),
  .awaddr0(awaddr0),
  .awvalid0(awvalid0),
  .awready0(awready0),
  .wdata0(wdata0),
  .memfinish0(memfinish0),
  .MemOp1(memop),
  .data_out1(data_out1),
  .araddr1(res),
  .arvalid1(arvalid1),
  .arready1(arready1),
  .awaddr1(res),
  .awvalid1(awvalid1),
  .awready1(awready1),
  .wdata1(src2),
  .memfinish1(memfinish1),
  .memop(dm_memop),
  .data_out(dm_data_out),
  .araddr(dm_araddr),
  .arvalid(dm_arvalid),
  .awaddr(arbiter_awaddr),
  .awvalid_sram(dm_awvalid),
  .awvalid_uart(uart_awvalid),
  .arready(dm_arready),
  .awready_sram(dm_awready),
  .awready_uart(uart_awready),
  .wdata(arbiter_wdata),
  .memfinish_sram(dm_memfinish),
  .memfinish_uart(uart_memfinish)
  );

  DataMem dm(
  .MemOp(dm_memop),
  .clk(clk),
  .data_out(dm_data_out),
  .araddr(dm_araddr),
  .arvalid(dm_arvalid),
  .awaddr(arbiter_awaddr),
  .awvalid(dm_awvalid),
  .arready(dm_arready),
  .awready(dm_awready),
  .wdata(arbiter_wdata),
  .memfinish(dm_memfinish)
  );

  wire [31:0] wd;
  wire [3:0] aluctr;
  wire aluasrc;
  wire [1:0] alubsrc; 
  wire [2:0] branch;
  wire [2:0] memop;
  wire memtoreg;
  wire memwr;
  wire IDU_valid;
  wire EXU_ready;
  wire wen;
  reg [31:0] csr[3:0];
  reg [31:0] rf[31:0];

  Idu idu(
  .inst(inst),
  .aluctr(aluctr),
  .aluasrc(aluasrc),
  .alubsrc(alubsrc),
  .branch(branch),
  .memop(memop),
  .memtoreg(memtoreg),
  .memwr(memwr),
  .src1(src1),
  .src2(src2),
  .imm(imm),
  .csr(csr),
  .clk(clk),
  .rf_in(rf),
  .rf_out(rf),
  .wen(wen),
  .CSRctr(CSRctr),
  .IFU_valid(IFU_valid),
  .IDU_ready(IDU_ready),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready));


reg [31:0] data_out1;
reg arvalid1, awvalid1, arready1, awready1, memfinish1;

  Exu exu(
  .clk(clk),
  .src1(src1),
  .src2(src2),
  .pc(pc),
  .imm(imm),
  .aluctr(aluctr),
  .aluasrc(aluasrc),
  .alubsrc(alubsrc),
  .branch(branch),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .memop(memop),
  .memwr(memwr),
  .memtoreg(memtoreg),
  .wd(wd),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready),
  .EXU_valid(EXU_valid),
  .WBU_ready(WBU_ready),
  .data_out(data_out1),
  .arvalid(arvalid1),
  .awvalid(awvalid1),
  .arready(arready1),
  .awready(awready1),
  .memfinish(memfinish1),
  .res(res)
  );
  
  Wbu wbu(
  .rs1(src1),
  .imm(imm),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .pc(pc),
  .wdata(wd),
  .waddr(inst[11:7]),
  .Ra(inst[19:15]),
  .clk(clk),
  .wen(wen),
  .rf_in(rf),
  .rf_out(rf),
  .csr_in(csr),
  .csr_out(csr),
  .CSRctr(CSRctr),
  .EXU_valid(EXU_valid),
  .IFU_ready(IFU_ready),
  .WBU_ready(WBU_ready),
  .WBU_valid(WBU_valid)
  );
 endmodule

