module ysyx_23060221_Arbiter(
  input clk,
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
  wire ifu_fast, lsu_fast, mst, clint, slv;
  reg master, slaver;

  assign ifu_fast = ifu_arvalid;
  assign lsu_fast = lsu_arvalid | lsu_awvalid;
`ifdef NPC
  assign clint = (lsu_arvalid &
                 (lsu_araddr == 32'ha0000048 |
		  lsu_araddr == 32'ha000004c));
`else
  assign clint = (lsu_arvalid &
                 (lsu_araddr == 32'h02000000 |
		  lsu_araddr == 32'h02000004));
`endif
  assign slv = (clint) ? 1 : slaver;
  assign mst = (ifu_fast) ? 0 : ((lsu_fast) ? 1 : master);
  always @(posedge clk) begin
    if (ifu_arvalid) master <= 0;
    else if (lsu_arvalid | lsu_awvalid) master <= 1;
    if (clint) slaver <= 1;
    else if (clint_rvalid & clint_rready) slaver <= 0;
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

assign io_master_awvalid =  awvalid; 
assign io_master_awaddr  =  awaddr ;
assign io_master_awid    =  awid   ;
assign io_master_awlen   =  awlen  ;
assign io_master_awsize  =  awsize ;
assign io_master_awburst =  awburst;
assign io_master_wvalid  =  wvalid ;
assign io_master_wdata   =  wdata  ;
assign io_master_wstrb   =  wstrb  ;
assign io_master_wlast   =  wlast  ;
assign io_master_bready  =  bready ;
assign io_master_arvalid = (~slv) ? arvalid : 0;
assign io_master_araddr  = (~slv) ? araddr  : 0;
assign io_master_arid    = (~slv) ? arid    : 0;
assign io_master_arlen   = (~slv) ? arlen   : 0;
assign io_master_arsize  = (~slv) ? arsize  : 0;
assign io_master_arburst = (~slv) ? arburst : 0;
assign io_master_rready  = (~slv) ? rready  : 0;

assign clint_bready  =  (slv) ? bready  : 0;
assign clint_arvalid =  (slv) ? arvalid : 0;
assign clint_araddr  =  (slv) ? araddr  : 0;
assign clint_arid    =  (slv) ? arid    : 0;
assign clint_arlen   =  (slv) ? arlen   : 0;
assign clint_arsize  =  (slv) ? arsize  : 0;
assign clint_arburst =  (slv) ? arburst : 0;
assign clint_rready  =  (slv) ? rready  : 0;

assign awvalid = lsu_awvalid; 
assign awaddr  = lsu_awaddr ;
assign awid    = lsu_awid   ;
assign awlen   = lsu_awlen  ;
assign awsize  = lsu_awsize ;
assign awburst = lsu_awburst;
assign wvalid  = lsu_wvalid ;
assign wdata   = lsu_wdata  ;
assign wstrb   = lsu_wstrb  ;
assign wlast   = lsu_wlast  ;
assign bready  = lsu_bready ;
assign arvalid = (mst) ?  lsu_arvalid :  ifu_arvalid ;
assign araddr  = (mst) ?  lsu_araddr  :  ifu_araddr  ;
assign arid    = (mst) ?  lsu_arid    :  ifu_arid    ;
assign arlen   = (mst) ?  lsu_arlen   :  ifu_arlen   ;
assign arsize  = (mst) ?  lsu_arsize  :  ifu_arsize  ;
assign arburst = (mst) ?  lsu_arburst :  ifu_arburst ;
assign rready  = (mst) ?  lsu_rready  :  ifu_rready  ;

assign awready = (slv) ? clint_awready : io_master_awready ; 
assign wready  = (slv) ? clint_wready  : io_master_wready  ; 
assign bvalid  = (slv) ? clint_bvalid  : io_master_bvalid  ; 
assign bresp   = (slv) ? clint_bresp   : io_master_bresp   ; 
assign bid     = (slv) ? clint_bid     : io_master_bid     ; 
assign arready = (slv) ? clint_arready : io_master_arready ; 
assign rvalid  = (slv) ? clint_rvalid  : io_master_rvalid  ; 
assign rresp   = (slv) ? clint_rresp   : io_master_rresp   ; 
assign rdata   = (slv) ? clint_rdata   : io_master_rdata   ; 
assign rlast   = (slv) ? clint_rlast   : io_master_rlast   ; 
assign rid     = (slv) ? clint_rid     : io_master_rid     ; 

assign ifu_arready = (~mst) ?  arready : 0;    
assign ifu_rvalid  = (~mst) ?  rvalid  : 0;    
assign ifu_rresp   = (~mst) ?  rresp   : 0;    
assign ifu_rdata   = (~mst) ?  rdata   : 0;    
assign ifu_rlast   = (~mst) ?  rlast   : 0;    
assign ifu_rid     = (~mst) ?  rid     : 0;    

assign lsu_awready = awready;
assign lsu_wready  = wready ;
assign lsu_bvalid  = bvalid ;
assign lsu_bresp   = bresp  ;
assign lsu_bid     = bid    ;
assign lsu_arready = (mst)  ?  arready : 0;
assign lsu_rvalid  = (mst)  ?  rvalid  : 0;
assign lsu_rresp   = (mst)  ?  rresp   : 0;
assign lsu_rdata   = (mst)  ?  rdata   : 0;
assign lsu_rlast   = (mst)  ?  rlast   : 0;
assign lsu_rid     = (mst)  ?  rid     : 0;

endmodule
