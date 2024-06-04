import "DPI-C" function int pmem_read(input int raddr, input int len);
import "DPI-C" function void pmem_write(
  input int waddr, input byte len, input int wdata);

module Alu(
  input [31:0] a,
  input [31:0] b,
  input [3:0] ctr,
  output [31:0] ans,
  output less,
  output zero
);
  reg [31:0] res;
  assign less = ctr[3] ? (a < b) : ($signed(a) < $signed(b));
  assign zero = (res == 0);
  always @(*) begin
    case(ctr[2:0])
      3'b000: res = ctr[3] ? (a - b) : (a + b);
      3'b001: res = a << b[5:0];
      3'b010: res = a - b; 
      3'b011: res = b;
      3'b100: res = a ^ b;
      3'b101: begin
        if(ctr[3]) begin
	  res = $signed(a) >>> b[5:0];
	end
	else begin
	  res = a >> b[5:0];
	end
      end
      3'b110: res = a | b;
      3'b111: res = a & b;
      default: res = 0;
    endcase
  end
  assign ans = (ctr[2:0] == 3'b010) ? {{31{1'b0}}, less} : res;
endmodule

module BranchCond(
  input [2:0] branch,
  input zero,
  input less,
  output reg PCAsrc,
  output reg PCBsrc
);
  always @(*) begin
    PCBsrc = (branch == 3'b010) ? 1 : 0;
    case(branch)
      3'b000: PCAsrc = 0;
      3'b001: PCAsrc = 1;
      3'b010: PCAsrc = 1;
      3'b100: PCAsrc = zero;
      3'b101: PCAsrc = ~zero;
      3'b110: PCAsrc = less;
      3'b111: PCAsrc = ~less;
      default: PCAsrc = 0;
    endcase
  end
endmodule

module Exu(
  input         clk      ,
  input  [31:0] src1     ,
  input  [31:0] src2     ,
  input  [31:0] pc       ,
  input  [31:0] imm      ,
  input  [3:0]  aluctr   ,
  input         aluasrc  ,
  input  [1:0]  alubsrc  ,
  input  [2:0]  branch   ,
  output        PCAsrc   ,
  output        PCBsrc   ,
  input  [2:0]  memop    ,
  input         memwr    ,
  input         memtoreg ,
  output [31:0] wd       ,
  output reg    EXU_ready,
  output reg    EXU_valid,
  input  reg    WBU_ready,
  input  reg    IDU_valid,
  input         awready  ,
  output        awvalid  ,
  output [31:0] awaddr   ,
  output [3:0]  awid     ,
  output [7:0]  awlen    ,
  output [2:0]  awsize   ,
  output [1:0]  awburst  ,
  input         wready   ,
  output        wvalid   ,
  output [63:0] wdata    ,
  output [7:0]  wstrb    ,
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
  input [63:0]  rdata    ,
  input         rlast    ,
  input [3:0]   rid      ,
  output reg [31:0] res
  );
wire syn_IDU_EXU, syn_EXU_WBU;
assign syn_IDU_EXU = IDU_valid & EXU_ready;
assign syn_EXU_WBU = EXU_valid & WBU_ready;
always @(posedge clk) begin
  if (syn_IDU_EXU) begin 
    // $display("EXU");
    EXU_ready <= 0;
  end
  if (syn_EXU_WBU) begin
    EXU_valid <= 0;
    EXU_ready <= 1;
  end
end

wire [31:0] a;
wire [31:0] b;
MuxKey #(2, 1, 32)  i1 (a, aluasrc, {
  1'b0, src1,
  1'b1, pc
});
MuxKey #(3, 2, 32) i2 (b, alubsrc, {
  2'b00, src2,
  2'b01, imm,
  2'b10, 32'd4
});
wire less, zero, memfinish;
assign memfinish = (bvalid & bready) | (rvalid & rready);
Alu a0 (.a (a), .b(b), .ctr(aluctr), .ans(res), .less(less), .zero(zero));
BranchCond bc(
.branch(branch),
.zero(zero),
.less(less),
.PCAsrc(PCAsrc),
.PCBsrc(PCBsrc));

always @(posedge clk) begin
  if (syn_IDU_EXU & (memop == 3'b111))
    EXU_valid <= 1;
  else if (memfinish) begin
    EXU_valid <= 1;
  end
end

MuxKey #(2, 1, 32)  mr (wd, memtoreg, {
  1'b0, res,
  1'b1, rdata[31:0]
});

/*************AXI-master**************/

/*************register**************/
reg        reg_awvalid;
reg [31:0] reg_awaddr ;
reg        reg_wvalid ;
reg [31:0] reg_wdata  ;
reg        reg_arvalid;
reg [31:0] reg_araddr ;
reg        reg_rready ;
reg [31:0] reg_rdata  ;
reg        reg_bready ;

/*************wire***************/
wire wstart;
wire rstart;
/*************assign**************/
assign wstart = syn_IDU_EXU & ~memwr & (memop != 3'b111);
assign rstart = syn_IDU_EXU & memwr & (memop != 3'b111) ;

assign awvalid = reg_awvalid;
assign awaddr  = reg_awaddr ;
assign awid    = 'd0        ;    
assign awlen   = 'd1        ;
assign awsize  = 3'b010     ;
assign awburst = 2'b01      ;

assign wvalid  = reg_wvalid ;
assign wdata   = {{32{1'b0}},reg_wdata} ;
assign wstrb   = (memop == 3'b000) ? 8'b00000001 : ((memop == 3'b001) ? 8'b00000011 : 8'b00001111);
assign wlast   = wvalid & wready;

assign arvalid = reg_arvalid;
assign araddr  = reg_araddr ;
assign arid    = 'd0        ;
assign arsize  = 3'b010     ;
assign arlen   = 'd1        ;
assign arburst = 2'b01      ;

assign rready  = reg_rready ;

assign bready  = reg_bready ;

/*************process**************/

always @(posedge clk) begin
  if (awvalid & awready)
    reg_awvalid <= 'd0;
  else if(wstart)
    reg_awvalid <= 'd1;
  else
    reg_awvalid <= reg_awvalid;
end

always @(posedge clk) begin
  if (wstart) 
    reg_awaddr <= res;
  else
    reg_awaddr <= reg_awaddr;
end

always @(posedge clk) begin
  if (wlast)
    reg_wvalid <= 'd0;
  else if (awvalid & awready)
    reg_wvalid <= 'd1;
  else 
    reg_wvalid <= reg_wvalid;
end

always @(posedge clk) begin
  if (wvalid & wready)
    reg_wdata <= src2;
  else 
    reg_wdata <= reg_wdata;
end

always @(posedge clk) begin
  if (bvalid & bready)
    reg_bready <= 'd0;
  else if (wlast)
    reg_bready <= 'd1;
  else 
    reg_bready <= reg_bready;
end

always @(posedge clk) begin
  if (arvalid & arready)
    reg_arvalid <= 'd0;
  else if (rstart)
    reg_arvalid <= 'd1;
  else 
    reg_arvalid <= reg_arvalid;
end

always @(posedge clk) begin
  if (rstart)
    reg_araddr <= src2;
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

always @(posedge clk) begin
  if (rvalid & rready)
    reg_rdata <= rdata[31:0];
  else 
    reg_rdata <= reg_rdata;
end

endmodule
