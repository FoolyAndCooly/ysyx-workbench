import "DPI-C" function bit cache_check(input int index, input int tag);
import "DPI-C" function void cache_read(input int index, input int offset, output int data);
import "DPI-C" function void cache_write(input int index, input int data, input int tag, input int count);

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

  wire [OFFSET_WIDTH-1:0] offset = in_araddr_r[OFFSET_WIDTH-1:0];
  wire [INDEX_WIDTH-1:0]  index = in_araddr_r[INDEX_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
  wire [31-OFFSET_WIDTH-INDEX_WIDTH:0] tag = in_araddr_r[31:INDEX_WIDTH+OFFSET_WIDTH];

  typedef enum [2:0] {idle_t, check_t, req_t, trans_t, data_t} state_t;
  reg [2:0] state;

  always @(posedge clk) begin
    case (state) 
      idle_t: state <= (in_arvalid & in_arready) ? check_t: idle_t;
      check_t: state <= (cache_check({{(32-INDEX_WIDTH){1'd0}}, index}, {{(OFFSET_WIDTH+INDEX_WIDTH){1'd0}}, tag})) ? data_t: req_t;
      data_t: state <= idle_t;
      req_t: state <= (out_arvalid & out_arready) ? trans_t :req_t;
      trans_t: state <= (out_rlast) ? data_t : trans_t;
      default: state <= state;
    endcase
  end
 
  assign in_arready = in_arvalid;

  reg [31:0] in_araddr_r;
  always @(posedge clk) begin
    in_araddr_r <= (state == idle_t) ? in_araddr : in_araddr_r;
  end

  reg in_rvalid_r;
  reg [31:0] in_rdata_r;
  assign in_rlast = in_rvalid;
  assign in_rvalid = in_rvalid_r;
  assign in_rdata = in_rdata_r;
  always @(posedge clk) begin
    in_rvalid_r <= (state == data_t) ? 'd1 : 'd0;
    if (state == data_t) cache_read({{(32-INDEX_WIDTH){1'd0}}, index}, {{(32-OFFSET_WIDTH){1'd0}}, offset}, in_rdata_r);
  end
  
  reg out_arvalid_r;
  reg [31:0] out_araddr_r;
  assign out_araddr = out_araddr_r;
  assign out_arvalid = out_arvalid_r;
  assign out_arlen = (BLOCK_SIZE >> 2)-1;
  assign out_arsize = 3'b010;
  assign out_arburst = 2'b01;
  always @(posedge clk) begin
    if (state == req_t) begin
      out_araddr_r <= in_araddr_r & {{(32-OFFSET_WIDTH){1'b1}}, {OFFSET_WIDTH{1'b0}}};
      out_arvalid_r <= (out_arvalid & out_arready) ? 1'd0 : 1'd1;
    end
  end

  reg [3:0] count;
  assign out_rready = out_rvalid;
  always @(posedge clk) begin
    if (state == trans_t) begin
      if (out_rvalid & out_rready) begin
        cache_write({{(32-INDEX_WIDTH){1'd0}}, index}, out_rdata,{{(OFFSET_WIDTH+INDEX_WIDTH){1'd0}}, tag}, {{28{1'b0}}, count});
        count <= count + 1;
      end
    end
    else count <= 0;
  end
endmodule
