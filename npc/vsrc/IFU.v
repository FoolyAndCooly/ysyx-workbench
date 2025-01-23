`ifndef SYNTHESIS
import "DPI-C" function void ifu_count(input int addr);
`endif

module PC_Gen(
  input clk,
  input rst,
  input PCAsrc, PCBsrc,
  input syn,
  input [31:0] rs1,
  input [31:0] imm,
  input [31:0] pc_in,
  output [31:0] pc_out
);
  reg [31:0] pc;
  assign pc_out = pc;

  always @(posedge clk) begin
    if (rst) begin 
  `ifdef SOC
      pc <= 32'h30000000;
  `else
      pc <= 32'h80000000;
  `endif
    end
    else if (syn) begin
      pc <= (PCAsrc) ? (imm + ((PCBsrc) ? rs1 : (pc_in))) : (pc + 4);
    end
  end
endmodule

module ysyx_23060221_Ifu(
  input             clk  ,
  input             rst  ,
  input  [31:0]       pc ,
  input         IDU_ready,
  output        IFU_valid,
  input         arready  ,
  output        arvalid  ,
  output [31:0] araddr   ,
  output [3:0]  arid     ,
  output [7:0]  arlen    ,
  output [2:0]  arsize   ,
  output [1:0]  arburst  ,
  output        rready   ,
  input         rvalid   ,
  input [1:0]   rresp    ,
  input         rlast    ,
  input [3:0]   rid      ,
  input         stall    
  );

/*************control**************/
wire syn_IFU_IDU = IFU_valid & IDU_ready;
assign IFU_valid = ((rvalid & rready) | IFU_valid_reg) & ~stall;
reg IFU_valid_reg;
always @(posedge clk) begin
  if (rst) IFU_valid_reg <= 0;
  else if ((IFU_valid_reg == 0) & stall) IFU_valid_reg <= (rvalid & rready);
  else if (syn_IFU_IDU) begin 
    IFU_valid_reg <= 0;
`ifndef SYNTHESIS
    ifu_count(pc);
`endif
  end
  else IFU_valid_reg <= IFU_valid_reg;
end

/*************AXI-master**************/

/*************register**************/
reg        reg_arvalid;
reg [31:0] reg_araddr ;
reg        reg_rready ;

/*************wire***************/
wire rstart;
/*************assign**************/

assign rstart =  start;
assign arvalid = reg_arvalid;
assign araddr  = reg_araddr ;
assign arid    = 'd0        ;
assign arsize  = 3'b010     ;
assign arlen   = 'd0        ;
assign arburst = 2'b00      ;

assign rready  = reg_rready ;

/*************process**************/

reg start;
always @(posedge clk) begin
  if (rst) start <= rst;
  else if (syn_IFU_IDU) start <= 1;
  else if (start) start <= 0;
end

always @(posedge clk) begin
  if (rst) reg_arvalid <= 'd0;
  else if (arvalid & arready) begin
    reg_arvalid <= 'd0;
  end
  else if (rstart)
    reg_arvalid <= 'd1;
  else 
    reg_arvalid <= reg_arvalid;
end

always @(posedge clk) begin
  if (rstart)
    reg_araddr <= pc;
  else 
    reg_araddr <= reg_araddr;
end

always @(posedge clk) begin
  if (rlast)
    reg_rready <= 'd0;
  else if (arvalid & arready) begin
    reg_rready <= 'd1;
  end
  else 
    reg_rready <= reg_rready;
end

endmodule

