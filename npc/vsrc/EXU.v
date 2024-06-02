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
  input reg IDU_valid,
  output reg [31:0] data_out,
  output reg arvalid,
  output reg awvalid,
  output reg arready,
  output reg awready,
  input memfinish,
  output reg [31:0]res
  );
  wire syn_IDU_EXU, syn_EXU_WBU;
  assign syn_IDU_EXU = IDU_valid & EXU_ready;
  assign syn_EXU_WBU = EXU_valid & WBU_ready;
  always @(posedge clk) begin
    if (syn_IDU_EXU) begin 
      // $display("EXU");
      EXU_ready <= 0;
    end
    if (syn_EXU_WBU) begin
      EXU_valid <= 0;
      EXU_ready <= 1;
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
  Alu a0 (.a (a), .b(b), .ctr(aluctr), .ans(res), .less(less), .zero(zero));
  BranchCond bc(
  .branch(branch),
  .zero(zero),
  .less(less),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc));

  reg state;

  always @(posedge clk) begin
    if (syn_IDU_EXU & ~memwr & (memop != 3'b111)) begin
      arvalid <= 1;
      state <= 1;
    end 
    else begin
      if (arready & arvalid) begin
        arvalid <= 0;
      end
    end
    if (syn_IDU_EXU & memwr & (memop != 3'b111)) begin
      awvalid <= 1;
      state <= 1;
    end 
    else begin
      if (awready & awvalid) begin
        awvalid <= 0;
      end
    end

    if (syn_IDU_EXU & (memop == 3'b111)) begin
      EXU_valid <= 1;
    end
    // $display("state: %d, memfinish: %d", state, memfinish);
    if (state & memfinish) begin
      EXU_valid <= 1;
      state <= 0;
    end
  end
  
  MuxKey #(2, 1, 32)  mr (wd, memtoreg, {
    1'b0, res,
    1'b1, data_out
  });
endmodule
