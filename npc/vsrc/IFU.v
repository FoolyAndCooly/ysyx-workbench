`ifndef SYNTHESIS
import "DPI-C" function void ifu_count();
`endif
module ysyx_23060221_Ifu(
  input             clk  ,
  input             rst  ,
  input  [31:0]       pc ,
  output [31:0]      inst,
  input  reg    WBU_valid,
  input  reg    IDU_ready,
  output reg    IFU_valid,
  output reg    IFU_ready,
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
  input [31:0]  rdata    ,
  input         rlast    ,
  input [3:0]   rid      
  );

/*************control**************/
wire syn_IFU_IDU, syn_WBU_IFU;
wire memfinish;
assign syn_IFU_IDU = IFU_valid & IDU_ready; 
assign syn_WBU_IFU = WBU_valid & IFU_ready;

always @(posedge clk) begin
  // $strobe("IFU_valid %d", IFU_valid);
  // $strobe("WBU_valid %d", WBU_valid);
  // $strobe("IFU_ready %d", IFU_ready);
  if (rst) begin
    IFU_ready <= 1;
  end
  else begin
    if (syn_WBU_IFU) begin 
      IFU_ready <= 0;
      // $display("IFU");
    end
    if (syn_IFU_IDU) begin 
      IFU_valid <= 0;
      IFU_ready <= 1;
    end
  end
end

always @(posedge clk) begin
  if (rst)
    IFU_valid <= 0;
  else if (memfinish) begin
    IFU_valid <= 1;
`ifndef SYNTHESIS
    ifu_count();
`endif
  end
end

assign memfinish = (rvalid & rready);

/*************AXI-master**************/

/*************register**************/
reg        reg_arvalid;
reg [31:0] reg_araddr ;
reg        reg_rready ;
reg [31:0] reg_rdata  ;

/*************wire***************/
wire rstart;
/*************assign**************/
assign inst = reg_rdata[31:0];

assign rstart = syn_WBU_IFU;

assign arvalid = reg_arvalid;
assign araddr  = reg_araddr ;
assign arid    = 'd0        ;
assign arsize  = 3'b010     ;
assign arlen   = 'd0        ;
assign arburst = 2'b00      ;

assign rready  = reg_rready ;

/*************process**************/

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

always @(posedge clk) begin
  if (rvalid & rready)
    reg_rdata <= rdata;
  else 
    reg_rdata <= reg_rdata;
end

endmodule

