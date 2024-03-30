import "DPI-C" function void set_npc_state(input byte state);
`define MEPC 0
`define MSTATUS 1
`define MCAUSE 2
`define MTVEC 3
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
  input CSRctr,
  output [31:0] busA,
  output [31:0] busB
);
reg [31:0] rf [31:0];
reg [31:0] csr[3:0]; // 0:mepc, 1:mstatus, 2:mcause, 3:mtvec
assign busA = (CSRctr) ? csr[`MTVEC] : rf[Ra];
assign busB = rf[Rb];
assign rf[0] = 0;
always @(posedge clk) begin
  if (wen && (waddr != 0)) begin
    rf[waddr] = wdata;
  end
  if (CSRctr) begin
    csr[`MCAUSE] = 11;
    csr[`MEPC] = wdata;
  end
end

endmodule

module ContrGen(
  input [4:0] op_6_2,
  input [2:0] func3,
  input func7_5,
  input inst20,
  output reg [2:0] ExtOp,
  output reg [3:0] ALUctr,
  output reg ALUAsrc,
  output reg [1:0] ALUBsrc,
  output reg Regw,
  output reg [2:0] branch,
  output reg MemtoReg,
  output reg [2:0] MemOp,
  output reg MemWr,
  output reg CSRctr
);
reg [19:0] ctr; //1:csrCtr 1:MemWr 1:MemtoReg 3: MemOp 3: branch  1: RegWr 4: ALUctr, 1: ALUAsrc, 2: ALUBsrc[1:0], ExtOp[2:0]
always @(*) begin
  case (op_6_2)
    5'b00000: begin
      case (func3)
        3'b000: ctr = 20'b00100000010000001000; // lb
        3'b001: ctr = 20'b00100100010000001000; // lh
        3'b010: ctr = 20'b00101000010000001000; // lw
	3'b100: ctr = 20'b00110000010000001000; // lbu
        3'b101: ctr = 20'b00110100010000001000; // lhu
	default: ctr = {20{1'b1}};
      endcase
    end
    5'b00100: begin
      case (func3)
        3'b000: ctr = 20'b00011100010000001000; // addi
	3'b001: ctr = 20'b00011100010001001000; // slli
	3'b010: ctr = 20'b00011100010010001000; // slti
	3'b011: ctr = 20'b00011100011010001000; // sltiu
	3'b100: ctr = 20'b00011100010100001000; // xori
	3'b101: ctr = func7_5 ? 20'b00011100011101001000 : 20'b00011100010101001000; // srai
	3'b110: ctr = 20'b00011100010110001000; // ori
	3'b111: ctr = 20'b00011100010111001000; // andi
	default: ctr = {20{1'b1}};
      endcase
    end
    5'b00101: ctr = 20'b00011100010000101001; // auipc
    5'b01000: begin
      case (func3)
        3'b000: ctr = 20'b01000000000000001010; // sb
        3'b001: ctr = 20'b01000100000000001010; // sh
        3'b010: ctr = 20'b01001000000000001010; // sw
        default: ctr = {20{1'b1}};
      endcase
    end
    5'b01100: begin
      case (func3)
        3'b000: ctr = func7_5 ? 20'b00011100011000000111 : 20'b00011100010000000111; // add
	3'b001: ctr = 20'b00011100010001000111; // sll
	3'b010: ctr = 20'b00011100010010000111; // slt
	3'b011: ctr = 20'b00011100011010000111; // sltu
	3'b100: ctr = 20'b00011100010100000111; // xor
	3'b101: ctr = func7_5 ? 20'b00011100011101000111 : 20'b00011100010101000111;
	3'b110: ctr = 20'b00011100010110000111; // or
	3'b111: ctr = 20'b00011100010111000111; // and
	default: ctr = {20{1'b1}};
      endcase
    end
    5'b01101: ctr = 20'b00011100010011001001; // lui
    5'b11000: begin
      case (func3)
        3'b000: ctr = 20'b00011110000010000011; // beq
	3'b001: ctr = 20'b00011110100010000011; // bne
	3'b100: ctr = 20'b00011111000010000011; // blt
	3'b110: ctr = 20'b00011111001010000011; // bltu
	3'b101: ctr = 20'b00011111100010000011; // bge
	3'b111: ctr = 20'b00011111101010000011; // bgeu
	default: ctr = {20{1'b1}};
      endcase
    end
    5'b11001: ctr = 20'b00011101010000110000; // jalr
    5'b11011: ctr = 20'b00011100110000110100; // jal 
    5'b11100:
      case (func3)
        3'b001: ctr = 20'b10011100010000000000; // csrrw
        3'b000: begin
	  if (inst20) begin ctr = {20{1'b1}}; set_npc_state(2); end //ebreak
          else begin ctr = 20'b10011101000000000000; end // ecall
	end
    default: ctr = {20{1'b1}};
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
  CSRctr = ctr[19];
end
endmodule
