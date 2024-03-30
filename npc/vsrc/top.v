module top(
  input [31:0] inst,
  input clk,
  output reg [31:0] pc
);
  wire [31:0] res;
  wire [31:0] wd;
  wire [31:0] src1;
  wire [31:0] src2;
  wire [2:0] extop;
  wire [3:0] aluctr;
  wire aluasrc;
  wire [1:0] alubsrc;
  wire wen;
  wire [31:0] imm;
  wire CSRctr;
  wire PCAsrc, PCBsrc;
  PC_Gen pg(
  .pc_in(pc),
  .rs1(src1),
  .clk(clk),
  .imm(imm),
  .pc_out(pc),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc));
  
  wire [2:0] branch;
  wire [2:0] memop;
  wire memtoreg;
  wire memwr;
  ContrGen cg (
  .op_6_2 (inst[6:2]), 
  .func3 (inst[14:12]),
  .func7_5 (inst[30]),
  .inst20(inst[20]),
  .ExtOp(extop), 
  .ALUctr(aluctr), 
  .ALUAsrc(aluasrc), 
  .ALUBsrc(alubsrc), 
  .Regw(wen),
  .CSRctr(CSRctr),
  .branch(branch),
  .MemOp(memop),
  .MemtoReg(memtoreg),
  .MemWr(memwr));

  RegisterFile rf (
  .Ra(inst[19:15]),
  .Rb(inst[24:20]),
  .clk(clk), 
  .wdata(wd), 
  .waddr(inst[11:7]),
  .wen(wen),
  .CSRctr(CSRctr),
  .busA(src1), 
  .busB(src2));
  ImmGen ig (inst, extop, imm);
  wire [31:0] a, b;
  MuxKey #(2, 1, 32)  i1 (a, aluasrc, {
    1'b0, src1,
    1'b1, pc
  });
  MuxKey #(3, 2, 32) i2 (b, alubsrc, {
    2'b00, src2,
    2'b01, imm,
    2'b10, 32'd4
  });
  wire less, zero;
  Alu a0 (.a (a), .b(b), .ctr(aluctr), .ans(res), .less(less), .zero(zero));
  BranchCond bc(
  .branch(branch),
  .zero(zero),
  .less(less),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc));
  wire [31:0] data_out;
  DataMem dm (
  .addr(res),
  .data(src2),
  .MemOp(memop),
  .MemWr(memwr),
  .clk(clk),
  .data_out(data_out));
   MuxKey #(2, 1, 32)  mr (wd, memtoreg, {
    1'b0, res,
    1'b1, data_out
   });
endmodule

