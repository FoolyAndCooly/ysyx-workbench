module ysyx_23060221_Arbiter(
  input clk,
  input rst,
  output        ifu_arready,
  input         ifu_arvalid,
  input [31:0]  ifu_araddr ,
  input [3:0]   ifu_arid   ,
  input [7:0]   ifu_arlen  ,
  input [2:0]   ifu_arsize ,
  input [1:0]   ifu_arburst,
  input         ifu_rready ,
  output        ifu_rvalid ,
  output [1:0]  ifu_rresp  ,
  output [31:0] ifu_rdata  ,
  output        ifu_rlast  ,
  output [3:0]  ifu_rid    ,
  output        lsu_awready,
  input         lsu_awvalid,
  input [31:0]  lsu_awaddr ,
  input [3:0]   lsu_awid   ,
  input [7:0]   lsu_awlen  ,
  input [2:0]   lsu_awsize ,
  input [1:0]   lsu_awburst,
  output        lsu_wready ,
  input         lsu_wvalid ,
  input [31:0]  lsu_wdata  ,
  input [3:0]   lsu_wstrb  ,
  input         lsu_wlast  ,
  input         lsu_bready ,
  output        lsu_bvalid ,
  output [1:0]  lsu_bresp  ,
  output [3:0]  lsu_bid    ,
  output        lsu_arready,
  input         lsu_arvalid,
  input [31:0]  lsu_araddr ,
  input [3:0]   lsu_arid   ,
  input [7:0]   lsu_arlen  ,
  input [2:0]   lsu_arsize ,
  input [1:0]   lsu_arburst,
  input         lsu_rready ,
  output        lsu_rvalid ,
  output [1:0]  lsu_rresp  ,
  output [31:0] lsu_rdata  ,
  output        lsu_rlast  ,
  output [3:0]  lsu_rid    ,
  input         io_master_awready,
  output        io_master_awvalid,
  output [31:0] io_master_awaddr ,
  output [3:0]  io_master_awid   ,
  output [7:0]  io_master_awlen  ,
  output [2:0]  io_master_awsize ,
  output [1:0]  io_master_awburst,
  input         io_master_wready ,
  output        io_master_wvalid ,
  output [31:0] io_master_wdata  ,
  output [3:0]  io_master_wstrb  ,
  output        io_master_wlast  ,
  output        io_master_bready ,
  input         io_master_bvalid ,
  input  [1:0]  io_master_bresp  ,
  input  [3:0]  io_master_bid    ,
  input         io_master_arready,
  output        io_master_arvalid,
  output [31:0] io_master_araddr ,
  output [3:0]  io_master_arid   ,
  output [7:0]  io_master_arlen  ,
  output [2:0]  io_master_arsize ,
  output [1:0]  io_master_arburst,
  output        io_master_rready ,
  input         io_master_rvalid ,
  input [1:0]   io_master_rresp  ,
  input [31:0]  io_master_rdata  ,
  input         io_master_rlast  ,
  input [3:0]   io_master_rid    ,
  input         clint_awready,
  output        clint_awvalid,
  output [31:0] clint_awaddr ,
  output [3:0]  clint_awid   ,
  output [7:0]  clint_awlen  ,
  output [2:0]  clint_awsize ,
  output [1:0]  clint_awburst,
  input         clint_wready ,
  output        clint_wvalid ,
  output [31:0] clint_wdata  ,
  output [3:0]  clint_wstrb  ,
  output        clint_wlast  ,
  output        clint_bready ,
  input         clint_bvalid ,
  input  [1:0]  clint_bresp  ,
  input  [3:0]  clint_bid    ,
  input         clint_arready,
  output        clint_arvalid,
  output [31:0] clint_araddr ,
  output [3:0]  clint_arid   ,
  output [7:0]  clint_arlen  ,
  output [2:0]  clint_arsize ,
  output [1:0]  clint_arburst,
  output        clint_rready ,
  input         clint_rvalid ,
  input [1:0]   clint_rresp  ,
  input [31:0]  clint_rdata  ,
  input         clint_rlast  ,
  input [3:0]   clint_rid
);
  wire ifu_fast = ifu_arvalid;
  wire lsu_fast = lsu_arvalid | lsu_awvalid;
  wire ifu_done = (ifu_rvalid & ifu_rready);
  wire lsu_done = (lsu_rvalid & lsu_rready) | (lsu_bvalid & lsu_bready);
`ifdef NPC
  wire clint_fast = (lsu_arvalid &
                      (lsu_araddr == 32'ha0000048 |
		       lsu_araddr == 32'ha000004c));
  wire io_fast   = ifu_arvalid | (lsu_arvalid &
                     (lsu_araddr != 32'ha0000048 &
		      lsu_araddr != 32'ha000004c)) | lsu_awvalid;
`else
  wire clint_fast = (lsu_arvalid &
                      (lsu_araddr == 32'h02000000 |
		       lsu_araddr == 32'h02000004));
  wire io_fast   = ifu_arvalid | (lsu_arvalid &
                     (lsu_araddr != 32'h02000000 &
		      lsu_araddr != 32'h02000004)) | lsu_awvalid;
`endif
  wire clint_done = (clint_rvalid & clint_rready);
  wire io_done = (io_master_rvalid & io_master_rready) | (io_master_bvalid & io_master_bready);

// 0: DEV1, 1: DEV2
// assign mst = (ifu_fast) ? 0 : ((lsu_fast) ? 1 : master);
// always @(posedge clk) begin
//   if (ifu_arvalid) master <= 0;
//   else if (lsu_arvalid | lsu_awvalid) master <= 1;
//   if (clint) slaver <= 1;
//   else if (clint_rvalid & clint_rready) slaver <= 0;
// end

wire [1:0] mst = (master == IDLE) ? (ifu_fast ? 2'b01 : (lsu_fast ? 2'b10 : 2'b00)) : master;

typedef enum reg [1:0] {
  IDLE = 2'b00,
  DEV1  = 2'b01, // DEV1, DEV1
  DEV2  = 2'b10  // DEV2, DEV2
} state_t;

state_t master, next_master;

always @(posedge clk or posedge rst) begin
    if (rst)
        master <= IDLE; 
    else
        master <= next_master;
end

always @(*) begin
  case (master) 
    IDLE: begin
      if (ifu_fast) 
        next_master = DEV1;
      else if (lsu_fast)
        next_master = DEV2;
      else
        next_master = IDLE;
    end
    DEV1: begin
      if (ifu_done) begin
        if (lsu_fast)
          next_master = DEV2;
	else 
	  next_master = IDLE;
      end
      else begin 
        next_master = DEV1;
      end
    end
    DEV2: begin
      if (lsu_done) begin
        if (ifu_fast)
          next_master = DEV1;
	else 
	  next_master = IDLE;
      end
      else begin 
        next_master = DEV2;
      end
    end
    default:
      next_master = master;
  endcase
end

wire [1:0] slv = (slaver == IDLE) ? (io_fast ? 2'b01 : (clint_fast ? 2'b10 : 2'b00)) : slaver;

state_t slaver, next_slaver;

always @(posedge clk or posedge rst) begin
    if (rst)
        slaver <= IDLE; 
    else
        slaver <= next_slaver;
end

always @(*) begin
  case (slaver) 
    IDLE: begin
      if (io_fast) 
        next_slaver = DEV1;
      else if (clint_fast)
        next_slaver = DEV2;
      else
        next_slaver = IDLE;
    end
    DEV1: begin
      if (io_done) begin
        if (clint_fast)
          next_slaver = DEV2;
	else 
	  next_slaver = IDLE;
      end
      else begin 
        next_slaver = DEV1;
      end
    end
    DEV2: begin
      if (clint_done) begin
        if (io_fast)
          next_slaver = DEV1;
	else 
	  next_slaver = IDLE;
      end
      else begin 
        next_slaver = DEV2;
      end
    end
    default: 
      next_master = master;
  endcase
end


wire        awvalid; 
wire [31:0] awaddr ;
wire [3:0]  awid   ;
wire [7:0]  awlen  ;
wire [2:0]  awsize ;
wire [1:0]  awburst;
wire        wvalid ;
wire [31:0] wdata  ;
wire [3:0]  wstrb  ;
wire        wlast  ;
wire        bready ;
wire        arvalid;
wire [31:0] araddr ;
wire [3:0]  arid   ;
wire [7:0]  arlen  ;
wire [2:0]  arsize ;
wire [1:0]  arburst;
wire        rready ;

wire        awready;
wire        wready ;
wire        bvalid ;
wire [1:0]  bresp  ;
wire [3:0]  bid    ;
wire        arready;
wire        rvalid ;
wire [1:0]  rresp  ;
wire [31:0] rdata  ;
wire        rlast  ;
wire [3:0]  rid    ;

assign io_master_awvalid = (slv == DEV1) ? awvalid : 0; 
assign io_master_awaddr  = (slv == DEV1) ? awaddr  : 0;
assign io_master_awid    = (slv == DEV1) ? awid    : 0;
assign io_master_awlen   = (slv == DEV1) ? awlen   : 0;
assign io_master_awsize  = (slv == DEV1) ? awsize  : 0;
assign io_master_awburst = (slv == DEV1) ? awburst : 0;
assign io_master_wvalid  = (slv == DEV1) ? wvalid  : 0;
assign io_master_wdata   = (slv == DEV1) ? wdata   : 0;
assign io_master_wstrb   = (slv == DEV1) ? wstrb   : 0;
assign io_master_wlast   = (slv == DEV1) ? wlast   : 0;
assign io_master_bready  = (slv == DEV1) ? bready  : 0;
assign io_master_arvalid = (slv == DEV1) ? arvalid : 0;
assign io_master_araddr  = (slv == DEV1) ? araddr  : 0;
assign io_master_arid    = (slv == DEV1) ? arid    : 0;
assign io_master_arlen   = (slv == DEV1) ? arlen   : 0;
assign io_master_arsize  = (slv == DEV1) ? arsize  : 0;
assign io_master_arburst = (slv == DEV1) ? arburst : 0;
assign io_master_rready  = (slv == DEV1) ? rready  : 0;

assign clint_bready  =  (slv == DEV2) ? bready  : 0;
assign clint_arvalid =  (slv == DEV2) ? arvalid : 0;
assign clint_araddr  =  (slv == DEV2) ? araddr  : 0;
assign clint_arid    =  (slv == DEV2) ? arid    : 0;
assign clint_arlen   =  (slv == DEV2) ? arlen   : 0;
assign clint_arsize  =  (slv == DEV2) ? arsize  : 0;
assign clint_arburst =  (slv == DEV2) ? arburst : 0;
assign clint_rready  =  (slv == DEV2) ? rready  : 0;

assign awvalid = (mst == DEV2) ? lsu_awvalid : 0; 
assign awaddr  = (mst == DEV2) ? lsu_awaddr  : 0;
assign awid    = (mst == DEV2) ? lsu_awid    : 0;
assign awlen   = (mst == DEV2) ? lsu_awlen   : 0;
assign awsize  = (mst == DEV2) ? lsu_awsize  : 0;
assign awburst = (mst == DEV2) ? lsu_awburst : 0;
assign wvalid  = (mst == DEV2) ? lsu_wvalid  : 0;
assign wdata   = (mst == DEV2) ? lsu_wdata   : 0;
assign wstrb   = (mst == DEV2) ? lsu_wstrb   : 0;
assign wlast   = (mst == DEV2) ? lsu_wlast   : 0;
assign bready  = (mst == DEV2) ? lsu_bready  : 0;
assign arvalid = (mst == DEV2) ? lsu_arvalid : ((mst == DEV1) ? ifu_arvalid : 0);
assign araddr  = (mst == DEV2) ? lsu_araddr  : ((mst == DEV1) ? ifu_araddr  : 0);
assign arid    = (mst == DEV2) ? lsu_arid    : ((mst == DEV1) ? ifu_arid    : 0);
assign arlen   = (mst == DEV2) ? lsu_arlen   : ((mst == DEV1) ? ifu_arlen   : 0);
assign arsize  = (mst == DEV2) ? lsu_arsize  : ((mst == DEV1) ? ifu_arsize  : 0);
assign arburst = (mst == DEV2) ? lsu_arburst : ((mst == DEV1) ? ifu_arburst : 0);
assign rready  = (mst == DEV2) ? lsu_rready  : ((mst == DEV1) ? ifu_rready  : 0);

assign awready = (slv == DEV2) ? clint_awready : ((slv == DEV1) ?  io_master_awready : 0); 
assign wready  = (slv == DEV2) ? clint_wready  : ((slv == DEV1) ?  io_master_wready  : 0); 
assign bvalid  = (slv == DEV2) ? clint_bvalid  : ((slv == DEV1) ?  io_master_bvalid  : 0); 
assign bresp   = (slv == DEV2) ? clint_bresp   : ((slv == DEV1) ?  io_master_bresp   : 0); 
assign bid     = (slv == DEV2) ? clint_bid     : ((slv == DEV1) ?  io_master_bid     : 0); 
assign arready = (slv == DEV2) ? clint_arready : ((slv == DEV1) ?  io_master_arready : 0); 
assign rvalid  = (slv == DEV2) ? clint_rvalid  : ((slv == DEV1) ?  io_master_rvalid  : 0); 
assign rresp   = (slv == DEV2) ? clint_rresp   : ((slv == DEV1) ?  io_master_rresp   : 0); 
assign rdata   = (slv == DEV2) ? clint_rdata   : ((slv == DEV1) ?  io_master_rdata   : 0); 
assign rlast   = (slv == DEV2) ? clint_rlast   : ((slv == DEV1) ?  io_master_rlast   : 0); 
assign rid     = (slv == DEV2) ? clint_rid     : ((slv == DEV1) ?  io_master_rid     : 0); 

assign ifu_arready = (mst == DEV1) ? arready : 0;    
assign ifu_rvalid  = (mst == DEV1) ? rvalid  : 0;    
assign ifu_rresp   = (mst == DEV1) ? rresp   : 0;    
assign ifu_rdata   = (mst == DEV1) ? rdata   : 0;    
assign ifu_rlast   = (mst == DEV1) ? rlast   : 0;    
assign ifu_rid     = (mst == DEV1) ? rid     : 0;    

assign lsu_awready = (mst == DEV2) ? awready : 0;
assign lsu_wready  = (mst == DEV2) ? wready  : 0;
assign lsu_bvalid  = (mst == DEV2) ? bvalid  : 0;
assign lsu_bresp   = (mst == DEV2) ? bresp   : 0;
assign lsu_bid     = (mst == DEV2) ? bid     : 0;
assign lsu_arready = (mst == DEV2) ? arready : 0;
assign lsu_rvalid  = (mst == DEV2) ? rvalid  : 0;
assign lsu_rresp   = (mst == DEV2) ? rresp   : 0;
assign lsu_rdata   = (mst == DEV2) ? rdata   : 0;
assign lsu_rlast   = (mst == DEV2) ? rlast   : 0;
assign lsu_rid     = (mst == DEV2) ? rid     : 0;

endmodule
