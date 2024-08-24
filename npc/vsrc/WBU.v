`define MEPC 2'b00
`define MSTATUS 2'b01
`define MCAUSE 2'b10
`define MTVEC 2'b11

module PC_Gen(
  input rst,
  input [31:0] rs1,
  input [31:0] csrrdata,
  input clk,
  input [31:0] imm,
  input PCAsrc, PCBsrc,
  input csrpc,
  input syn,
  output [31:0] pc_out
);
  reg [31:0] pc;
  assign pc_out = pc;
  wire [31:0] tmp1, tmp2, t2;
  MuxKey #(2, 1, 32) p1 (tmp1, PCAsrc, {1'b0, 32'b100, 1'b1, imm});
  MuxKey #(2, 1, 32) p2 (t2, PCBsrc, {1'b0, pc,   1'b1, rs1});
  assign tmp2 = (csrpc) ? csrrdata : t2;

  Reg #(
    .WIDTH     (32   ),
`ifdef SOC
    .RESET_VAL (32'h30000000)
`else
    .RESET_VAL (32'h80000000)
`endif
  ) u_reg (
    .clk   (clk   ),
    .rst   (rst   ),
    .wen   (syn),
    .din   (tmp1 + tmp2 ),
    .dout  (pc    )
  );

endmodule

module ysyx_23060221_Wbu (
  input rst,
  output reg [31:0] pc,
  input PCAsrc, PCBsrc,
  input [31:0] imm,
  input [31:0] rs1,
  input clk,
  input csrw,
  input regw,
  input csrpc,
  input [31:0] csrrdata,
  output csrwen,
  output regwen,
  input reg EXU_valid,
  input reg IFU_ready,
  output reg WBU_ready,
  output reg WBU_valid
);
  wire syn_EXU_WBU, syn_WBU_IFU;
  assign syn_EXU_WBU = EXU_valid & WBU_ready;
  assign syn_WBU_IFU = WBU_valid & IFU_ready;
  
  always @(posedge clk) begin
    if (rst) begin
      WBU_valid <= 1;
      WBU_ready <= 1;
    end
    else begin
      if (syn_EXU_WBU) begin 
        WBU_ready <= 0;
	WBU_valid <= 1;
      end
      if (syn_WBU_IFU) begin 
        WBU_valid <= 0;
        WBU_ready <= 1;
      end
    end
  end

  PC_Gen pg(
  .rst(rst),
  .rs1(rs1),
  .clk(clk),
  .imm(imm),
  .pc_out(pc),
  .csrrdata(csrrdata),
  .csrpc(csrpc),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .syn(syn_EXU_WBU));

  assign csrwen = syn_EXU_WBU & csrw;
  assign regwen = syn_EXU_WBU & regw;
endmodule

