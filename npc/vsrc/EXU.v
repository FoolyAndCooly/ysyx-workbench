module Alu(
  input [31:0] a,
  input [31:0] b,
  input [3:0] ctr,
  output [31:0] ans
);
  reg [31:0] res;
  wire less = ctr[3] ? (a < b) : ($signed(a) < $signed(b));
  always @(*) begin
    case(ctr[2:0])
      3'b000: res = ctr[3] ? (a - b) : (a + b);
      3'b001: res = a << b[4:0];
      3'b010: res = a - b; 
      3'b011: res = b;
      3'b100: res = a ^ b;
      3'b101: begin
        if(ctr[3]) begin
	  res = $signed(a) >>> b[4:0];
	end
	else begin
	  res = a >> b[4:0];
	end
      end
      3'b110: res = a | b;
      3'b111: res = a & b;
      default: res = 0;
    endcase
  end
  assign ans = (ctr[2:0] == 3'b010) ? {{31{1'b0}}, less} : res;
endmodule

module ysyx_23060221_Exu(
  input         clk      ,
  input         rst      ,
  input  [31:0] src1     ,
  input  [31:0] src2     ,
  input  [31:0] pc       ,
  input  [31:0] imm      ,
  input  [3:0]  aluctr   ,
  input         aluasrc  ,
  input  [1:0]  alubsrc  ,
  input         ca1      ,
  input         ca2      ,
  input         cb1      ,
  input         cb2      ,
  input  [31:0] exlssrc  ,
  input  [31:0] lswbsrc  ,
  output [31:0] res      ,
  output        EXU_ready,
  output        EXU_valid,
  input         LSU_ready,
  input         IDU_valid
  );
  reg EXU_ready_reg, EXU_valid_reg;
  wire syn_IDU_EXU = (IDU_valid & EXU_ready);
  wire syn_EXU_LSU = (EXU_valid & LSU_ready);
  assign EXU_ready = (~EXU_valid | LSU_ready);
  assign EXU_valid = EXU_valid_reg;
  always @(posedge clk) begin
    if (rst) EXU_valid_reg <= 0;
    else if (syn_IDU_EXU) EXU_valid_reg <= 1;
    else if (syn_EXU_LSU) EXU_valid_reg <= 0;
  end

wire [31:0] a, b;

MuxKey #(2, 1, 32)  i1 (a, aluasrc, {
  1'b0, (ca1) ? exlssrc : ((ca2) ? lswbsrc : src1),
  1'b1, pc
});

MuxKey #(3, 2, 32) i2 (b, alubsrc, {
  2'b00, (cb1) ? exlssrc : ((cb2) ? lswbsrc : src2),
  2'b01, imm,
  2'b10, 32'd4
});

Alu a0 (.a (a), .b(b), .ctr(aluctr), .ans(res));

endmodule
