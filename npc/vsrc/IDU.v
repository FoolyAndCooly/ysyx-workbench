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
  input [2:0] CSRctr,
  output [31:0] busA,
  output [31:0] busB,
  input reg [31:0] rf_in [31:0],
  output reg [31:0] rf_out [31:0],
  input reg [31:0] csr[3:0] // 0:mepc, 1:mstatus, 2:mcause, 3:mtvec
);

  wire [31:0] def;
  assign def = rf_in[Ra];
  MuxKeyWithDefault #(2, 3, 32) d (busA, CSRctr, def, {
    3'b001, csr[`MTVEC],
    3'b100, csr[`MEPC]
  });
  assign busB = rf_in[Rb];
  assign rf_out[0] = 0;

endmodule

module ContrGen(
  input [4:0] op_6_2,
  input [2:0] func3,
  input func7_5,
  input inst20,
  input inst21,
  input clk,
  input syn,
  output reg IDU_valid,
  output reg [2:0] ExtOp,
  output reg [3:0] ALUctr,
  output reg ALUAsrc,
  output reg [1:0] ALUBsrc,
  output reg Regw,
  output reg [2:0] branch,
  output reg MemtoReg,
  output reg [2:0] MemOp,
  output reg MemWr,
  output reg [2:0] CSRctr
);
reg [21:0] ctr;
// 3:csrCtr 1:MemWr 1:MemtoReg 3: MemOp 3: branch  1: RegWr 4: ALUctr, 1: ALUAsrc, 2: ALUBsrc[1:0], ExtOp[2:0]
// 001: ecall, 010: csrrw, 011: csrrs, 100: mret
always @(posedge clk) begin
  if (syn) begin
  case (op_6_2)
    5'b00000: begin
      case (func3)
        3'b000: ctr <= 22'b0000100000010000001000; // lb
        3'b001: ctr <= 22'b0000100100010000001000; // lh
        3'b010: ctr <= 22'b0000101000010000001000; // lw
	3'b100: ctr <= 22'b0000110000010000001000; // lbu
        3'b101: ctr <= 22'b0000110100010000001000; // lhu
	default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
      endcase
    end
    5'b00100: begin
      case (func3)
        3'b000: ctr <= 22'b0000011100010000001000; // addi
	3'b001: ctr <= 22'b0000011100010001001000; // slli
	3'b010: ctr <= 22'b0000011100010010001000; // slti
	3'b011: ctr <= 22'b0000011100011010001000; // sltiu
	3'b100: ctr <= 22'b0000011100010100001000; // xori
	3'b101: ctr <= func7_5 ? 22'b0000011100011101001000 : 22'b0000011100010101001000; // srai
	3'b110: ctr <= 22'b0000011100010110001000; // ori
	3'b111: ctr <= 22'b0000011100010111001000; // andi
	default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
      endcase
    end
    5'b00101: ctr <= 22'b0000011100010000101001; // auipc
    5'b01000: begin
      case (func3)
        3'b000: ctr <= 22'b0001000000000000001010; // sb
        3'b001: ctr <= 22'b0001000100000000001010; // sh
        3'b010: ctr <= 22'b0001001000000000001010; // sw
        default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
      endcase
    end
    5'b01100: begin
      case (func3)
        3'b000: ctr <= func7_5 ? 22'b0000011100011000000111 : 22'b0000011100010000000111; // add
	3'b001: ctr <= 22'b0000011100010001000111; // sll
	3'b010: ctr <= 22'b0000011100010010000111; // slt
	3'b011: ctr <= 22'b0000011100011010000111; // sltu
	3'b100: ctr <= 22'b0000011100010100000111; // xor
	3'b101: ctr <= func7_5 ? 22'b0000011100011101000111 : 22'b0000011100010101000111;
	3'b110: ctr <= 22'b0000011100010110000111; // or
	3'b111: ctr <= 22'b0000011100010111000111; // and
	default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
      endcase
    end
    5'b01101: ctr <= 22'b0000011100010011001001; // lui
    5'b11000: begin
      case (func3)
        3'b000: ctr <= 22'b0000011110000010000011; // beq
	3'b001: ctr <= 22'b0000011110100010000011; // bne
	3'b100: ctr <= 22'b0000011111000010000011; // blt
	3'b110: ctr <= 22'b0000011111001010000011; // bltu
	3'b101: ctr <= 22'b0000011111100010000011; // bge
	3'b111: ctr <= 22'b0000011111101010000011; // bgeu
	default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
      endcase
    end
    5'b11001: ctr <= 22'b0000011101010000110000; // jalr
    5'b11011: ctr <= 22'b0000011100110000110100; // jal 
    5'b11100: begin
      case (func3)
        3'b001: ctr <= 22'b0100011100000011001000; // csrrw
	3'b010: ctr <= 22'b0110011100000011001000; // csrrs
        3'b000: begin
	  if (inst20) begin ctr <= {22{1'b1}}; set_npc_state(2); end //ebreak
          else if (inst21) begin ctr <= 22'b1000011101000000000111; end // mret
	  else begin ctr <= 22'b0010011101000000101111; end // ecall
	end
        default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
      endcase
    end
    default: begin ctr <= {22{1'b1}}; set_npc_state(2); end
  endcase
  IDU_valid <= 1;
  // $display("IDU");
  end
  // $display("memop: %b", MemOp);
  // $display("ctr: %b", ctr);
end

assign  ExtOp = ctr[2:0];
assign  ALUBsrc = ctr[4:3];
assign  ALUAsrc = ctr[5];
assign  ALUctr = ctr[9:6];
assign  Regw = ctr[10];
assign  branch = ctr[13:11];
assign  MemOp = ctr[16:14];
assign  MemtoReg = ctr[17];
assign  MemWr = ctr[18];
assign  CSRctr = ctr[21:19];

endmodule

module ysyx_23060221_Idu(
  input [31:0] inst,
  input clk,
  output [3:0] aluctr,
  output aluasrc,
  output [1:0] alubsrc,
  output [2:0] branch,
  output [2:0] memop,
  output memtoreg,
  output memwr,
  output [31:0] src1,
  output [31:0] src2,
  output [31:0] imm,
  input reg [31:0] csr[3:0],
  input reg [31:0] rf_in[31:0],
  output reg [31:0] rf_out[31:0],
  output [2:0] CSRctr,
  output wen,
  output reg IDU_ready,
  output reg IDU_valid,
  input reg EXU_ready,
  input reg IFU_valid
);
  wire [2:0] extop;
  wire syn_IFU_IDU, syn_IDU_EXU;
  assign syn_IFU_IDU = IFU_valid & IDU_ready;
  assign syn_IDU_EXU = IDU_valid & EXU_ready;

  always @(posedge clk) begin
    if (syn_IFU_IDU) IDU_ready <= 0;
    if (syn_IDU_EXU) begin 
      IDU_valid <= 0;
      IDU_ready <= 1;
    end
  end
  ContrGen cg (
  .op_6_2 (inst[6:2]), 
  .func3 (inst[14:12]),
  .func7_5 (inst[30]),
  .inst20(inst[20]),
  .inst21(inst[21]),
  .ExtOp(extop), 
  .ALUctr(aluctr), 
  .ALUAsrc(aluasrc), 
  .ALUBsrc(alubsrc), 
  .Regw(wen),
  .CSRctr(CSRctr),
  .branch(branch),
  .MemOp(memop),
  .MemtoReg(memtoreg),
  .MemWr(memwr),
  .IDU_valid(IDU_valid),
  .clk(clk),
  .syn(syn_IFU_IDU));

  RegisterFile rf (
  .Ra(inst[19:15]),
  .Rb(inst[24:20]),
  .CSRctr(CSRctr),
  .busA(src1), 
  .busB(src2),
  .rf_in(rf_in),
  .rf_out(rf_out),
  .csr(csr));

  ImmGen ig (inst, extop, imm);
endmodule
