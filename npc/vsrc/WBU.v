`define MEPC 2'b00
`define MSTATUS 2'b01
`define MCAUSE 2'b10
`define MTVEC 2'b11
`ifndef SYNTHESIS
import "DPI-C" function void next(input int valid);
`endif

module ysyx_23060221_Wbu (
  input         clk,
  input         rst,
  input [31:0]  res,
  input [31:0]  dataout,
  input         memtoreg,
  input         regw,
  output        regwen,
  output [31:0] wd,
  output        WBU_ready,
  input         LSU_valid
);

`ifndef SYNTHESIS
always @(posedge clk) begin
  if (~rst) next({31'b0, wen});  
end
`endif

wire syn_LSU_WBU = WBU_ready & LSU_valid;
reg wen;
always @(posedge clk) begin
  if (rst) wen <= 0;
  else wen <= syn_LSU_WBU;
end
assign WBU_ready = 1;
assign wd = (memtoreg) ? dataout : res;
assign regwen = wen & regw;
endmodule

