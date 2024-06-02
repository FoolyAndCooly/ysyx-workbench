module Ifu(
  input clk,
  input [31:0] pc,
  input reg WBU_valid,
  input reg IDU_ready,
  output reg IFU_valid,
  output reg IFU_ready,
  output reg [31:0] inst,
  output [2:0] memop,
  output [31:0] awaddr,
  output [31:0] wdata,
  output awready,
  output awvalid,
  output reg arready,
  output reg arvalid,
  input memfinish
  );

  wire syn_IFU_IDU, syn_WBU_IFU;
  assign syn_IFU_IDU = IFU_valid & IDU_ready; 
  assign syn_WBU_IFU = WBU_valid & IFU_ready;

  always @(posedge clk) begin
    // $strobe("IFU_valid %d", IFU_valid);
    // $strobe("WBU_valid %d", WBU_valid);
    // $strobe("IFU_ready %d", IFU_ready);
    if (syn_WBU_IFU) IFU_ready <= 0;
    if (syn_IFU_IDU) begin 
      IFU_valid <= 0;
      IFU_ready <= 1;
    end
  end

  assign memop = 3'b010;

  always @(posedge clk) begin
    if (syn_WBU_IFU) begin
      // $display("IFU");
      arvalid <= 1;
    end
    else begin
      if (arready & arvalid) begin
        arvalid <= 0;
      end
    end
    //$display("memfinish %d", memfinish);
    if (memfinish) begin
      IFU_valid <= 1;
    end
  end
endmodule

