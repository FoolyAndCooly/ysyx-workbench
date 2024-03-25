import "DPI-C" function void set_npc_state(input byte state);
module ImmGen(
  input [31:0] inst,
  input [2:0] ExtOp,
  output [31:0] imm
  );
  wire [31:0] immI, immU, immS, immB, immJ;
  assign immI = {{20{inst[31]}}, inst[31:20]};
  assign immU = {inst[31:12], 12'b0};
  assign immS = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  assign immB = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  assign immJ = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
  MuxKeyWithDefault #(5, 3, 32) i(imm, ExtOp, 0, {
    3'b000, immI,
    3'b001, immU,
    3'b010, immS,
    3'b011, immB,
    3'b100, immJ
  });
endmodule

module RegisterFile (
  input [4:0] Ra,
  input [4:0] Rb,
  input clk,
  input [31:0] wdata,
  input [4:0] waddr,
  input wen,
  output [31:0] busA,
  output [31:0] busB
);
reg [31:0] rf [31:0];
assign busA = rf[Ra];
assign busB = rf[Rb];
assign rf[0] = 0;
always @(posedge clk) begin
  if (wen && (waddr != 0)) begin
    rf[waddr] = wdata;
  end
end

endmodule

module ContrGen(
  input [4:0] op_6_2,
  input [2:0] func3,
  input func7_5,
  output reg [2:0] ExtOp,
  output reg [3:0] ALUctr,
  output reg ALUAsrc,
  output reg [1:0] ALUBsrc,
  output reg Regw,
  output reg [2:0] branch,
  output reg MemtoReg,
  output reg [2:0] MemOp,
  output reg MemWr
);
reg [18:0] ctr; //1:MemWr 1:MemtoReg 3: MemOp 3: branch  1: RegWr 4: ALUctr, 1: ALUAsrc, 2: ALUBsrc[1:0], ExtOp[2:0]
always @(*) begin
  case (op_6_2)
    5'b00000: begin
      case (func3)
        3'b000: ctr = 19'b0100000010000001000; // lb
        3'b001: ctr = 19'b0100100010000001000; // lh
        3'b010: ctr = 19'b0101000010000001000; // lw
	3'b100: ctr = 19'b0110000010000001000; // lbu
        3'b101: ctr = 19'b0110100010000001000; // lhu
	default: ctr = {19{1'b1}};
      endcase
    end
    5'b00100: begin
      case (func3)
        3'b000: ctr = 19'b0011100010000001000; // addi
	3'b001: ctr = 19'b0011100010001001000; // slli
	3'b010: ctr = 19'b0011100010010001000; // slti
	3'b011: ctr = 19'b0011100011010001000; // sltiu
	3'b100: ctr = 19'b0011100010100001000; // xori
	3'b101: ctr = func7_5 ? 19'b0011100011101001000 : 19'b0011100010101001000; // srai
	3'b110: ctr = 19'b0011100010110001000; // ori
	3'b111: ctr = 19'b0011100010111001000; // andi
	default: ctr = {19{1'b1}};
      endcase
    end
    5'b00101: ctr = 19'b0011100010000101001; // auipc
    5'b01000: begin
      case (func3)
        3'b000: ctr = 19'b1000000000000001010; // sb
        3'b001: ctr = 19'b1000100000000001010; // sh
        3'b010: ctr = 19'b1001000000000001010; // sw
        default: ctr = {19{1'b1}};
      endcase
    end
    5'b01100: begin
      case (func3)
        3'b000: ctr = func7_5 ? 19'b0011100011000000111 : 19'b0011100010000000111; // add
	3'b001: ctr = 19'b0011100010001000111; // sll
	3'b010: ctr = 19'b0011100010010000111; // slt
	3'b011: ctr = 19'b0011100011010000111; // sltu
	3'b100: ctr = 19'b0011100010100000111; // xor
	3'b101: ctr = func7_5 ? 19'b0011100011101000111 : 19'b0011100010101000111;
	3'b110: ctr = 19'b0011100010110000111; // or
	3'b111: ctr = 19'b0011100010111000111; // and
	default: ctr = {19{1'b1}};
      endcase
    end
    5'b01101: ctr = 19'b0011100010011001001; // lui
    5'b11000: begin
      case (func3)
        3'b000: ctr = 19'b0011110000010000011; // beq
	3'b001: ctr = 19'b0011110100010000011; // bne
	3'b100: ctr = 19'b0011111000010000011; // blt
	3'b110: ctr = 19'b0011111001010000011; // bltu
	3'b101: ctr = 19'b0011111100010000011; // bge
	3'b111: ctr = 19'b0011111101010000011; // bgeu
	default: ctr = {19{1'b1}};
      endcase
    end
    5'b11001: ctr = 19'b0011101010000110000; // jalr
    5'b11011: ctr = 19'b0011100110000110100; // jal 
    5'b11100: begin ctr = 0; set_npc_state(2); end //ebreak
    default: ctr = {19{1'b1}};
  endcase
  ExtOp = ctr[2:0];
  ALUBsrc = ctr[4:3];
  ALUAsrc = ctr[5];
  ALUctr = ctr[9:6];
  Regw = ctr[10];
  branch = ctr[13:11];
  MemOp = ctr[16:14];
  MemtoReg = ctr[17];
  MemWr = ctr[18];
end
endmodule
