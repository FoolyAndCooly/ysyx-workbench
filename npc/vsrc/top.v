module top(
  input clk
);
  
  reg IFU_valid, IDU_ready, IDU_valid, EXU_ready, EXU_valid, WBU_ready, WBU_finish;

  reg [31:0] pc;
  wire [31:0] src1, src2;
  wire [31:0] imm;
  wire PCAsrc, PCBsrc;
  wire [31:0] inst;
  wire [2:0] CSRctr;

  Ifu ifu(
  .rs1(src1),
  .clk(clk),
  .imm(imm),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .WBU_finish(WBU_finish),
  .IDU_ready(IDU_ready),
  .IFU_valid(IFU_valid),
  .pc(pc),
  .inst(inst)); 

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
  .WBU_ready(WBU_ready)
  );
  
  Wbu wbu(
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
  .WBU_ready(WBU_ready),
  .WBU_finish(WBU_finish)
  );
 endmodule

