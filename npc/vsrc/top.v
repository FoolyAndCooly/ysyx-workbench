module top(
  input clk
);
  
reg IFU_valid, IFU_ready, IDU_ready, IDU_valid, EXU_ready, EXU_valid, WBU_ready, WBU_valid;

reg [31:0] res;
reg [31:0] pc;
reg [31:0] csr[3:0];
reg [31:0] rf[31:0];
reg [31:0] inst;


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
wire [63:0] ifu_wdata   ;
wire [7:0]  ifu_wstrb   ;
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
wire [63:0] ifu_rdata   ;
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
wire [63:0] exu_wdata   ;
wire [7:0]  exu_wstrb   ;
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
wire [63:0] exu_rdata   ;
wire        exu_rlast   ;
wire [3:0]  exu_rid     ;
wire        sram_awready;
wire        sram_awvalid;
wire [31:0] sram_awaddr ;
wire [3:0]  sram_awid   ;
wire [7:0]  sram_awlen  ;
wire [2:0]  sram_awsize ;
wire [1:0]  sram_awburst;
wire        sram_wready ;
wire        sram_wvalid ;
wire [63:0] sram_wdata  ;
wire [7:0]  sram_wstrb  ;
wire        sram_wlast  ;
wire        sram_bready ;
wire        sram_bvalid ;
wire [1:0]  sram_bresp  ;
wire [3:0]  sram_bid    ;
wire        sram_arready;
wire        sram_arvalid;
wire [31:0] sram_araddr ;
wire [3:0]  sram_arid   ;
wire [7:0]  sram_arlen  ;
wire [2:0]  sram_arsize ;
wire [1:0]  sram_arburst;
wire        sram_rready ;
wire        sram_rvalid ;
wire[1:0]   sram_rresp  ;
wire[63:0]  sram_rdata  ;
wire        sram_rlast  ;
wire[3:0]   sram_rid    ;
wire        uart_awready;
wire        uart_awvalid;
wire [31:0] uart_awaddr ;
wire [3:0]  uart_awid   ;
wire [7:0]  uart_awlen  ;
wire [2:0]  uart_awsize ;
wire [1:0]  uart_awburst;
wire        uart_wready ;
wire        uart_wvalid ;
wire [63:0] uart_wdata  ;
wire [7:0]  uart_wstrb  ;
wire        uart_wlast  ;
wire        uart_bready ;
wire        uart_bvalid ;
wire [1:0]  uart_bresp  ;
wire [3:0]  uart_bid    ;
wire        uart_arready;
wire        uart_arvalid;
wire [31:0] uart_araddr ;
wire [3:0]  uart_arid   ;
wire [7:0]  uart_arlen  ;
wire [2:0]  uart_arsize ;
wire [1:0]  uart_arburst;
wire        uart_rready ;
wire        uart_rvalid ;
wire[1:0]   uart_rresp  ;
wire[63:0]  uart_rdata  ;
wire        uart_rlast  ;
wire[3:0]   uart_rid    ;

assign inst = ifu_rdata[31:0];

Ifu ifu(
  .clk      (clk        )  ,
  .pc       (pc         )  ,
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

DataMem dm(
  .clk(clk),
  .awready  (sram_awready)  ,
  .awvalid  (sram_awvalid)  ,
  .awaddr   (sram_awaddr )  ,
  .awid     (sram_awid   )  ,
  .awlen    (sram_awlen  )  ,
  .awsize   (sram_awsize )  ,
  .awburst  (sram_awburst)  ,
  .wready   (sram_wready )  ,
  .wvalid   (sram_wvalid )  ,
  .wdata    (sram_wdata  )  ,
  .wstrb    (sram_wstrb  )  ,
  .wlast    (sram_wlast  )  ,
  .bready   (sram_bready )  ,
  .bvalid   (sram_bvalid )  ,
  .bresp    (sram_bresp  )  ,
  .bid      (sram_bid    )  ,
  .arready  (sram_arready)  ,
  .arvalid  (sram_arvalid)  ,
  .araddr   (sram_araddr )  ,
  .arid     (sram_arid   )  ,
  .arlen    (sram_arlen  )  ,
  .arsize   (sram_arsize )  ,
  .arburst  (sram_arburst)  ,
  .rready   (sram_rready )  ,
  .rvalid   (sram_rvalid )  ,
  .rresp    (sram_rresp  )  ,
  .rdata    (sram_rdata  )  ,
  .rlast    (sram_rlast  )  ,
  .rid      (sram_rid    )  
);

Arbiter arbiter(
  .clk         (clk)         ,
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
  .ifu_arready (ifu_arready ),
  .ifu_arvalid (ifu_arvalid ), 
  .ifu_araddr  (ifu_araddr  ), 
  .ifu_arid    (ifu_arid    ), 
  .ifu_arlen   (ifu_arlen   ), 
  .ifu_arsize  (ifu_arsize  ), 
  .ifu_arburst (ifu_arburst ),
  .ifu_rready  (ifu_rready  ),  
  .ifu_rvalid  (ifu_rvalid  ), 
  .ifu_rresp   (ifu_rresp   ),
  .ifu_rdata   (ifu_rdata   ), 
  .ifu_rlast   (ifu_rlast   ), 
  .ifu_rid     (ifu_rid     ), 
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
  .sram_awready(sram_awready), 
  .sram_awvalid(sram_awvalid), 
  .sram_awaddr (sram_awaddr ), 
  .sram_awid   (sram_awid   ),
  .sram_awlen  (sram_awlen  ), 
  .sram_awsize (sram_awsize ), 
  .sram_awburst(sram_awburst), 
  .sram_wready (sram_wready ), 
  .sram_wvalid (sram_wvalid ),
  .sram_wdata  (sram_wdata  ), 
  .sram_wstrb  (sram_wstrb  ), 
  .sram_wlast  (sram_wlast  ), 
  .sram_bready (sram_bready ),
  .sram_bvalid (sram_bvalid ), 
  .sram_bresp  (sram_bresp  ), 
  .sram_bid    (sram_bid    ),
  .sram_arready(sram_arready), 
  .sram_arvalid(sram_arvalid), 
  .sram_araddr (sram_araddr ),
  .sram_arid   (sram_arid   ), 
  .sram_arlen  (sram_arlen  ), 
  .sram_arsize (sram_arsize ),
  .sram_arburst(sram_arburst), 
  .sram_rready (sram_rready ), 
  .sram_rvalid (sram_rvalid ), 
  .sram_rresp  (sram_rresp  ),
  .sram_rdata  (sram_rdata  ), 
  .sram_rlast  (sram_rlast  ), 
  .sram_rid    (sram_rid    ),
  .uart_awready(uart_awready), 
  .uart_awvalid(uart_awvalid), 
  .uart_awaddr (uart_awaddr ),
  .uart_awid   (uart_awid   ), 
  .uart_awlen  (uart_awlen  ), 
  .uart_awsize (uart_awsize ), 
  .uart_awburst(uart_awburst),
  .uart_wready (uart_wready ), 
  .uart_wvalid (uart_wvalid ), 
  .uart_wdata  (uart_wdata  ), 
  .uart_wstrb  (uart_wstrb  ),
  .uart_wlast  (uart_wlast  ), 
  .uart_bready (uart_bready ), 
  .uart_bvalid (uart_bvalid ),
  .uart_bresp  (uart_bresp  ), 
  .uart_bid    (uart_bid    ), 
  .uart_arready(uart_arready), 
  .uart_arvalid(uart_arvalid), 
  .uart_araddr (uart_araddr ),
  .uart_arid   (uart_arid   ), 
  .uart_arlen  (uart_arlen  ), 
  .uart_arsize (uart_arsize ),
  .uart_arburst(uart_arburst), 
  .uart_rready (uart_rready ), 
  .uart_rvalid (uart_rvalid ), 
  .uart_rresp  (uart_rresp  ),
  .uart_rdata  (uart_rdata  ), 
  .uart_rlast  (uart_rlast  ), 
  .uart_rid    (uart_rid    )
);

Uart uart(
  .clk(clk),
  .awready  (uart_awready)  ,
  .awvalid  (uart_awvalid)  ,
  .awaddr   (uart_awaddr )  ,
  .awid     (uart_awid   )  ,
  .awlen    (uart_awlen  )  ,
  .awsize   (uart_awsize )  ,
  .awburst  (uart_awburst)  ,
  .wready   (uart_wready )  ,
  .wvalid   (uart_wvalid )  ,
  .wdata    (uart_wdata  )  ,
  .wstrb    (uart_wstrb  )  ,
  .wlast    (uart_wlast  )  ,
  .bready   (uart_bready )  ,
  .bvalid   (uart_bvalid )  ,
  .bresp    (uart_bresp  )  ,
  .bid      (uart_bid    )  ,
  .arready  (uart_arready)  ,
  .arvalid  (uart_arvalid)  ,
  .araddr   (uart_araddr )  ,
  .arid     (uart_arid   )  ,
  .arlen    (uart_arlen  )  ,
  .arsize   (uart_arsize )  ,
  .arburst  (uart_arburst)  ,
  .rready   (uart_rready )  ,
  .rvalid   (uart_rvalid )  ,
  .rresp    (uart_rresp  )  ,
  .rdata    (uart_rdata  )  ,
  .rlast    (uart_rlast  )  ,
  .rid      (uart_rid    )  
);

Idu idu(
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
  .clk(clk),
  .rf_in(rf),
  .rf_out(rf),
  .wen(wen),
  .CSRctr(CSRctr),
  .IFU_valid(IFU_valid),
  .IDU_ready(IDU_ready),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready));

  Exu exu(
  .clk(clk),
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

  Wbu wbu(
  .rs1(src1),
  .imm(imm),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .pc(pc),
  .wdata(wd),
  .waddr(inst[11:7]),
  .Ra(inst[19:15]),
  .clk(clk),
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

