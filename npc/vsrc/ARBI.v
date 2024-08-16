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
  output        exu_awready,
  input         exu_awvalid,
  input [31:0]  exu_awaddr ,
  input [3:0]   exu_awid   ,
  input [7:0]   exu_awlen  ,
  input [2:0]   exu_awsize ,
  input [1:0]   exu_awburst,
  output        exu_wready ,
  input         exu_wvalid ,
  input [31:0]  exu_wdata  ,
  input [3:0]   exu_wstrb  ,
  input         exu_wlast  ,
  input         exu_bready ,
  output        exu_bvalid ,
  output [1:0]  exu_bresp  ,
  output [3:0]  exu_bid    ,
  output        exu_arready,
  input         exu_arvalid,
  input [31:0]  exu_araddr ,
  input [3:0]   exu_arid   ,
  input [7:0]   exu_arlen  ,
  input [2:0]   exu_arsize ,
  input [1:0]   exu_arburst,
  input         exu_rready ,
  output        exu_rvalid ,
  output [1:0]  exu_rresp  ,
  output [31:0] exu_rdata  ,
  output        exu_rlast  ,
  output [3:0]  exu_rid    ,
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
  input [3:0]   io_master_rid
);
  wire ifu_fast, exu_fast, mst;
  wire io_master_memfinish;

  reg master, used;

  assign ifu_fast = ifu_arvalid;
  assign exu_fast = exu_arvalid | exu_awvalid;
  assign mst = (ifu_fast) ? 0 : ((exu_fast) ? 1 : master);
  assign io_master_memfinish = (io_master_bvalid & io_master_bready) | (io_master_rvalid & io_master_rready);
  always @(posedge clk) begin
    // $display("mst: %d", mst);
    if (ifu_arvalid | exu_arvalid | exu_awvalid) used <= 1;
    if (ifu_arvalid) begin
      master <= 0;
    end
    else begin
      if (exu_arvalid | exu_awvalid) begin
        master <= 1;
      end
    end
    if (master == 0 && (io_master_memfinish == 1)) begin
      used <= 0;
    end
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
assign io_master_arvalid =  arvalid;
assign io_master_araddr  =  araddr ;
assign io_master_arid    =  arid   ;
assign io_master_arlen   =  arlen  ;
assign io_master_arsize  =  arsize ;
assign io_master_arburst =  arburst;
assign io_master_rready  =  rready ;

assign awvalid = exu_awvalid; 
assign awaddr  = exu_awaddr ;
assign awid    = exu_awid   ;
assign awlen   = exu_awlen  ;
assign awsize  = exu_awsize ;
assign awburst = exu_awburst;
assign wvalid  = exu_wvalid ;
assign wdata   = exu_wdata  ;
assign wstrb   = exu_wstrb  ;
assign wlast   = exu_wlast  ;
assign bready  = exu_bready ;
assign arvalid = (mst) ?  exu_arvalid :  ifu_arvalid ;
assign araddr  = (mst) ?  exu_araddr  :  ifu_araddr  ;
assign arid    = (mst) ?  exu_arid    :  ifu_arid    ;
assign arlen   = (mst) ?  exu_arlen   :  ifu_arlen   ;
assign arsize  = (mst) ?  exu_arsize  :  ifu_arsize  ;
assign arburst = (mst) ?  exu_arburst :  ifu_arburst ;
assign rready  = (mst) ?  exu_rready  :  ifu_rready  ;

assign awready =  io_master_awready ; 
assign wready  =  io_master_wready  ; 
assign bvalid  =  io_master_bvalid  ; 
assign bresp   =  io_master_bresp   ; 
assign bid     =  io_master_bid     ; 
assign arready =  io_master_arready ; 
assign rvalid  =  io_master_rvalid  ; 
assign rresp   =  io_master_rresp   ; 
assign rdata   =  io_master_rdata   ; 
assign rlast   =  io_master_rlast   ; 
assign rid     =  io_master_rid     ; 

assign ifu_arready = (~mst) ?  arready : 0;    
assign ifu_rvalid  = (~mst) ?  rvalid  : 0;    
assign ifu_rresp   = (~mst) ?  rresp   : 0;    
assign ifu_rdata   = (~mst) ?  rdata   : 0;    
assign ifu_rlast   = (~mst) ?  rlast   : 0;    
assign ifu_rid     = (~mst) ?  rid     : 0;    

assign exu_awready = awready;
assign exu_wready  = wready ;
assign exu_bvalid  = bvalid ;
assign exu_bresp   = bresp  ;
assign exu_bid     = bid    ;
assign exu_arready = (mst)  ?  arready : 0;
assign exu_rvalid  = (mst)  ?  rvalid  : 0;
assign exu_rresp   = (mst)  ?  rresp   : 0;
assign exu_rdata   = (mst)  ?  rdata   : 0;
assign exu_rlast   = (mst)  ?  rlast   : 0;
assign exu_rid     = (mst)  ?  rid     : 0;
endmodule
