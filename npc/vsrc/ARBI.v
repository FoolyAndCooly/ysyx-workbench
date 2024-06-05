module ysyx_23060221_Arbiter(
  input clk,
  output        ifu_awready,
  input         ifu_awvalid,
  input [31:0]  ifu_awaddr ,
  input [3:0]   ifu_awid   ,
  input [7:0]   ifu_awlen  ,
  input [2:0]   ifu_awsize ,
  input [1:0]   ifu_awburst,
  output        ifu_wready ,
  input         ifu_wvalid ,
  input [63:0]  ifu_wdata  ,
  input [7:0]   ifu_wstrb  ,
  input         ifu_wlast  ,
  input         ifu_bready ,
  output        ifu_bvalid ,
  output [1:0]  ifu_bresp  ,
  output [3:0]  ifu_bid    ,
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
  output [63:0] ifu_rdata  ,
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
  input [63:0]  exu_wdata  ,
  input [7:0]   exu_wstrb  ,
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
  output [63:0] exu_rdata  ,
  output        exu_rlast  ,
  output [3:0]  exu_rid    ,
  input         sram_awready,
  output        sram_awvalid,
  output [31:0] sram_awaddr ,
  output [3:0]  sram_awid   ,
  output [7:0]  sram_awlen  ,
  output [2:0]  sram_awsize ,
  output [1:0]  sram_awburst,
  input         sram_wready ,
  output        sram_wvalid ,
  output [63:0] sram_wdata  ,
  output [7:0]  sram_wstrb  ,
  output        sram_wlast  ,
  output        sram_bready ,
  input         sram_bvalid ,
  input  [1:0]  sram_bresp  ,
  input  [3:0]  sram_bid    ,
  input         sram_arready,
  output        sram_arvalid,
  output [31:0] sram_araddr ,
  output [3:0]  sram_arid   ,
  output [7:0]  sram_arlen  ,
  output [2:0]  sram_arsize ,
  output [1:0]  sram_arburst,
  output        sram_rready ,
  input         sram_rvalid ,
  input [1:0]   sram_rresp  ,
  input [63:0]  sram_rdata  ,
  input         sram_rlast  ,
  input [3:0]   sram_rid    ,
  input         uart_awready,
  output        uart_awvalid,
  output [31:0] uart_awaddr ,
  output [3:0]  uart_awid   ,
  output [7:0]  uart_awlen  ,
  output [2:0]  uart_awsize ,
  output [1:0]  uart_awburst,
  input         uart_wready ,
  output        uart_wvalid ,
  output [63:0] uart_wdata  ,
  output [7:0]  uart_wstrb  ,
  output        uart_wlast  ,
  output        uart_bready ,
  input         uart_bvalid ,
  input  [1:0]  uart_bresp  ,
  input  [3:0]  uart_bid    ,
  input         uart_arready,
  output        uart_arvalid,
  output [31:0] uart_araddr ,
  output [3:0]  uart_arid   ,
  output [7:0]  uart_arlen  ,
  output [2:0]  uart_arsize ,
  output [1:0]  uart_arburst,
  output        uart_rready ,
  input         uart_rvalid ,
  input [1:0]   uart_rresp  ,
  input [63:0]  uart_rdata  ,
  input         uart_rlast  ,
  input [3:0]   uart_rid    
);
  wire ifu_fast, exu_fast, mst;
  wire sram_memfinish, uart_memfinish;

  reg master, used;

  assign ifu_fast = ifu_arvalid | ifu_awvalid;
  assign exu_fast = exu_arvalid | exu_awvalid;
  assign mst = (ifu_fast) ? 0 : ((exu_fast) ? 1 : master);
  assign sram_memfinish = (sram_bvalid & sram_bready) | (sram_rvalid & sram_rready);
  assign uart_memfinish = (uart_bvalid & uart_bready) | (uart_rvalid & uart_rready);
  always @(posedge clk) begin
    if (ifu_arvalid | exu_arvalid | ifu_awvalid | exu_awvalid) used <= 1;
    if (ifu_arvalid | ifu_awvalid) begin
      master <= 0;
    end
    else begin
      if (exu_arvalid | exu_awvalid) begin
        master <= 1;
      end
    end
    if (master == 0 && (sram_memfinish == 1)) begin
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
wire [63:0] wdata  ;
wire [7:0]  wstrb  ;
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
wire [63:0] rdata  ;
wire        rlast  ;
wire [3:0]  rid    ;

wire uart;
wire sram;


reg  reg_uart;
reg         reg_sram_awvalid; 
reg  [31:0] reg_sram_awaddr ; 
reg  [3:0]  reg_sram_awid   ; 
reg  [7:0]  reg_sram_awlen  ; 
reg  [2:0]  reg_sram_awsize ; 
reg  [1:0]  reg_sram_awburst; 
reg         reg_sram_wvalid ; 
reg  [63:0] reg_sram_wdata  ; 
reg  [7:0]  reg_sram_wstrb  ; 
reg         reg_sram_wlast  ; 
reg         reg_sram_bready ; 
reg         reg_sram_arvalid; 
reg  [31:0] reg_sram_araddr ; 
reg  [3:0]  reg_sram_arid   ; 
reg  [7:0]  reg_sram_arlen  ; 
reg  [2:0]  reg_sram_arsize ; 
reg  [1:0]  reg_sram_arburst; 
reg         reg_sram_rready ; 
           
reg         reg_uart_awvalid; 
reg  [31:0] reg_uart_awaddr ; 
reg  [3:0]  reg_uart_awid   ; 
reg  [7:0]  reg_uart_awlen  ; 
reg  [2:0]  reg_uart_awsize ; 
reg  [1:0]  reg_uart_awburst; 
reg         reg_uart_wvalid ; 
reg  [63:0] reg_uart_wdata  ; 
reg  [7:0]  reg_uart_wstrb  ; 
reg         reg_uart_wlast  ; 
reg         reg_uart_bready ; 
reg         reg_uart_arvalid; 
reg  [31:0] reg_uart_araddr ; 
reg  [3:0]  reg_uart_arid   ; 
reg  [7:0]  reg_uart_arlen  ; 
reg  [2:0]  reg_uart_arsize ; 
reg  [1:0]  reg_uart_arburst; 
reg         reg_uart_rready ; 


reg        reg_ifu_awready ;
reg        reg_ifu_wready  ;
reg        reg_ifu_bvalid  ;
reg [1:0]  reg_ifu_bresp   ;
reg [3:0]  reg_ifu_bid     ;
reg        reg_ifu_arready ;
reg        reg_ifu_rvalid  ;
reg [1:0]  reg_ifu_rresp   ;
reg [63:0] reg_ifu_rdata   ;
reg        reg_ifu_rlast   ;
reg [3:0]  reg_ifu_rid     ;

reg        reg_exu_awready ;
reg        reg_exu_wready  ;
reg        reg_exu_bvalid  ;
reg [1:0]  reg_exu_bresp   ;
reg [3:0]  reg_exu_bid     ;
reg        reg_exu_arready ;
reg        reg_exu_rvalid  ;
reg [1:0]  reg_exu_rresp   ;
reg [63:0] reg_exu_rdata   ;
reg        reg_exu_rlast   ;
reg [3:0]  reg_exu_rid     ;


assign ifu_awready =  reg_ifu_awready; 
assign ifu_wready  =  reg_ifu_wready ; 
assign ifu_bvalid  =  reg_ifu_bvalid ; 
assign ifu_bresp   =  reg_ifu_bresp  ; 
assign ifu_bid     =  reg_ifu_bid    ; 
assign ifu_arready =  reg_ifu_arready; 
assign ifu_rvalid  =  reg_ifu_rvalid ; 
assign ifu_rresp   =  reg_ifu_rresp  ; 
assign ifu_rdata   =  reg_ifu_rdata  ; 
assign ifu_rlast   =  reg_ifu_rlast  ; 
assign ifu_rid     =  reg_ifu_rid    ; 

assign exu_awready =  reg_exu_awready; 
assign exu_wready  =  reg_exu_wready ; 
assign exu_bvalid  =  reg_exu_bvalid ; 
assign exu_bresp   =  reg_exu_bresp  ; 
assign exu_bid     =  reg_exu_bid    ; 
assign exu_arready =  reg_exu_arready; 
assign exu_rvalid  =  reg_exu_rvalid ; 
assign exu_rresp   =  reg_exu_rresp  ; 
assign exu_rdata   =  reg_exu_rdata  ; 
assign exu_rlast   =  reg_exu_rlast  ; 
assign exu_rid     =  reg_exu_rid    ; 

assign sram_awvalid =  reg_sram_awvalid; 
assign sram_awaddr  =  reg_sram_awaddr ;
assign sram_awid    =  reg_sram_awid   ;
assign sram_awlen   =  reg_sram_awlen  ;
assign sram_awsize  =  reg_sram_awsize ;
assign sram_awburst =  reg_sram_awburst;
assign sram_wvalid  =  reg_sram_wvalid ;
assign sram_wdata   =  reg_sram_wdata  ;
assign sram_wstrb   =  reg_sram_wstrb  ;
assign sram_wlast   =  reg_sram_wlast  ;
assign sram_bready  =  reg_sram_bready ;
assign sram_arvalid =  reg_sram_arvalid;
assign sram_araddr  =  reg_sram_araddr ;
assign sram_arid    =  reg_sram_arid   ;
assign sram_arlen   =  reg_sram_arlen  ;
assign sram_arsize  =  reg_sram_arsize ;
assign sram_arburst =  reg_sram_arburst;
assign sram_rready  =  reg_sram_rready ;

assign uart_awvalid =  reg_uart_awvalid;
assign uart_awaddr  =  reg_uart_awaddr ;
assign uart_awid    =  reg_uart_awid   ;
assign uart_awlen   =  reg_uart_awlen  ;
assign uart_awsize  =  reg_uart_awsize ;
assign uart_awburst =  reg_uart_awburst;
assign uart_wvalid  =  reg_uart_wvalid ;
assign uart_wdata   =  reg_uart_wdata  ;
assign uart_wstrb   =  reg_uart_wstrb  ;
assign uart_wlast   =  reg_uart_wlast  ;
assign uart_bready  =  reg_uart_bready ;
assign uart_arvalid =  reg_uart_arvalid;
assign uart_araddr  =  reg_uart_araddr ;
assign uart_arid    =  reg_uart_arid   ;
assign uart_arlen   =  reg_uart_arlen  ;
assign uart_arsize  =  reg_uart_arsize ;
assign uart_arburst =  reg_uart_arburst;
assign uart_rready  =  reg_uart_rready ;

assign awvalid = (mst) ?  exu_awvalid :  ifu_awvalid ; 
assign awaddr  = (mst) ?  exu_awaddr  :  ifu_awaddr  ;
assign awid    = (mst) ?  exu_awid    :  ifu_awid    ;
assign awlen   = (mst) ?  exu_awlen   :  ifu_awlen   ;
assign awsize  = (mst) ?  exu_awsize  :  ifu_awsize  ;
assign awburst = (mst) ?  exu_awburst :  ifu_awburst ;
assign wvalid  = (mst) ?  exu_wvalid  :  ifu_wvalid  ;
assign wdata   = (mst) ?  exu_wdata   :  ifu_wdata   ;
assign wstrb   = (mst) ?  exu_wstrb   :  ifu_wstrb   ;
assign wlast   = (mst) ?  exu_wlast   :  ifu_wlast   ;
assign bready  = (mst) ?  exu_bready  :  ifu_bready  ;
assign arvalid = (mst) ?  exu_arvalid :  ifu_arvalid ;
assign araddr  = (mst) ?  exu_araddr  :  ifu_araddr  ;
assign arid    = (mst) ?  exu_arid    :  ifu_arid    ;
assign arlen   = (mst) ?  exu_arlen   :  ifu_arlen   ;
assign arsize  = (mst) ?  exu_arsize  :  ifu_arsize  ;
assign arburst = (mst) ?  exu_arburst :  ifu_arburst ;
assign rready  = (mst) ?  exu_rready  :  ifu_rready  ;

assign sram = ~uart                   ;

assign awready = (uart) ?  uart_awready :  sram_awready ; 
assign wready  = (uart) ?  uart_wready  :  sram_wready  ; 
assign bvalid  = (uart) ?  uart_bvalid  :  sram_bvalid  ; 
assign bresp   = (uart) ?  uart_bresp   :  sram_bresp   ; 
assign bid     = (uart) ?  uart_bid     :  sram_bid     ; 
assign arready = (uart) ?  uart_arready :  sram_arready ; 
assign rvalid  = (uart) ?  uart_rvalid  :  sram_rvalid  ; 
assign rresp   = (uart) ?  uart_rresp   :  sram_rresp   ; 
assign rdata   = (uart) ?  uart_rdata   :  sram_rdata   ; 
assign rlast   = (uart) ?  uart_rlast   :  sram_rlast   ; 
assign rid     = (uart) ?  uart_rid     :  sram_rid     ; 

assign uart = (awaddr == 32'ha00003f8 & awvalid) ? 'd1 : reg_uart;

always @(posedge clk) begin
  if (awaddr == 32'ha00003f8 & awvalid)
    reg_uart <= 1;
  else if ((bvalid & bready) | (rvalid & rready))
    reg_uart <= 0;
  else 
    reg_uart <= reg_uart;
end

always @(posedge clk) begin
  reg_sram_awvalid  <= (sram) ? awvalid :  sram_awvalid ;
  reg_sram_awaddr   <= (sram) ? awaddr  :  sram_awaddr  ;
  reg_sram_awid     <= (sram) ? awid    :  sram_awid    ;
  reg_sram_awlen    <= (sram) ? awlen   :  sram_awlen   ;
  reg_sram_awsize   <= (sram) ? awsize  :  sram_awsize  ;
  reg_sram_awburst  <= (sram) ? awburst :  sram_awburst ;
  reg_sram_wvalid   <= (sram) ? wvalid  :  sram_wvalid  ;
  reg_sram_wdata    <= (sram) ? wdata   :  sram_wdata   ;
  reg_sram_wstrb    <= (sram) ? wstrb   :  sram_wstrb   ;
  reg_sram_wlast    <= (sram) ? wlast   :  sram_wlast   ;
  reg_sram_bready   <= (sram) ? bready  :  sram_bready  ;
  reg_sram_arvalid  <= (sram) ? arvalid :  sram_arvalid ;
  reg_sram_araddr   <= (sram) ? araddr  :  sram_araddr  ;
  reg_sram_arid     <= (sram) ? arid    :  sram_arid    ;
  reg_sram_arlen    <= (sram) ? arlen   :  sram_arlen   ;
  reg_sram_arsize   <= (sram) ? arsize  :  sram_arsize  ;
  reg_sram_arburst  <= (sram) ? arburst :  sram_arburst ;
  reg_sram_rready   <= (sram) ? rready  :  sram_rready  ;
 
  reg_uart_awvalid  <= (uart) ? awvalid :  uart_awvalid ;
  reg_uart_awaddr   <= (uart) ? awaddr  :  uart_awaddr  ;
  reg_uart_awid     <= (uart) ? awid    :  uart_awid    ;
  reg_uart_awlen    <= (uart) ? awlen   :  uart_awlen   ;
  reg_uart_awsize   <= (uart) ? awsize  :  uart_awsize  ;
  reg_uart_awburst  <= (uart) ? awburst :  uart_awburst ;
  reg_uart_wvalid   <= (uart) ? wvalid  :  uart_wvalid  ;
  reg_uart_wdata    <= (uart) ? wdata   :  uart_wdata   ;
  reg_uart_wstrb    <= (uart) ? wstrb   :  uart_wstrb   ;
  reg_uart_wlast    <= (uart) ? wlast   :  uart_wlast   ;
  reg_uart_bready   <= (uart) ? bready  :  uart_bready  ;
  reg_uart_arvalid  <= (uart) ? arvalid :  uart_arvalid ;
  reg_uart_araddr   <= (uart) ? araddr  :  uart_araddr  ; 
  reg_uart_arid     <= (uart) ? arid    :  uart_arid    ;
  reg_uart_arlen    <= (uart) ? arlen   :  uart_arlen   ;
  reg_uart_arsize   <= (uart) ? arsize  :  uart_arsize  ;
  reg_uart_arburst  <= (uart) ? arburst :  uart_arburst ;
  reg_uart_rready   <= (uart) ? rready  :  uart_rready  ;
end

always @(posedge clk) begin
  reg_ifu_awready <= (~mst) ?  awready : ifu_awready ; 
  reg_ifu_wready  <= (~mst) ?  wready  : ifu_wready  ;    
  reg_ifu_bvalid  <= (~mst) ?  bvalid  : ifu_bvalid  ;    
  reg_ifu_bresp   <= (~mst) ?  bresp   : ifu_bresp   ;    
  reg_ifu_bid     <= (~mst) ?  bid     : ifu_bid     ;    
  reg_ifu_arready <= (~mst) ?  arready : ifu_arready ;    
  reg_ifu_rvalid  <= (~mst) ?  rvalid  : ifu_rvalid  ;    
  reg_ifu_rresp   <= (~mst) ?  rresp   : ifu_rresp   ;    
  reg_ifu_rdata   <= (~mst) ?  rdata   : ifu_rdata   ;    
  reg_ifu_rlast   <= (~mst) ?  rlast   : ifu_rlast   ;    
  reg_ifu_rid     <= (~mst) ?  rid     : ifu_rid     ;    
 
  reg_exu_awready <= (mst)  ?  awready : exu_awready ;
  reg_exu_wready  <= (mst)  ?  wready  : exu_wready  ;
  reg_exu_bvalid  <= (mst)  ?  bvalid  : exu_bvalid  ;
  reg_exu_bresp   <= (mst)  ?  bresp   : exu_bresp   ;
  reg_exu_bid     <= (mst)  ?  bid     : exu_bid     ;
  reg_exu_arready <= (mst)  ?  arready : exu_arready ;
  reg_exu_rvalid  <= (mst)  ?  rvalid  : exu_rvalid  ;
  reg_exu_rresp   <= (mst)  ?  rresp   : exu_rresp   ;
  reg_exu_rdata   <= (mst)  ?  rdata   : exu_rdata   ;
  reg_exu_rlast   <= (mst)  ?  rlast   : exu_rlast   ;
  reg_exu_rid     <= (mst)  ?  rid     : exu_rid     ;
end
endmodule
