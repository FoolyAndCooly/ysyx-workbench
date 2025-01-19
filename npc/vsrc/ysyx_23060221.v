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

wire IFU_valid, IDU_ready, IDU_valid, EXU_ready, EXU_valid, LSU_ready, LSU_valid, WBU_ready;

// always @(posedge clock) begin
//   $display("pc       :%08x", pc      );
//   $display("IFU_valid: %d", IFU_valid);
//   $display("IDU_valid: %d", IDU_valid);
//   $display("EXU_valid: %d", EXU_valid);
//   $display("WBU_valid: %d", WBU_valid);
// end


wire [31:0] inst;
wire [31:0] res;
wire [31:0] src1, src2;
wire [31:0] imm;
wire PCAsrc, PCBsrc;

wire [31:0] wd;
wire [3:0] aluctr;
wire aluasrc;
wire [1:0] alubsrc; 
wire [2:0] branch;
wire [2:0] memop;
wire memtoreg;
wire memwr;
wire regw;

wire regwen;
wire csrwen;

wire csrw;
wire csrALU;
wire csrpc;
wire csrcause;

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

wire        lsu_awready ;
wire        lsu_awvalid ;
wire [31:0] lsu_awaddr  ;
wire [3:0]  lsu_awid    ;
wire [7:0]  lsu_awlen   ;
wire [2:0]  lsu_awsize  ;
wire [1:0]  lsu_awburst ;
wire        lsu_wready  ;
wire        lsu_wvalid  ;
wire [31:0] lsu_wdata   ;
wire [3:0]  lsu_wstrb   ;
wire        lsu_wlast   ;
wire        lsu_bready  ;
wire        lsu_bvalid  ;
wire [1:0]  lsu_bresp   ;
wire [3:0]  lsu_bid     ;
wire        lsu_arready ;
wire        lsu_arvalid ;
wire [31:0] lsu_araddr  ;
wire [3:0]  lsu_arid    ;
wire [7:0]  lsu_arlen   ;
wire [2:0]  lsu_arsize  ;
wire [1:0]  lsu_arburst ;
wire        lsu_rready  ;
wire        lsu_rvalid  ;
wire [1:0]  lsu_rresp   ;
wire [31:0] lsu_rdata   ;
wire        lsu_rlast   ;
wire [3:0]  lsu_rid     ;

ysyx_23060221_Ifu ifu(
  .clk      (clock      ),
  .rst      (reset      ),
  .pc       (if_pc      ),
  .IDU_ready(IDU_ready  ),
  .IFU_valid(IFU_valid  ),
  .arready  (ifu_arready),
  .arvalid  (ifu_arvalid),
  .araddr   (ifu_araddr ),
  .arid     (ifu_arid   ),
  .arlen    (ifu_arlen  ),
  .arsize   (ifu_arsize ),
  .arburst  (ifu_arburst),
  .rready   (ifu_rready ),
  .rvalid   (ifu_rvalid ),
  .rresp    (ifu_rresp  ),
  .rlast    (ifu_rlast  ),
  .rid      (ifu_rid    ),
  .ifidwen  (ifidwen    )
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

wire pc_update;
PC_Gen pcgen(
  .clk(clock),
  .rst(reset),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc),
  .syn(ifidwen),
  .rs1(id_src1),
  .imm(id_imm),
  .pc_out(if_pc)
);

wire [31:0] if_inst, if_pc;
wire [31:0] id_inst, id_pc;
wire ifidwen;

Reg #(64, 64'h0000001300000000) ifid(
  .clk(clock),
  .rst(reset | (ifidwen & PCAsrc)),
  .din ({ifu_rdata, if_pc}),
  .dout({id_inst, id_pc}),
  .wen(ifidwen)
);

// wire [1:0] csrraddr;
// wire [1:0] csrwaddr;
// wire [31:0] csrrdata;
// wire [31:0] csrwdata;
// 
// Csr csr(
//   .clk(clock),
//   .rst(reset),
//   .wen(csrwen),
//   .set_cause(csrcause),
//   .raddr(csrraddr),
//   .waddr(csrwaddr),
//   .wdata(csrwdata),
//   .rdata(csrrdata)
// );


wire [4:0] Ra, Rb;
RegisterFile rf(
  .clk(clock),
  .rst(reset),
  .Ra(Ra),
  .Rb(Rb),
  .busA(id_src1),
  .busB(id_src2),
  .wen(regwen),
  .wdata(wd),
  .waddr(wb_waddr)
);

PCCtr pcctr(
  .branch(branch),
  .signal(id_aluctr[3]),
  .rs1(id_src1),
  .rs2(id_src2),
  .PCAsrc(PCAsrc),
  .PCBsrc(PCBsrc)
);

ysyx_23060221_Arbiter arbiter(
  .clk         (clock          ),
  .rst         (reset          ),
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
  .lsu_awready (lsu_awready ), 
  .lsu_awvalid (lsu_awvalid ),
  .lsu_awaddr  (lsu_awaddr  ), 
  .lsu_awid    (lsu_awid    ), 
  .lsu_awlen   (lsu_awlen   ), 
  .lsu_awsize  (lsu_awsize  ),
  .lsu_awburst (lsu_awburst ), 
  .lsu_wready  (lsu_wready  ), 
  .lsu_wvalid  (lsu_wvalid  ), 
  .lsu_wdata   (lsu_wdata   ),
  .lsu_wstrb   (lsu_wstrb   ), 
  .lsu_wlast   (lsu_wlast   ), 
  .lsu_bready  (lsu_bready  ), 
  .lsu_bvalid  (lsu_bvalid  ), 
  .lsu_bresp   (lsu_bresp   ),
  .lsu_bid     (lsu_bid     ), 
  .lsu_arready (lsu_arready ), 
  .lsu_arvalid (lsu_arvalid ),
  .lsu_araddr  (lsu_araddr  ), 
  .lsu_arid    (lsu_arid    ), 
  .lsu_arlen   (lsu_arlen   ),
  .lsu_arsize  (lsu_arsize  ), 
  .lsu_arburst (lsu_arburst ), 
  .lsu_rready  (lsu_rready  ),
  .lsu_rvalid  (lsu_rvalid  ), 
  .lsu_rresp   (lsu_rresp   ), 
  .lsu_rdata   (lsu_rdata   ), 
  .lsu_rlast   (lsu_rlast   ), 
  .lsu_rid     (lsu_rid     ),
  .clint_awready(clint_awready), 
  .clint_awvalid(clint_awvalid),
  .clint_awaddr (clint_awaddr ),
  .clint_awid   (clint_awid   ),
  .clint_awlen  (clint_awlen  ),
  .clint_awsize (clint_awsize ),
  .clint_awburst(clint_awburst),
  .clint_wready (clint_wready ),
  .clint_wvalid (clint_wvalid ),
  .clint_wdata  (clint_wdata  ),
  .clint_wstrb  (clint_wstrb  ),
  .clint_wlast  (clint_wlast  ),
  .clint_bready (clint_bready ),
  .clint_bvalid (clint_bvalid ),
  .clint_bresp  (clint_bresp  ),
  .clint_bid    (clint_bid    ),
  .clint_arready(clint_arready),
  .clint_arvalid(clint_arvalid),
  .clint_araddr (clint_araddr ),
  .clint_arid   (clint_arid   ),
  .clint_arlen  (clint_arlen  ),
  .clint_arsize (clint_arsize ),
  .clint_arburst(clint_arburst),
  .clint_rready (clint_rready ),
  .clint_rvalid (clint_rvalid ),
  .clint_rresp  (clint_rresp  ),
  .clint_rdata  (clint_rdata  ),
  .clint_rlast  (clint_rlast  ),
  .clint_rid    (clint_rid    ),
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
  .clk(clock),
  .rst(reset),
  .inst(id_inst),
  .aluctr (id_aluctr),
  .aluasrc(id_aluasrc),
  .alubsrc(id_alubsrc),
  .branch(branch),
  .Ra(Ra),
  .Rb(Rb),
  .waddr(id_waddr),
  .memop(id_memop),
  .memtoreg(id_memtoreg),
  .memwr(id_memwr),
  .imm(id_imm),
  .regw(id_regw),
  .IFU_valid(IFU_valid),
  .IDU_ready(IDU_ready),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready)
  );

wire [3:0]  id_aluctr;
wire id_aluasrc;
wire [1:0]  id_alubsrc;
wire [31:0] id_imm;
wire [2:0]  id_memop;
wire        id_memwr;
wire [31:0] id_src1;
wire [31:0] id_src2;
wire id_memtoreg;
wire id_regw;
wire [4:0] id_waddr;

wire [3:0]  ex_aluctr;
wire ex_aluasrc;
wire [1:0]  ex_alubsrc;
wire [31:0] ex_imm;
wire [31:0] ex_pc;
wire [2:0]  ex_memop;
wire        ex_memwr;
wire [31:0] ex_src1;
wire [31:0] ex_src2;
wire ex_memtoreg;
wire ex_regw;
wire [4:0] ex_waddr;

// aluctr: 4, aluasrc: 1, alubsrc: 2, imm: 32, pc: 32, memop: 3, memwr: 1, src1: 32, src2: 32, mem2reg: 1, regw: 1, waddr: 5
Reg #(146, {71'b0, 3'b111, 72'b0}) idex(
  .clk(clock),
  .rst(reset),
  .din ({id_aluctr, id_aluasrc, id_alubsrc, id_imm, id_pc, id_memop, id_memwr, id_src1, id_src2, id_memtoreg, id_regw, id_waddr}),
  .dout({ex_aluctr, ex_aluasrc, ex_alubsrc, ex_imm, ex_pc, ex_memop, ex_memwr, ex_src1, ex_src2, ex_memtoreg, ex_regw, ex_waddr}),
  .wen(IFU_valid & IDU_ready)
);

ysyx_23060221_Exu exu(
  .clk(clock),
  .rst(reset),
  .src1(ex_src1),
  .src2(ex_src2),
  .pc(ex_pc),
  .imm(ex_imm),
  .aluctr(ex_aluctr),
  .aluasrc(ex_aluasrc),
  .alubsrc(ex_alubsrc),
  .res(ex_res),
  .IDU_valid(IDU_valid),
  .EXU_ready(EXU_ready),
  .EXU_valid(EXU_valid),
  .LSU_ready(LSU_ready)
);

wire [31:0] ex_res;
wire [2:0] ls_memop;
wire ls_memwr;
wire [31:0] ls_src2;
wire [31:0] ls_res;
wire ls_memtoreg;
wire ls_regw;
wire [4:0] ls_waddr;
wire lswbwen;
// memop: 3, memwr: 1, src2: 32, res: 32, mem2reg: 1, regw: 1, waddr: 5
Reg #(75, {3'b111, 72'b0}) exls(
  .clk(clock),
  .rst(reset),
  .din ({ex_memop, ex_memwr, ex_src2, ex_res, ex_memtoreg, ex_regw, ex_waddr}),
  .dout({ls_memop, ls_memwr, ls_src2, ls_res, ls_memtoreg, ls_regw, ls_waddr}),
  .wen(IDU_valid & EXU_ready)
);

ysyx_23060221_Lsu lsu(
  .clk(clock),
  .rst(reset),
  .res(ls_res),
  .rs2(ls_src2),
  .memop(ls_memop),
  .memwr(ls_memwr),
  .dataout  (ls_dataout),
  .LSU_ready(LSU_ready  ),
  .LSU_valid(LSU_valid  ),
  .WBU_ready(WBU_ready  ),
  .EXU_valid(EXU_valid  ),
  .awready  (lsu_awready),
  .awvalid  (lsu_awvalid),
  .awaddr   (lsu_awaddr ),
  .awid     (lsu_awid   ),
  .awlen    (lsu_awlen  ),
  .awsize   (lsu_awsize ),
  .awburst  (lsu_awburst),
  .wready   (lsu_wready ),
  .wvalid   (lsu_wvalid ),
  .wdata    (lsu_wdata  ),
  .wstrb    (lsu_wstrb  ),
  .wlast    (lsu_wlast  ),
  .bready   (lsu_bready ),
  .bvalid   (lsu_bvalid ),
  .bresp    (lsu_bresp  ),
  .bid      (lsu_bid    ),
  .arready  (lsu_arready),
  .arvalid  (lsu_arvalid),
  .araddr   (lsu_araddr ),
  .arid     (lsu_arid   ),
  .arlen    (lsu_arlen  ),
  .arsize   (lsu_arsize ),
  .arburst  (lsu_arburst),
  .rready   (lsu_rready ),
  .rvalid   (lsu_rvalid ),
  .rresp    (lsu_rresp  ),
  .rdata    (lsu_rdata  ),
  .rlast    (lsu_rlast  ),
  .rid      (lsu_rid    ),
  .lswbwen  (lswbwen    )
);

wire [31:0] ls_dataout;
wire [31:0] wb_res;
wire [31:0] wb_dataout;
wire wb_memtoreg;
wire wb_regw;
wire [4:0] wb_waddr;

// res: 32, dataout: 32, mem2reg: 1, regw: 1, waddr: 5
Reg #(71, 0) lswb(
  .clk(clock),
  .rst(reset),
  .din ({ls_res, ls_dataout, ls_memtoreg, ls_regw, ls_waddr}),
  .dout({wb_res, wb_dataout, wb_memtoreg, wb_regw, wb_waddr}),
  .wen(lswbwen)
);

ysyx_23060221_Wbu wbu(
  .clk      (clock       ),
  .rst      (reset       ),
  .res      (wb_res      ),
  .dataout  (wb_dataout  ),
  .memtoreg (wb_memtoreg ),
  .regw     (wb_regw     ),
  .regwen   (regwen      ),
  .wd       (wd          ),
  .WBU_ready(WBU_ready   ),
  .LSU_valid(LSU_valid   )
  );

wire 	        clint_awvalid;  
wire            clint_awready;
wire [31:0]	clint_awaddr ;  
wire [3:0]	clint_awid   ;  
wire [7:0]	clint_awlen  ;  
wire [2:0]	clint_awsize ;  
wire [1:0]	clint_awburst;  
wire            clint_wready ;          
wire 	        clint_wvalid ;  
wire [31:0]	clint_wdata  ;  
wire [3:0]	clint_wstrb  ;  
wire 	        clint_wlast  ;  
wire 	        clint_bready ;  
wire	        clint_bvalid ;          
wire [1:0]	clint_bresp  ;          
wire [3:0]	clint_bid    ;          
wire            clint_arready;	   
wire 	        clint_arvalid;  
wire [31:0]	clint_araddr ;  
wire [3:0]	clint_arid   ;  
wire [7:0]	clint_arlen  ;  
wire [2:0]	clint_arsize ;  
wire [1:0]	clint_arburst;  
wire 	        clint_rready ;  
wire            clint_rvalid ;          
wire [1:0]	clint_rresp  ;          
wire [31:0]	clint_rdata  ;          
wire 	        clint_rlast  ;          
wire [3:0]	clint_rid    ;          


clint cli(
  .clk    (clock  ), 
  .awready(clint_awready),  
  .awvalid(clint_awvalid), 
  .awaddr (clint_awaddr ),  
  .awid   (clint_awid   ),  
  .awlen  (clint_awlen  ),  
  .awsize (clint_awsize ),  
  .awburst(clint_awburst),  
  .wready (clint_wready ),  
  .wvalid (clint_wvalid ),  
  .wdata  (clint_wdata  ),  
  .wstrb  (clint_wstrb  ),  
  .wlast  (clint_wlast  ),  
  .bready (clint_bready ),  
  .bvalid (clint_bvalid ),
  .bresp  (clint_bresp  ),
  .bid    (clint_bid    ),
  .arready(clint_arready),
  .arvalid(clint_arvalid),  
  .araddr (clint_araddr ),  
  .arid   (clint_arid   ), 
  .arlen  (clint_arlen  ),  
  .arsize (clint_arsize ),  
  .arburst(clint_arburst),  
  .rready (clint_rready ),  
  .rvalid (clint_rvalid ),
  .rresp  (clint_rresp  ),
  .rdata  (clint_rdata  ),
  .rlast  (clint_rlast  ),
  .rid    (clint_rid    ),
  .reset  (reset  )
);
endmodule

`ifdef NPC
module npc(
  input clock,
  input reset
);
wire            awready  ;
wire		awvalid  ;
wire	[31:0]	awaddr   ;
wire	[3:0]	awid	 ;
wire	[7:0]	awlen	 ;
wire	[2:0]	awsize   ;
wire	[1:0]	awburst  ;
wire	        wready   ;
wire		wvalid   ;
wire	[31:0]	wdata	 ;
wire	[3:0]	wstrb	 ;
wire		wlast	 ;
wire		bready   ;
wire	        bvalid   ;
wire    [1:0]	bresp	 ;
wire    [3:0]	bid	 ;
wire	        arready  ;
wire		arvalid  ;
wire	[31:0]	araddr   ;
wire	[3:0]	arid	 ;
wire	[7:0]	arlen	 ;
wire	[2:0]	arsize   ;
wire	[1:0]	arburst  ;
wire		rready   ;
wire	        rvalid   ;
wire    [1:0]	rresp	 ;
wire    [31:0]	rdata	 ;
wire	        rlast	 ;
wire    [3:0]	rid	 ;

ysyx_23060221 cpu(
  .clock            (clock),  
  .reset            (reset),  
  .io_interrupt     (),  
  .io_master_awready(awready ),   
  .io_master_awvalid(awvalid ),  
  .io_master_awaddr (awaddr  ),  
  .io_master_awid   (awid    ),  
  .io_master_awlen  (awlen   ),  
  .io_master_awsize (awsize  ),  
  .io_master_awburst(awburst ),  
  .io_master_wready (wready  ),  
  .io_master_wvalid (wvalid  ),  
  .io_master_wdata  (wdata   ),  
  .io_master_wstrb  (wstrb   ),  
  .io_master_wlast  (wlast   ),  
  .io_master_bready (bready  ),  
  .io_master_bvalid (bvalid  ),  
  .io_master_bresp  (bresp   ), 
  .io_master_bid    (bid     ), 
  .io_master_arready(arready ), 
  .io_master_arvalid(arvalid ), 
  .io_master_araddr (araddr  ), 
  .io_master_arid   (arid    ), 
  .io_master_arlen  (arlen   ), 
  .io_master_arsize (arsize  ), 
  .io_master_arburst(arburst ), 
  .io_master_rready (rready  ), 
  .io_master_rvalid (rvalid  ), 
  .io_master_rresp  (rresp   ), 
  .io_master_rdata  (rdata   ), 
  .io_master_rlast  (rlast   ), 
  .io_master_rid    (rid     ), 
  .io_slave_awready (), 
  .io_slave_awvalid (), 
  .io_slave_awaddr  (), 
  .io_slave_awid    (), 
  .io_slave_awlen   (), 
  .io_slave_awsize  (), 
  .io_slave_awburst (), 
  .io_slave_wready  (), 
  .io_slave_wvalid  (), 
  .io_slave_wdata   (), 
  .io_slave_wstrb   (), 
  .io_slave_wlast   (), 
  .io_slave_bready  (), 
  .io_slave_bvalid  (), 
  .io_slave_bresp   (), 
  .io_slave_bid     (), 
  .io_slave_arready (), 
  .io_slave_arvalid (), 
  .io_slave_araddr  (), 
  .io_slave_arid    (), 
  .io_slave_arlen   (), 
  .io_slave_arsize  (), 
  .io_slave_arburst (), 
  .io_slave_rready  (), 
  .io_slave_rvalid  (),  
  .io_slave_rresp   (),  
  .io_slave_rdata   (),  
  .io_slave_rlast   (),   
  .io_slave_rid     ()
);

axi_queue_sdram sd(
  .clk    (clock  ), 
  .rst    (reset  ),
  .awready(awready),  
  .awvalid(awvalid), 
  .awaddr (awaddr ),  
  .awid   (awid   ),  
  .awlen  (awlen  ),  
  .awsize (awsize ),  
  .awburst(awburst),  
  .wready (wready ),  
  .wvalid (wvalid ),  
  .wdata  (wdata  ),  
  .wstrb  (wstrb  ),  
  .wlast  (wlast  ),  
  .bready (bready ),  
  .bvalid (bvalid ),
  .bresp  (bresp  ),
  .bid    (bid    ),
  .arready(arready),
  .arvalid(arvalid),  
  .araddr (araddr ),  
  .arid   (arid   ),  
  .arlen  (arlen  ),  
  .arsize (arsize ),  
  .arburst(arburst),  
  .rready (rready ),  
  .rvalid (rvalid ),
  .rresp  (rresp  ),
  .rdata  (rdata  ),
  .rlast  (rlast  ),
  .rid    (rid    )
);

endmodule
`endif
