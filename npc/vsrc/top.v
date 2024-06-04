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

DataMem ifu_dm(
  .clk(clk),
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

DataMem exu_dm(
  .clk(clk),
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

