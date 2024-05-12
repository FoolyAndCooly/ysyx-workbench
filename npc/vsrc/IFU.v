module PC_Gen(
  input reg [31:0] pc_in,
  input [31:0] rs1,
  input clk,
  input [31:0] imm,
  input PCAsrc, PCBsrc,
  input WBU_finish,
  output reg [31:0] pc_out,
  input state
);
  wire [31:0] tmp1, tmp2;
  MuxKey #(2, 1, 32) p1 (tmp1, PCAsrc, {1'b0, 32'b100, 1'b1, imm});
  MuxKey #(2, 1, 32) p2 (tmp2, PCBsrc, {1'b0, pc_in,   1'b1, rs1});
  always @(posedge clk) begin
    if (state & WBU_finish) pc_out <= tmp1 + tmp2;
    $display("change pc");
  end
endmodule

module Sram(
  input reg [31:0] pc,
  input clk,
  output reg [31:0] rdata,
  input state,
  input WBU_finish,
  output reg IFU_valid
  );
  always @(posedge clk) begin
    $strobe("%08x", pc);
    if (state & WBU_finish) begin
      //rdata <= pmem_read(pc, 4);
      IFU_valid <= 1;
      $display("ifu");
    end
  end
endmodule

module Ifu(
  input [31:0] rs1,
  input clk,
  input [31:0] imm,
  input PCAsrc, PCBsrc,
  input reg WBU_finish,
  input reg IDU_ready,
  output reg IFU_valid,
  output reg [31:0] pc,
  output reg [31:0] inst
  );
  reg state_in, state_out;
  parameter [0:0] wready = 0, idle = 1;
  MuxKey #(2, 1, 1) si (state_out, state_in, {
    wready, IDU_ready ? idle : wready,
    idle, IFU_valid ? wready : idle
  });
  wire syn_IFU_IDU;
  assign syn_IFU_IDU = IFU_valid & IDU_ready; 
  always @(posedge clk) begin
    state_in <= state_out;
  end
  
  always @(posedge clk) begin
    if (syn_IFU_IDU) IFU_valid <= 0;
  end

  Sram sr(.pc(pc), .clk(clk), .rdata(inst), .state(state_in),
  .IFU_valid(IFU_valid),
  .WBU_finish(WBU_finish));

  PC_Gen pg(
  .pc_in(pc),
  .rs1(rs1),
  .clk(clk),
  .imm(imm),
  .pc_out(pc),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .state(state_in),
  .WBU_finish(WBU_finish));
endmodule

