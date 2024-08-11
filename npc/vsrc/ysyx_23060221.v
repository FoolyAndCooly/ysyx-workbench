module ysyx_23060221(
  input clock                              ,
  input reset                              ,
  input io_interrupt                       ,
  input		io_master_awready	   , 
  output		io_master_awvalid  ,
  output	[31:0]	io_master_awaddr   ,
  output	[3:0]	io_master_awid	   ,
  output	[7:0]	io_master_awlen	   ,
  output	[2:0]	io_master_awsize   ,
  output	[1:0]	io_master_awburst  ,
  input		io_master_wready	   ,
  output		io_master_wvalid   ,
  output	[31:0]	io_master_wdata	   ,
  output	[3:0]	io_master_wstrb	   ,
  output		io_master_wlast	   ,
  output		io_master_bready   ,
  input		io_master_bvalid	   ,
  input	[1:0]	io_master_bresp	           ,
  input	[3:0]	io_master_bid	           ,
  input		io_master_arready	   ,
  output		io_master_arvalid  ,
  output	[31:0]	io_master_araddr   ,
  output	[3:0]	io_master_arid	   ,
  output	[7:0]	io_master_arlen	   ,
  output	[2:0]	io_master_arsize   ,
  output	[1:0]	io_master_arburst  ,
  output		io_master_rready   ,
  input		io_master_rvalid	   ,
  input	[1:0]	io_master_rresp	           ,
  input	[31:0]	io_master_rdata	           ,
  input		io_master_rlast	           ,
  input	[3:0]	io_master_rid	           ,
  output		io_slave_awready   ,
  input		io_slave_awvalid           ,
  input	[31:0]	io_slave_awaddr            ,
  input	[3:0]	io_slave_awid              ,
  input	[7:0]	io_slave_awlen             ,
  input	[2:0]	io_slave_awsize            ,
  input	[1:0]	io_slave_awburst           ,
  output		io_slave_wready    ,
  input		io_slave_wvalid            ,
  input	[31:0]	io_slave_wdata             ,
  input	[3:0]	io_slave_wstrb             ,
  input		io_slave_wlast             ,
  input		io_slave_bready            ,
  output		io_slave_bvalid    ,
  output	[1:0]	io_slave_bresp     ,
  output	[3:0]	io_slave_bid       ,
  output		io_slave_arready   ,
  input		io_slave_arvalid           ,
  input	[31:0]	io_slave_araddr            ,
  input	[3:0]	io_slave_arid              ,
  input	[7:0]	io_slave_arlen             ,
  input	[2:0]	io_slave_arsize            ,
  input	[1:0]	io_slave_arburst           ,
  input		io_slave_rready            ,
  output		io_slave_rvalid    ,
  output	[1:0]	io_slave_rresp     ,
  output	[31:0]	io_slave_rdata     ,
  output		io_slave_rlast     ,  
  output	[3:0]	io_slave_rid    
);

assign io_slave_awready  = 0;  
assign io_slave_wready   = 0;  
assign io_slave_bvalid   = 0;  
assign io_slave_bresp    = 0;  
assign io_slave_bid      = 0;  
assign io_slave_arready  = 0;  
assign io_slave_rvalid   = 0;  
assign io_slave_rresp    = 0; 
assign io_slave_rdata    = 0; 
assign io_slave_rlast    = 0; 
assign io_slave_rid      = 0; 


reg IFU_valid, IFU_ready, IDU_ready, IDU_valid, EXU_ready, EXU_valid, WBU_ready, WBU_valid;

reg [31:0] pc;
reg [31:0] csr[3:0];
reg [31:0] rf[31:0];

wire [31:0] inst;
wire [31:0] res;
wire [31:0] src1, src2;
wire [31:0] imm;
wire PCAsrc, PCBsrc;
wire [2:0] CSRctr;

wire [31:0] wd;
wire [3:0] aluctr;
wire aluasrc;
wire [1:0] alubsrc; 
wire [2:0] branch;
wire [2:0] memop;
wire memtoreg;
wire memwr;
wire wen;

wire        ifu_awready ;
wire        ifu_awvalid ;
wire [31:0] ifu_awaddr  ;
wire [3:0]  ifu_awid    ;
wire [7:0]  ifu_awlen   ;
wire [2:0]  ifu_awsize  ;
wire [1:0]  ifu_awburst ;
wire        ifu_wready  ;
wire        ifu_wvalid  ;
wire [31:0] ifu_wdata   ;
wire [3:0]  ifu_wstrb   ;
wire        ifu_wlast   ;
wire        ifu_bready  ;
wire        ifu_bvalid  ;
wire [1:0]  ifu_bresp   ;
wire [3:0]  ifu_bid     ;
wire        ifu_arready ;
wire        ifu_arvalid ;
wire [31:0] ifu_araddr  ;
wire [3:0]  ifu_arid    ;
wire [7:0]  ifu_arlen   ;
wire [2:0]  ifu_arsize  ;
wire [1:0]  ifu_arburst ;
wire        ifu_rready  ;
wire        ifu_rvalid  ;
wire [1:0]  ifu_rresp   ;
wire [31:0] ifu_rdata   ;
wire        ifu_rlast   ;
wire [3:0]  ifu_rid     ;

wire        exu_awready ;
wire        exu_awvalid ;
wire [31:0] exu_awaddr  ;
wire [3:0]  exu_awid    ;
wire [7:0]  exu_awlen   ;
wire [2:0]  exu_awsize  ;
wire [1:0]  exu_awburst ;
wire        exu_wready  ;
wire        exu_wvalid  ;
wire [31:0] exu_wdata   ;
wire [3:0]  exu_wstrb   ;
wire        exu_wlast   ;
wire        exu_bready  ;
wire        exu_bvalid  ;
wire [1:0]  exu_bresp   ;
wire [3:0]  exu_bid     ;
wire        exu_arready ;
wire        exu_arvalid ;
wire [31:0] exu_araddr  ;
wire [3:0]  exu_arid    ;
wire [7:0]  exu_arlen   ;
wire [2:0]  exu_arsize  ;
wire [1:0]  exu_arburst ;
wire        exu_rready  ;
wire        exu_rvalid  ;
wire [1:0]  exu_rresp   ;
wire [31:0] exu_rdata   ;
wire        exu_rlast   ;
wire [3:0]  exu_rid     ;

ysyx_23060221_Ifu ifu(
  .clk      (clock      )  ,
  .rst      (reset      )  ,
  .pc       (pc         )  ,
  .inst     (inst       )  ,
  .WBU_valid(WBU_valid  )  ,
  .IDU_ready(IDU_ready  )  ,
  .IFU_valid(IFU_valid  )  ,
  .IFU_ready(IFU_ready  )  ,
  .awready  (ifu_awready)  ,
  .awvalid  (ifu_awvalid)  ,
  .awaddr   (ifu_awaddr )  ,
  .awid     (ifu_awid   )  ,
  .awlen    (ifu_awlen  )  ,
  .awsize   (ifu_awsize )  ,
  .awburst  (ifu_awburst)  ,
  .wready   (ifu_wready )  ,
  .wvalid   (ifu_wvalid )  ,
  .wdata    (ifu_wdata  )  ,
  .wstrb    (ifu_wstrb  )  ,
  .wlast    (ifu_wlast  )  ,
  .bready   (ifu_bready )  ,
  .bvalid   (ifu_bvalid )  ,
  .bresp    (ifu_bresp  )  ,
  .bid      (ifu_bid    )  ,
  .arready  (ifu_arready)  ,
  .arvalid  (ifu_arvalid)  ,
  .araddr   (ifu_araddr )  ,
  .arid     (ifu_arid   )  ,
  .arlen    (ifu_arlen  )  ,
  .arsize   (ifu_arsize )  ,
  .arburst  (ifu_arburst)  ,
  .rready   (ifu_rready )  ,
  .rvalid   (ifu_rvalid )  ,
  .rresp    (ifu_rresp  )  ,
  .rdata    (ifu_rdata  )  ,
  .rlast    (ifu_rlast  )  ,
  .rid      (ifu_rid    )  
  );

wire         icache_arready;
wire         icache_arvalid;
wire  [31:0] icache_araddr ;
wire  [3:0]  icache_arid   ;
wire  [7:0]  icache_arlen  ;
wire  [2:0]  icache_arsize ;
wire  [1:0]  icache_arburst;
wire         icache_rready ;
wire         icache_rvalid ;
wire  [1:0]  icache_rresp  ;
wire  [31:0] icache_rdata  ;
wire         icache_rlast  ;
wire  [3:0]  icache_rid    ; 

cache icache(
  .clk(clock),
  .rst(reset)  ,
  .in_arready (ifu_arready), 
  .in_arvalid (ifu_arvalid), 
  .in_araddr  (ifu_araddr ), 
  .in_arid    (ifu_arid   ), 
  .in_arlen   (ifu_arlen  ), 
  .in_arsize  (ifu_arsize ), 
  .in_arburst (ifu_arburst), 
  .in_rready  (ifu_rready ), 
  .in_rvalid  (ifu_rvalid ),   
  .in_rresp   (ifu_rresp  ),  
  .in_rdata   (ifu_rdata  ),  
  .in_rlast   (ifu_rlast  ),  
  .in_rid     (ifu_rid    ), 
  .out_arready(icache_arready), 
  .out_arvalid(icache_arvalid), 
  .out_araddr (icache_araddr ), 
  .out_arid   (icache_arid   ), 
  .out_arlen  (icache_arlen  ), 
  .out_arsize (icache_arsize ), 
  .out_arburst(icache_arburst),  
  .out_rready (icache_rready ), 
  .out_rvalid (icache_rvalid ), 
  .out_rresp  (icache_rresp  ),   
  .out_rdata  (icache_rdata  ),   
  .out_rlast  (icache_rlast  ),  
  .out_rid    (icache_rid    )
  ); 

ysyx_23060221_Arbiter arbiter(
  .clk         (clock)       ,
  .ifu_awready (ifu_awready ), 
  .ifu_awvalid (ifu_awvalid ), 
  .ifu_awaddr  (ifu_awaddr  ), 
  .ifu_awid    (ifu_awid    ), 
  .ifu_awlen   (ifu_awlen   ), 
  .ifu_awsize  (ifu_awsize  ), 
  .ifu_awburst (ifu_awburst ), 
  .ifu_wready  (ifu_wready  ), 
  .ifu_wvalid  (ifu_wvalid  ), 
  .ifu_wdata   (ifu_wdata   ),
  .ifu_wstrb   (ifu_wstrb   ),  
  .ifu_wlast   (ifu_wlast   ), 
  .ifu_bready  (ifu_bready  ), 
  .ifu_bvalid  (ifu_bvalid  ), 
  .ifu_bresp   (ifu_bresp   ), 
  .ifu_bid     (ifu_bid     ), 
  .ifu_arready (icache_arready ),
  .ifu_arvalid (icache_arvalid ), 
  .ifu_araddr  (icache_araddr  ), 
  .ifu_arid    (icache_arid    ), 
  .ifu_arlen   (icache_arlen   ), 
  .ifu_arsize  (icache_arsize  ), 
  .ifu_arburst (icache_arburst ),
  .ifu_rready  (icache_rready  ),  
  .ifu_rvalid  (icache_rvalid  ), 
  .ifu_rresp   (icache_rresp   ),
  .ifu_rdata   (icache_rdata   ), 
  .ifu_rlast   (icache_rlast   ), 
  .ifu_rid     (icache_rid     ), 
  .exu_awready (exu_awready ), 
  .exu_awvalid (exu_awvalid ),
  .exu_awaddr  (exu_awaddr  ), 
  .exu_awid    (exu_awid    ), 
  .exu_awlen   (exu_awlen   ), 
  .exu_awsize  (exu_awsize  ),
  .exu_awburst (exu_awburst ), 
  .exu_wready  (exu_wready  ), 
  .exu_wvalid  (exu_wvalid  ), 
  .exu_wdata   (exu_wdata   ),
  .exu_wstrb   (exu_wstrb   ), 
  .exu_wlast   (exu_wlast   ), 
  .exu_bready  (exu_bready  ), 
  .exu_bvalid  (exu_bvalid  ), 
  .exu_bresp   (exu_bresp   ),
  .exu_bid     (exu_bid     ), 
  .exu_arready (exu_arready ), 
  .exu_arvalid (exu_arvalid ),
  .exu_araddr  (exu_araddr  ), 
  .exu_arid    (exu_arid    ), 
  .exu_arlen   (exu_arlen   ),
  .exu_arsize  (exu_arsize  ), 
  .exu_arburst (exu_arburst ), 
  .exu_rready  (exu_rready  ),
  .exu_rvalid  (exu_rvalid  ), 
  .exu_rresp   (exu_rresp   ), 
  .exu_rdata   (exu_rdata   ), 
  .exu_rlast   (exu_rlast   ), 
  .exu_rid     (exu_rid     ),
  .io_master_awready(io_master_awready), 
  .io_master_awvalid(io_master_awvalid), 
  .io_master_awaddr (io_master_awaddr ), 
  .io_master_awid   (io_master_awid   ),
  .io_master_awlen  (io_master_awlen  ), 
  .io_master_awsize (io_master_awsize ), 
  .io_master_awburst(io_master_awburst), 
  .io_master_wready (io_master_wready ), 
  .io_master_wvalid (io_master_wvalid ),
  .io_master_wdata  (io_master_wdata  ), 
  .io_master_wstrb  (io_master_wstrb  ), 
  .io_master_wlast  (io_master_wlast  ), 
  .io_master_bready (io_master_bready ),
  .io_master_bvalid (io_master_bvalid ), 
  .io_master_bresp  (io_master_bresp  ), 
  .io_master_bid    (io_master_bid    ),
  .io_master_arready(io_master_arready), 
  .io_master_arvalid(io_master_arvalid), 
  .io_master_araddr (io_master_araddr ),
  .io_master_arid   (io_master_arid   ), 
  .io_master_arlen  (io_master_arlen  ), 
  .io_master_arsize (io_master_arsize ),
  .io_master_arburst(io_master_arburst), 
  .io_master_rready (io_master_rready ), 
  .io_master_rvalid (io_master_rvalid ), 
  .io_master_rresp  (io_master_rresp  ),
  .io_master_rdata  (io_master_rdata  ), 
  .io_master_rlast  (io_master_rlast  ), 
  .io_master_rid    (io_master_rid    )
);

ysyx_23060221_Idu idu(
  .rst(reset),
  .inst(inst),
  .aluctr(aluctr),
  .aluasrc(aluasrc),
  .alubsrc(alubsrc),
  .branch(branch),
  .memop(memop),
  .memtoreg(memtoreg),
  .memwr(memwr),
  .src1(src1),
  .src2(src2),
  .imm(imm),
  .csr(csr),
  .clk(clock),
  .rf_in(rf),
  .rf_out(rf),
  .wen(wen),
  .CSRctr(CSRctr),
  .IFU_valid(IFU_valid),
  .IDU_ready(IDU_ready),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready));

ysyx_23060221_Exu exu(
  .clk(clock),
  .rst(reset),
  .src1(src1),
  .src2(src2),
  .pc(pc),
  .imm(imm),
  .aluctr(aluctr),
  .aluasrc(aluasrc),
  .alubsrc(alubsrc),
  .branch(branch),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .memop(memop),
  .memwr(memwr),
  .memtoreg(memtoreg),
  .wd(wd),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready),
  .EXU_valid(EXU_valid),
  .WBU_ready(WBU_ready),
  .res(res),
  .awready  (exu_awready)  ,
  .awvalid  (exu_awvalid)  ,
  .awaddr   (exu_awaddr )  ,
  .awid     (exu_awid   )  ,
  .awlen    (exu_awlen  )  ,
  .awsize   (exu_awsize )  ,
  .awburst  (exu_awburst)  ,
  .wready   (exu_wready )  ,
  .wvalid   (exu_wvalid )  ,
  .wdata    (exu_wdata  )  ,
  .wstrb    (exu_wstrb  )  ,
  .wlast    (exu_wlast  )  ,
  .bready   (exu_bready )  ,
  .bvalid   (exu_bvalid )  ,
  .bresp    (exu_bresp  )  ,
  .bid      (exu_bid    )  ,
  .arready  (exu_arready)  ,
  .arvalid  (exu_arvalid)  ,
  .araddr   (exu_araddr )  ,
  .arid     (exu_arid   )  ,
  .arlen    (exu_arlen  )  ,
  .arsize   (exu_arsize )  ,
  .arburst  (exu_arburst)  ,
  .rready   (exu_rready )  ,
  .rvalid   (exu_rvalid )  ,
  .rresp    (exu_rresp  )  ,
  .rdata    (exu_rdata  )  ,
  .rlast    (exu_rlast  )  ,
  .rid      (exu_rid    )  
);

ysyx_23060221_Wbu wbu(
  .rst(reset),
  .rs1(src1),
  .imm(imm),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .pc(pc),
  .wdata(wd),
  .waddr(inst[11:7]),
  .Ra(inst[19:15]),
  .clk(clock),
  .wen(wen),
  .rf_in(rf),
  .rf_out(rf),
  .csr_in(csr),
  .csr_out(csr),
  .CSRctr(CSRctr),
  .EXU_valid(EXU_valid),
  .IFU_ready(IFU_ready),
  .WBU_ready(WBU_ready),
  .WBU_valid(WBU_valid)
  );
 endmodule

