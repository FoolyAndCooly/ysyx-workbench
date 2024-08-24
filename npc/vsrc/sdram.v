`ifdef NPC
import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input byte wstrb, input int data);
module sdram(
  input        clk      ,
  output       awready  ,
  input        awvalid  ,
  input [31:0] awaddr   ,
  input [3:0]  awid     ,
  input [7:0]  awlen    ,
  input [2:0]  awsize   ,
  input [1:0]  awburst  ,
  output       wready   ,
  input        wvalid   ,
  input [31:0] wdata    ,
  input [3:0]  wstrb    ,
  input        wlast    ,
  input        bready   ,
  output         bvalid   ,
  output  [1:0]  bresp    ,
  output  [3:0]  bid      ,
  output         arready  ,
  input        arvalid  ,
  input [31:0] araddr   ,
  input [3:0]  arid     ,
  input [7:0]  arlen    ,
  input [2:0]  arsize   ,
  input [1:0]  arburst  ,
  input        rready   ,
  output         rvalid   ,
  output [1:0]   rresp    ,
  output [31:0]  rdata    ,
  output         rlast    ,
  output [3:0]   rid      
  );

/*************AXI-master**************/

/*************register**************/
reg [31:0] reg_araddr;
reg        reg_rvalid;
reg [31:0] reg_rdata;
reg [2:0]  reg_arsize;
reg [7:0]   reg_arlen;
reg        reg_rlast;
reg        reg_wready;
reg [31:0] reg_awaddr;

/*************wire***************/
/*************assign**************/
assign arready = arvalid;
assign awready = awvalid;
assign rvalid = reg_rvalid;
assign rdata = reg_rdata;
assign rlast = reg_rlast;
assign wready = reg_wready;
assign bvalid = wready;

/*************process**************/
reg rstate;

always @(posedge clk) begin
  case (rstate)
    1'b0: rstate <= arready & arvalid;
    1'b1: rstate <= ~(reg_arlen == 0);
  endcase
end

always @(posedge clk) begin
  case (rstate)
  1'b0: begin
    reg_rvalid <= 0;
    reg_rlast <= 0;
    reg_arlen <= arlen;
    reg_araddr <= araddr;
  end
  1'b1: begin
    reg_rvalid <= 1;
    reg_arlen <= reg_arlen - 1;
    reg_rdata <= pmem_read(reg_araddr);
    reg_rlast <= (reg_arlen == 0);
  end
  endcase
end

always @(posedge clk) begin
  if (awvalid & awready) begin
    reg_awaddr <= awaddr;
  end
end

always @(posedge clk) begin
  if (wvalid & wready) begin
    pmem_write(reg_awaddr, {4'b0,wstrb}, wdata);
  end
end

always @(posedge clk) begin
  case (reg_wready)
    1'b0: reg_wready <= awvalid & awready;
    1'b1: reg_wready <= ~wlast;
  endcase
end

endmodule
`endif
