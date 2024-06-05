module ysyx_23060221_Uart(
  input clk,
  input reset,
  output        awready,
  input         awvalid,
  input [31:0]  awaddr ,
  input [3:0]   awid   , 
  input [7:0]   awlen  ,
  input [2:0]   awsize ,
  input [1:0]   awburst,
  output        wready ,
  input         wvalid ,
  input [63:0]  wdata  ,
  input [7:0]   wstrb  ,
  input         wlast  ,
  input         bready ,
  output        bvalid ,
  output [1:0]  bresp  ,
  output [3:0]  bid    ,
  output        arready,
  input         arvalid,
  input [31:0]  araddr ,
  input [3:0]   arid   ,
  input [7:0]   arlen  ,
  input [2:0]   arsize ,
  input [1:0]   arburst,
  input         rready ,
  output        rvalid ,
  output [1:0]  rresp  ,
  output [63:0] rdata  ,
  output        rlast  ,
  output [3:0]  rid    
  );

/*************AXI-master**************/

/*************register**************/
reg wl         ;
reg wen        ;
reg ren        ;

reg [31:0] reg_awaddr ;
reg [7:0]  reg_wstrb  ;
reg        reg_awready;
reg        reg_wready ;
reg [63:0] reg_wdata  ;
reg        reg_arready;
reg [31:0] reg_araddr ;
reg [7:0]  reg_arlen  ;
reg [63:0] reg_rdata  ;
reg [7:0]  read_cnt   ;
reg        reg_rvalid ;
reg        reg_bvalid ;

/*************wire***************/
wire awactive;
wire wactive ;
wire bactive ;
wire aractive;
wire ractive ;

/*************assign**************/
assign awactive    = awvalid & awready    ;
assign wactive     = wvalid  & wready     ;
assign bactive     = bvalid  & bready     ;
assign aractive    = arvalid & arready    ;
assign ractive     = rvalid  & rready     ;

assign awready = reg_awready;
assign wready  = reg_wready ;

assign arready = reg_arready;

assign rvalid  = reg_rvalid;
assign rresp   = 'd0       ;
assign rdata   = reg_rdata ;
assign rlast   = (read_cnt == reg_arlen - 1) ? ractive : 1'b0;
assign rid     = 'd0       ;

assign bvalid  = reg_bvalid;
assign bresp   = 'd0       ;
assign bid     = 'd0       ;


/*************process**************/
always @(posedge clk) begin
  if (awactive)
    reg_awaddr <= awaddr;
  else
    reg_awaddr <= reg_awaddr;
end

always @(posedge clk) begin
  if (awactive)
    reg_wstrb <= wstrb;
  else
    reg_wstrb <= reg_wstrb;
end

always @(posedge clk) begin 
  if (wactive)
    reg_wdata <= wdata;
  else 
    reg_wdata <= reg_wdata;
end

always @(posedge clk) begin
  if (reset)
    reg_awready <= 'd1;
  else if (wlast)
    reg_awready <= 'd1;
  else if (awactive)
    reg_awready <= 'd0;
  else 
    reg_awready <= reg_awready;
end

always @(posedge clk) begin
  if (awactive)
    reg_wready <= 'd1;
  else if (wlast)
    reg_wready <= 'd0;
  else
    reg_wready <= reg_wready;
end

always @(posedge clk) begin
  if (aractive)
    wl <= 'd1;
  else if (awactive)
    wl <= 'd0;
  else 
    wl <= wl;
end

reg flag;
reg wen1, wen0;

always @(posedge clk) begin
  if (flag)
    wen1 <= 0;
  else if (wactive)
    wen1 <= 1;
  else 
    wen1 <= 0;
end

always @(posedge clk) begin
  wen0 <= wen1;
  wen <= wen0;
end

always @(posedge clk) begin
  if (wactive) begin
    flag <='d1;
  end
  else begin
    flag <='d0;
  end
end

always @(posedge clk) begin
  if (!wl & wen & (awaddr == 32'ha00003f8))
    $write("%c", wdata[7:0]);
end

always @(posedge clk) begin
  if (aractive)
    reg_araddr <= araddr;
  else
    reg_araddr <= reg_araddr;
end

always @(posedge clk) begin
  if (rlast)
    reg_arready <= 'd1;
  else if (aractive)
    reg_arready <= 'd0;
  else
    reg_arready <= reg_arready;
end

always @(posedge clk) begin
  if (aractive)
    reg_arlen <= arlen;
  else
    reg_arlen <= reg_arlen;
end

always @(posedge clk) begin
  if (wl & ren)
    reg_rdata <= reg_rdata;
  else
    reg_rdata <= reg_rdata;
end

always @(posedge clk) begin
  if (rlast)
    read_cnt <= 'd0;
  else if (ractive)
    read_cnt <= read_cnt + 1;
  else 
    read_cnt <= read_cnt;
end

always @(posedge clk) begin
  if (aractive)
    ren <= 1;
  else
    ren <= 0;
end

always @(posedge clk) begin
  if (ractive)
    reg_rvalid <= 'd0;
  else if (ren)
    reg_rvalid <= 'd1;
  else 
    reg_rvalid <= reg_rvalid;
end

always @(posedge clk) begin
  if (wlast)
    reg_bvalid <= 'd1;
  else if (bactive)
    reg_bvalid <= 'd0;
  else 
    reg_bvalid <= reg_bvalid;
end

endmodule
