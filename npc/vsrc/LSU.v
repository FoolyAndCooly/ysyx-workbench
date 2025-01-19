`ifndef SYNTHESIS
import "DPI-C" function void exu_count(input int addr);
import "DPI-C" function void lsu_begin();
import "DPI-C" function void lsu_end(input int addr);
`endif

module ysyx_23060221_Lsu(
  input         clk, 
  input         rst,
  input [31:0]  res,
  input [31:0]  rs2,
  input [2:0]   memop,
  input         memwr,
  output [31:0] dataout ,
  output        LSU_ready,
  output        LSU_valid,
  input         WBU_ready,
  input         EXU_valid,
  input         awready  ,
  output        awvalid  ,
  output [31:0] awaddr   ,
  output [3:0]  awid     ,
  output [7:0]  awlen    ,
  output [2:0]  awsize   ,
  output [1:0]  awburst  ,
  input         wready   ,
  output        wvalid   ,
  output [31:0] wdata    ,
  output [3:0]  wstrb    ,
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
  input [31:0]  rdata    ,
  input         rlast    ,
  input [3:0]   rid      ,
  output        lswbwen  
);

reg LSU_ready_reg, LSU_valid_reg;
wire syn_EXU_LSU = (EXU_valid & LSU_ready);
wire syn_LSU_WBU = (LSU_valid & WBU_ready);
assign LSU_ready = syn_LSU_WBU | LSU_ready_reg;
assign LSU_valid = LSU_valid_reg;
assign lswbwen = (memop != 3'b111) ? memfinish : syn_EXU_LSU;

always @(posedge clk) begin
  if (rst) LSU_ready_reg <= 1;
  else if (syn_LSU_WBU) LSU_ready_reg <= 1;
  else if (syn_EXU_LSU) LSU_ready_reg <= 0;
end

always @(posedge clk) begin
  if (rst) LSU_valid_reg <= 0;
  else if (memop != 3'b111) begin
    if (memfinish) LSU_valid_reg <= 1;
    else if (syn_LSU_WBU) LSU_valid_reg <= 0;
  end
  else begin
    if (syn_EXU_LSU) LSU_valid_reg <= 1;
    else if (syn_LSU_WBU) LSU_valid_reg <= 0;
  end
end

wire memfinish = (bvalid & bready) | (rvalid & rready);

reg [31:0] data_out;
assign dataout = data_out;

`ifndef SYNTHESIS
// always @(posedge clk) begin
//   if (~rst) begin
//     if (syn_EXU_LSU) begin
//       if (memop == 3'b111) begin
//         exu_count(pc);
//       end else begin
//         lsu_begin();
//       end
//     end
//     else if (memfinish) begin
//       lsu_end(pc);
//     end
//   end
// end
`endif

always @(*) begin 
  case (memop)
    3'b000: begin 
      case (araddr[1:0])
        2'b00: data_out = {{24{rdata[7]}},  rdata[7:0]};
        2'b01: data_out = {{24{rdata[15]}}, rdata[15:8]};
	2'b10: data_out = {{24{rdata[23]}}, rdata[23:16]};
	2'b11: data_out = {{24{rdata[31]}}, rdata[31:24]};
      endcase
    end
    3'b001: begin
      case (araddr[1:0])
        2'b00: data_out = {{16{rdata[15]}}, rdata[15:0]};
        2'b01: data_out = {{16{rdata[23]}}, rdata[23:8]};
	2'b10: data_out = {{16{rdata[31]}}, rdata[31:16]};
	default: begin data_out = 0; end
      endcase
    end
    3'b010: begin
      case (araddr[1:0])
        2'b00: data_out = rdata[31:0];
	default: begin data_out = 0; end
      endcase
    end
    3'b100: begin
      case (araddr[1:0])
        2'b00: data_out = {24'b0, rdata[7:0]};
        2'b01: data_out = {24'b0, rdata[15:8]};
	2'b10: data_out = {24'b0, rdata[23:16]};
	2'b11: data_out = {24'b0, rdata[31:24]};
      endcase
    end
    3'b101: begin
       case (araddr[1:0])
        2'b00: data_out = {16'b0, rdata[15:0]};
        2'b01: data_out = {16'b0, rdata[23:8]};
	2'b10: data_out = {16'b0, rdata[31:16]};
        default: begin data_out = 0; end
      endcase     
    end
    default: begin data_out = 0; end
  endcase
end

/*************AXI-master**************/

/*************register**************/
reg        reg_awvalid;
reg [31:0] reg_awaddr ;
reg        reg_wvalid ;
reg [31:0] reg_wdata  ;
reg        reg_arvalid;
reg [31:0] reg_araddr ;
reg        reg_rready ;
reg        reg_bready ;
reg [3:0]  reg_wstrb  ;

/*************wire***************/
wire wstart;
wire rstart;
wire [3:0] wstrb0;

/*************assign**************/
assign wstart = syn_EXU_LSU & memwr & (memop != 3'b111);
assign rstart = syn_EXU_LSU & ~memwr & (memop != 3'b111) ;

assign awvalid = reg_awvalid;
assign awaddr  = reg_awaddr ;
assign awid    = 'd0        ;    
assign awlen   = 'd0        ;
assign awsize  = {1'b0, memop[1:0]} ;
assign awburst = 2'b00      ;

assign wvalid  = reg_wvalid ;
assign wdata   = reg_wdata  ;
assign wstrb    = reg_wstrb ;
assign wstrb0   = (memop == 3'b000) ? 4'b0001 : ((memop == 3'b001) ? 4'b0011 : 4'b1111);
assign wlast   = wvalid & wready;

assign arvalid = reg_arvalid;
assign araddr  = reg_araddr ;
assign arid    = 'd0        ;
assign arlen   = 'd0        ;
assign arsize  = {1'b0, memop[1:0]} ;
assign arburst = 2'b00      ;

assign rready  = reg_rready ;

assign bready  = 'd1         ;

/*************process**************/

reg [4:0] shift;

always @(*) begin
  shift = {3'b0,awaddr[1:0]} << 3;
  reg_wdata = rs2 << shift; // ?
end

always @(*) begin
  reg_wstrb = wstrb0 << (awaddr[1:0]);
end

always @(posedge clk) begin
  if (rst) reg_awvalid <= 'd0;
  else if (awvalid & awready)
    reg_awvalid <= 'd0;
  else if(wstart)
    reg_awvalid <= 'd1;
  else
    reg_awvalid <= reg_awvalid;
end

always @(posedge clk) begin
  if (wstart) begin
    reg_awaddr <= res;
  end
  else
    reg_awaddr <= reg_awaddr;
end

always @(posedge clk) begin
  if (wlast)
    reg_wvalid <= 'd0;
  else if (wstart)
    reg_wvalid <= 'd1;
  else 
    reg_wvalid <= reg_wvalid;
end

// always @(posedge clk) begin
//   if (bvalid & bready)
//     reg_bready <= 'd0;
//   else if (wlast)
//     reg_bready <= 'd1;
//   else 
//     reg_bready <= reg_bready;
// end

always @(posedge clk) begin
  if (rst) reg_arvalid <= 'd0;
  else if (arvalid & arready)
    reg_arvalid <= 'd0;
  else if (rstart) begin
    reg_arvalid <= 'd1;
  end
  else 
    reg_arvalid <= reg_arvalid;
end

always @(posedge clk) begin
  if (rstart)
    reg_araddr <= res;
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

endmodule
