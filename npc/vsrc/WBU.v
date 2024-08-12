`define MEPC 2'b00
`define MSTATUS 2'b01
`define MCAUSE 2'b10
`define MTVEC 2'b11
`define WADDR waddr_shift+:32
`define CSR   csr_shift+:32
`define RA    ra_shift+:32

module PC_Gen(
  input rst,
  input reg [31:0] pc_in,
  input [31:0] rs1,
  input clk,
  input [31:0] imm,
  input PCAsrc, PCBsrc,
  input syn,
  output reg [31:0] pc_out
);
  wire [31:0] tmp1, tmp2;
  MuxKey #(2, 1, 32) p1 (tmp1, PCAsrc, {1'b0, 32'b100, 1'b1, imm});
  MuxKey #(2, 1, 32) p2 (tmp2, PCBsrc, {1'b0, pc_in,   1'b1, rs1});
  always @(posedge clk) begin
    if (rst)
      pc_out <= 32'h30000000;
    else begin
      if (syn) begin 
        pc_out <= tmp1 + tmp2;
      end
    end
    // $display("pc: %08x", pc_out);
  end
endmodule

module ysyx_23060221_Wbu (
  input rst,
  input [31:0] wdata,
  input [4:0] waddr,
  input [31:0] rs1,
  input [31:0] imm,
  output reg [31:0] pc,
  input PCAsrc, PCBsrc,
  input clk,
  input wen,
  input [4:0] Ra,
  input reg [1023:0] rf_in,
  output reg [1023:0] rf_out,
  input reg [127:0] csr_in,
  output reg [127:0] csr_out,
  input reg EXU_valid,
  input reg IFU_ready,
  input [2:0] CSRctr,
  output reg WBU_ready,
  output reg WBU_valid
);
  wire syn_EXU_WBU, syn_WBU_IFU;
  assign syn_EXU_WBU = EXU_valid & WBU_ready;
  assign syn_WBU_IFU = WBU_valid & IFU_ready;
  
  always @(posedge clk) begin
    if (rst) begin
      WBU_valid <= 0;
      WBU_ready <= 1;
    end
    else begin
      if (syn_EXU_WBU) begin 
        // $display("WBU");
        WBU_ready <= 0;
      end
      if (syn_WBU_IFU) begin 
        WBU_valid <= 0;
        WBU_ready <= 1;
      end
    end
  end

  PC_Gen pg(
  .rst(rst),
  .pc_in(pc),
  .rs1(rs1),
  .clk(clk),
  .imm(imm),
  .pc_out(pc),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .syn(syn_EXU_WBU));

  wire [1:0] csr_num;
  MuxKey #(4, 32, 2) i (csr_num, wdata, {
    32'h300, `MSTATUS,
    32'h305, `MTVEC,
    32'h341, `MEPC,
    32'h342, `MCAUSE
  });

  wire [9:0] waddr_shift = {5'b0, waddr} << 5;
  wire [9:0] ra_shift = {5'b0, Ra} << 5;
  wire [6:0] csr_shift = {5'b0, csr_num} << 5;
  always @(posedge clk) begin
    if (rst) begin
      WBU_valid <= 1;
      csr_out[31:0] <= 0;
      csr_out[63:32] <= 32'h1800;
      csr_out[95:64] <= 0;
      csr_out[127:96] <= 0;
      rf_out[1023:0] <= 0;
    end
    else begin
      if (syn_EXU_WBU) begin
        WBU_valid <= 1;
        if (wen && (waddr != 0)) begin
          rf_out[`WADDR] <= wdata;
        end
        if (CSRctr != 0 && CSRctr != 3'b100) begin
          case (CSRctr)
            3'b001: begin
              csr_out[{5'b0,`MCAUSE}<<5+:32] <= 11;
              csr_out[{5'b0,`MEPC}<<5+:32] <= wdata;
            end
            3'b010: begin
                if (waddr != 0) rf_out[`WADDR] <= csr_in[`CSR];
                csr_out[`CSR] <= rf_in[`RA];
            end
            3'b011: begin
                if (waddr != 0) rf_out[`WADDR] <= csr_in[`CSR]; 
                csr_out[`CSR] <= rf_in[`RA] | csr_in[`CSR];
            end
	    default: csr_out[`CSR] <= csr_out[`CSR];
          endcase
        end
      end 
    end
  end
endmodule

