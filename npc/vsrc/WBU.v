`define MEPC 2'b00
`define MSTATUS 2'b01
`define MCAUSE 2'b10
`define MTVEC 2'b11
module Wbu (
  input [31:0] wdata,
  input [4:0] waddr,
  input clk,
  input wen,
  input [4:0] Ra,
  input reg [31:0] rf_in[31:0],
  output reg [31:0] rf_out[31:0],
  input reg [31:0] csr_in[3:0],
  output reg [31:0] csr_out[3:0],
  input reg EXU_valid,
  input [2:0] CSRctr,
  output reg WBU_ready,
  output reg WBU_finish
);
  wire syn_EXU_WBU;
  assign syn_EXU_WBU = EXU_valid & WBU_ready;
  
  wire [1:0] csr_num;
  MuxKey #(4, 32, 2) i (csr_num, wdata, {
    32'h300, `MSTATUS,
    32'h305, `MTVEC,
    32'h341, `MEPC,
    32'h342, `MCAUSE
  });
  always @(posedge clk) begin
    if (syn_EXU_WBU) begin
      WBU_ready = 0;
      WBU_finish = 0;
      if (wen && (waddr != 0)) begin
        rf_out[waddr] = wdata;
      end
      if (CSRctr != 0 && CSRctr != 3'b100) begin
        case (CSRctr)
          3'b001: begin
            csr_out[`MCAUSE] = 11;
            csr_out[`MEPC] = wdata;
          end
          3'b010: begin
              if (waddr != 0) rf_out[waddr] = csr_in[csr_num];
              csr_out[csr_num] = rf_in[Ra];
          end
          3'b011: begin
              if (waddr != 0) rf_out[waddr] = csr_in[csr_num]; 
              csr_out[csr_num] = rf_in[Ra] | csr_in[csr_num];
          end
          default: set_npc_state(2);
        endcase
      end
      WBU_ready = 1;
      WBU_finish = 1;
    end 
    else WBU_finish = 0;
  end
endmodule

