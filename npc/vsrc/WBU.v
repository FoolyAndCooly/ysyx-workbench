`define MEPC 2'b00
`define MSTATUS 2'b01
`define MCAUSE 2'b10
`define MTVEC 2'b11

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
      pc_out <= 32'h20000000;
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
  input reg [31:0] rf_in[31:0],
  output reg [31:0] rf_out[31:0],
  input reg [31:0] csr_in[3:0],
  output reg [31:0] csr_out[3:0],
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
  always @(posedge clk) begin
    if (rst) begin
      WBU_valid <= 1;
      csr_out[0] <= 0;
      csr_out[1] <= 32'h1800;
      csr_out[2] <= 0;
      csr_out[3] <= 0;
      for (int i = 0; i < 32; i++) begin
        rf_out[i] <= 0;
      end
    end
    else begin
      if (syn_EXU_WBU) begin
        WBU_valid <= 1;
        if (wen && (waddr != 0)) begin
          rf_out[waddr] <= wdata;
        end
        if (CSRctr != 0 && CSRctr != 3'b100) begin
          case (CSRctr)
            3'b001: begin
              csr_out[`MCAUSE] <= 11;
              csr_out[`MEPC] <= wdata;
            end
            3'b010: begin
                if (waddr != 0) rf_out[waddr] <= csr_in[csr_num];
                csr_out[csr_num] <= rf_in[Ra];
            end
            3'b011: begin
                if (waddr != 0) rf_out[waddr] <= csr_in[csr_num]; 
                csr_out[csr_num] <= rf_in[Ra] | csr_in[csr_num];
            end
	    default: csr_out[csr_num] <= csr_out[csr_num];
          endcase
        end
      end 
    end
  end
endmodule

