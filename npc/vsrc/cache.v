`define IDLE 3'd0
`define CHECK 3'd1
`define REQ 3'd2
`define TRANS 3'd3
`define DATA 3'd4

module cache(
  input             clk  ,
  input             rst  ,
  output         in_arready ,
  input          in_arvalid ,
  input  [31:0]  in_araddr  ,
  input  [3:0]   in_arid    ,
  input  [7:0]   in_arlen   ,
  input  [2:0]   in_arsize  ,
  input  [1:0]   in_arburst ,
  input          in_rready  ,
  output         in_rvalid  ,
  output [1:0]   in_rresp   ,
  output [31:0]  in_rdata   ,
  output         in_rlast   ,
  output [3:0]   in_rid     ,
  input          out_arready ,
  output         out_arvalid ,
  output  [31:0] out_araddr  ,
  output  [3:0]  out_arid    ,
  output  [7:0]  out_arlen   ,
  output  [2:0]  out_arsize  ,
  output  [1:0]  out_arburst ,
  output         out_rready  ,
  input          out_rvalid  ,
  input [1:0]    out_rresp   ,
  input [31:0]   out_rdata   ,
  input          out_rlast   ,
  input [3:0]    out_rid      
);
  parameter BLOCK_SIZE =  4;
  parameter OFFSET_WIDTH = $clog2(BLOCK_SIZE);
  parameter BLOCK_NUM  = 16;
  parameter INDEX_WIDTH = $clog2(BLOCK_NUM);
  parameter TAG_WIDTH = 32 - OFFSET_WIDTH - INDEX_WIDTH;

  reg [BLOCK_NUM-1:0] cache_tag[0:TAG_WIDTH-1];
  reg [BLOCK_NUM-1:0] cache_valid;
  reg [BLOCK_NUM-1:0] cache_data[0:(OFFSET_WIDTH<<3)-1];

  wire [OFFSET_WIDTH-1:0] offset = in_araddr_r[OFFSET_WIDTH-1:0];
  wire [INDEX_WIDTH-1:0]  index = in_araddr_r[INDEX_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
  wire [31-OFFSET_WIDTH-INDEX_WIDTH:0] tag = in_araddr_r[31:INDEX_WIDTH+OFFSET_WIDTH];

  reg [2:0] state;

  wire check = (cache_tag[index]==tag) & cache_valid[index];
  always @(posedge clk) begin
    case (state) 
      `IDLE: state <= (in_arvalid & in_arready) ? `CHECK: `IDLE;
      `CHECK: state <= (check) ? `DATA: `REQ;
      `DATA: state <= `IDLE;
      `REQ: state <= (out_arvalid & out_arready) ? `TRANS :`REQ;
      `TRANS: state <= (out_rlast) ? `DATA : `TRANS;
      default: state <= state;
    endcase
  end
 
  assign in_arready = in_arvalid;

  reg [31:0] in_araddr_r;
  always @(posedge clk) begin
    in_araddr_r <= (state == `IDLE) ? in_araddr : in_araddr_r;
  end

  reg in_rvalid_r;
  reg [31:0] in_rdata_r;
  assign in_rlast = in_rvalid;
  assign in_rvalid = in_rvalid_r;
  assign in_rdata = in_rdata_r;
  always @(posedge clk) begin
    in_rvalid_r <= (state == `DATA) ? 'd1 : 'd0;
    if (state == `DATA)  in_rdata_r <= cache_data[index][(offset<<3)+:32];
  end
  
  reg out_arvalid_r;
  reg [31:0] out_araddr_r;
  assign out_araddr = out_araddr_r;
  assign out_arvalid = out_arvalid_r;
  assign out_arlen = (BLOCK_SIZE >> 2)-1;
  assign out_arsize = 3'b010;
  assign out_arburst = 2'b01;
  always @(posedge clk) begin
    if (state == `REQ) begin
      out_araddr_r <= in_araddr_r & {{(32-OFFSET_WIDTH){1'b1}}, {OFFSET_WIDTH{1'b0}}};
      out_arvalid_r <= (out_arvalid & out_arready) ? 1'd0 : 1'd1;
    end
  end

  reg [8:0] count;
  assign out_rready = out_rvalid;
  always @(posedge clk) begin
    if (state == `TRANS) begin
      if (out_rvalid & out_rready) begin
	cache_tag[index] <= tag;
	cache_valid[index] <= 1'd1;
	cache_data[index] <= out_rdata;
        count <= count + 1;
      end
    end
    else count <= 0;
  end
endmodule
