module PC_Gen(
  input [31:0] pc_in,
  input [31:0] rs1,
  input clk,
  input [31:0] imm,
  input PCAsrc, PCBsrc,
  output reg [31:0] pc_out
);
  wire [31:0] tmp1, tmp2;
  MuxKey #(2, 1, 32) p1 (tmp1, PCAsrc, {1'b0, 32'b100, 1'b1, imm});
  MuxKey #(2, 1, 32) p2 (tmp2, PCBsrc, {1'b0, pc_in,   1'b1, rs1});
  always @(posedge clk) begin
    pc_out = tmp1 + tmp2;
  end
endmodule

