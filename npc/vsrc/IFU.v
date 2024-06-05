module ysyx_23060221_Ifu(
  input             clk  ,
  input [31:0]       pc  ,
  input  reg    WBU_valid,
  input  reg    IDU_ready,
  output reg    IFU_valid,
  output reg    IFU_ready,
  input         awready  ,
  output        awvalid  ,
  output [31:0] awaddr   ,
  output [3:0]  awid     ,
  output [7:0]  awlen    ,
  output [2:0]  awsize   ,
  output [1:0]  awburst  ,
  input         wready   ,
  output        wvalid   ,
  output [63:0] wdata    ,
  output [7:0]  wstrb    ,
  output        wlast    ,
  output        bready   ,
  input         bvalid   ,
  input  [1:0]  bresp    ,
  input  [3:0]  bid      ,
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
  input [63:0]  rdata    ,
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
  if (syn_WBU_IFU) IFU_ready <= 0;
  if (syn_IFU_IDU) begin 
    IFU_valid <= 0;
    IFU_ready <= 1;
  end
end

assign memfinish = (bvalid & bready) | (rvalid & rready);
always @(posedge clk) begin
  if (memfinish) begin
    IFU_valid <= 1;
  end
end
/*************AXI-master**************/

/*************register**************/
reg        reg_awvalid;
reg [31:0] reg_awaddr ;
reg        reg_wvalid ;
reg [63:0] reg_wdata  ;
reg        reg_arvalid;
reg [31:0] reg_araddr ;
reg        reg_rready ;
reg [63:0] reg_rdata  ;
reg        reg_bready ;

/*************wire***************/
wire wstart;
wire rstart;
/*************assign**************/
assign wstart = 0;
assign rstart = syn_WBU_IFU;

assign awvalid = reg_awvalid;
assign awaddr  = reg_awaddr ;
assign awid    = 'd0        ;    
assign awlen   = 'd1        ;
assign awsize  = 3'b010     ;
assign awburst = 2'b01      ;

assign wvalid  = reg_wvalid ;
assign wdata   = reg_wdata  ;
assign wstrb   = 8'b00001111;
assign wlast   = wvalid & wready;

assign arvalid = reg_arvalid;
assign araddr  = reg_araddr ;
assign arid    = 'd0        ;
assign arsize  = 3'b010     ;
assign arlen   = 'd1        ;
assign arburst = 2'b01      ;

assign rready  = reg_rready ;

assign bready  = reg_bready ;

/*************process**************/

always @(posedge clk) begin
  if (awvalid & awready) begin 
    reg_awvalid <= 'd0;
  end
  else if(wstart)
    reg_awvalid <= 'd1;
  else
    reg_awvalid <= reg_awvalid;
end

always @(posedge clk) begin
  if (wstart) 
    reg_awaddr <= 'd0;
  else
    reg_awaddr <= reg_awaddr;
end

always @(posedge clk) begin
  if (wlast)
    reg_wvalid <= 'd0;
  else if (awvalid & awready)
    reg_wvalid <= 'd1;
  else 
    reg_wvalid <= reg_wvalid;
end

always @(posedge clk) begin
  if (wvalid & wready)
    reg_wdata <= 'd0;
  else 
    reg_wdata <= reg_wdata;
end

always @(posedge clk) begin
  if (bvalid & bready)
    reg_bready <= 'd0;
  else if (wlast)
    reg_bready <= 'd1;
  else 
    reg_bready <= reg_bready;
end

always @(posedge clk) begin
  if (arvalid & arready)
    reg_arvalid <= 'd0;
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
  else if (arvalid & arready)
    reg_rready <= 'd1;
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

