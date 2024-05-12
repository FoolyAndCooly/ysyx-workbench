import "DPI-C" function int pmem_read(input int raddr, input int len);
import "DPI-C" function void pmem_write(
  input int waddr, input byte len, input int wdata);


module Alu(
  input [31:0] a,
  input [31:0] b,
  input [3:0] ctr,
  output [31:0] ans,
  output less,
  output zero
);
  reg [31:0] res;
  assign less = ctr[3] ? (a < b) : ($signed(a) < $signed(b));
  assign zero = (res == 0);
  always @(*) begin
    case(ctr[2:0])
      3'b000: res = ctr[3] ? (a - b) : (a + b);
      3'b001: res = a << b[5:0];
      3'b010: res = a - b; 
      3'b011: res = b;
      3'b100: res = a ^ b;
      3'b101: begin
        if(ctr[3]) begin
	  res = $signed(a) >>> b[5:0];
	end
	else begin
	  res = a >> b[5:0];
	end
      end
      3'b110: res = a | b;
      3'b111: res = a & b;
      default: res = 0;
    endcase
  end
  assign ans = (ctr[2:0] == 3'b010) ? {{31{1'b0}}, less} : res;
endmodule

module BranchCond(
  input [2:0] branch,
  input zero,
  input less,
  output reg PCAsrc,
  output reg PCBsrc
);
  always @(*) begin
    PCBsrc = (branch == 3'b010) ? 1 : 0;
    case(branch)
      3'b000: PCAsrc = 0;
      3'b001: PCAsrc = 1;
      3'b010: PCAsrc = 1;
      3'b100: PCAsrc = zero;
      3'b101: PCAsrc = ~zero;
      3'b110: PCAsrc = less;
      3'b111: PCAsrc = ~less;
      default: PCAsrc = 0;
    endcase
  end
endmodule

module DataMem(
  input [31:0] addr,
  input [31:0] data,
  input [2:0] MemOp,
  input MemWr,
  input clk,
  output reg [31:0] data_out,
  input state,
  output reg EXU_valid
);
  reg [31:0] dat;
  always @(posedge clk) begin
    if (state) begin
      case ({MemWr,MemOp})
        4'b1000: pmem_write(addr, 1, data);
        4'b1001: pmem_write(addr, 2, data);
        4'b1010: pmem_write(addr, 4, data);
        4'b0000: begin dat = pmem_read(addr,1); data_out = {{24{dat[7]}},dat[7:0]}; end // lb
        4'b0001: begin dat = pmem_read(addr,2); data_out = {{16{dat[15]}},dat[15:0]}; end//lh
        4'b0010: data_out = pmem_read(addr,4); //lw
        4'b0100: begin dat = pmem_read(addr,1); data_out = {24'b0,dat[7:0]}; end // lbu
        4'b0101: begin dat = pmem_read(addr,2); data_out = {16'b0,dat[15:0]}; end // lhu
        default: data_out = 0;
      endcase
      EXU_valid = 1;
    end
  end
endmodule

module Exu(
  input clk,
  input [31:0] src1,
  input [31:0] src2,
  input [31:0] pc,
  input [31:0] imm,
  input [3:0] aluctr,
  input aluasrc,
  input [1:0] alubsrc,
  input [2:0] branch,
  output PCAsrc,
  output PCBsrc,
  input [2:0] memop,
  input memwr,
  input memtoreg,
  output [31:0] wd,
  output reg EXU_ready,
  output reg EXU_valid,
  input reg WBU_ready,
  input reg IDU_valid
  );
  reg state_in, state_out;
  wire syn_IDU_EXU, syn_EXU_WBU;
  parameter [0:0] wready = 0, idle = 1;
  MuxKey #(2, 1, 1) si (state_out, state_in, {
    wready, WBU_ready ? idle : wready,
    idle, EXU_valid ? wready : idle
  });
  assign syn_IDU_EXU = IDU_valid & EXU_ready;
  assign syn_EXU_WBU = EXU_valid & WBU_ready;
  always @(posedge clk) begin
    state_in = state_out;
  end

  always @(posedge clk) begin
    if (syn_IDU_EXU) EXU_ready = 0;
    if (syn_EXU_WBU) begin
      EXU_valid = 0;
      EXU_ready = 1;
    end
  end

  wire [31:0] a;
  wire [31:0] b;
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
  wire [31:0] res;
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
  .data_out(data_out),
  .state(state_in),
  .EXU_valid(EXU_valid)
  );
  MuxKey #(2, 1, 32)  mr (wd, memtoreg, {
    1'b0, res,
    1'b1, data_out
  });
endmodule
