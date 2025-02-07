`define MEPC 2'b00
`define MSTATUS 2'b01
`define MCAUSE 2'b10
`define MTVEC 2'b11

`ifndef SYNTHESIS
import "DPI-C" function void set_npc_state(input byte state, input byte info);
import "DPI-C" function void ali_count(input int addr);
import "DPI-C" function void lsi_count(input int addr);
import "DPI-C" function void cfi_count(input int addr);
import "DPI-C" function void csr_count(input int addr);
`endif

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
  // 3'b111, R
endmodule

module PCCtr(
  input [2:0] branch,
  input signal,
  input [31:0] rs1, rs2,
  output PCAsrc, PCBsrc
);
  wire zero = (rs1 == rs2);
  wire less = signal ? (rs1 < rs2) : ($signed(rs1) < $signed(rs2));
  reg PCAsrc_reg, PCBsrc_reg;
  assign PCAsrc = PCAsrc_reg;
  assign PCBsrc = PCBsrc_reg;
  always @(*) begin
    PCBsrc_reg = (branch == 3'b010) ? 1 : 0;
    case(branch)
      3'b000:  PCAsrc_reg = 0;
      3'b001:  PCAsrc_reg = 1;
      3'b010:  PCAsrc_reg = 1;
      3'b100:  PCAsrc_reg = zero;
      3'b101:  PCAsrc_reg = ~zero;
      3'b110:  PCAsrc_reg = less;
      3'b111:  PCAsrc_reg = ~less;
      default: PCAsrc_reg = 0;
    endcase
  end
endmodule

module bypass(
  input [4:0] Ra,
  input [4:0] Rb,
  input [4:0] idexRd,
  input [4:0] exlsRd,
  input [4:0] lswbRd,
  input idexwreg,
  input exlswreg,
  input lswbwreg,
  output ca1,
  output ca2,
  output cb1,
  output cb2,
  output ca3,
  output cb3,
  input Raable,
  input Rbable
);
  assign ca1 = idexwreg & (idexRd != 0) & ((idexRd == Ra) & Raable);
  assign cb1 = idexwreg & (idexRd != 0) & ((idexRd == Rb) & Rbable);
  assign ca2 = exlswreg & (exlsRd != 0) & (((exlsRd == Ra) & (idexRd != Ra)) & Raable);
  assign cb2 = exlswreg & (exlsRd != 0) & (((exlsRd == Rb) & (idexRd != Rb)) & Rbable);
  assign ca3 = lswbwreg & (lswbRd != 0) & (((lswbRd == Ra) & (idexRd != Ra) & (exlsRd != Ra)) & Raable);
  assign cb3 = lswbwreg & (lswbRd != 0) & (((lswbRd == Rb) & (idexRd != Rb) & (exlsRd != Rb)) & Rbable);
endmodule

module Csr(
  input clk,
  input rst,
  input wen,
  input set_cause,
  input [1:0] raddr,
  input [1:0] waddr,
  input [31:0] wdata,
  output [31:0] rdata
);
  reg [31:0] csr[0:3]; // 0:mepc, 1:mstatus, 2:mcause, 3:mtvec
  assign rdata = csr[raddr];
  always @(posedge clk) begin
    if (rst) 
      csr[`MEPC] <= 0;
    else if (wen && waddr == `MEPC) 
      csr[`MEPC] <= wdata;
  end

  always @(posedge clk) begin
    if (rst) 
      csr[`MSTATUS] <= 0;
    else if (wen && waddr == `MSTATUS) 
      csr[`MSTATUS] <= wdata;
  end

  always @(posedge clk) begin
    if (rst) 
      csr[`MCAUSE] <= 0;
    else if (wen && set_cause)
      csr[`MCAUSE] <= 11;
    else if (wen && waddr == `MCAUSE) 
      csr[`MCAUSE] <= wdata;
  end

  always @(posedge clk) begin
    if (rst) 
      csr[`MTVEC] <= 0;
    else if (wen && waddr == `MTVEC) 
      csr[`MTVEC] <= wdata;
  end
endmodule

module RegisterFile (
  input clk,
  input rst,
  input [4:0] Ra,
  input [4:0] Rb,
  input wen,
  input [4:0] waddr,
  input [31:0] wdata,
  output [31:0] busA,
  output [31:0] busB
);
  
  reg [31:0] rf[0:31];
  wire  rfwen[0:31];
  assign busA = rf[Ra];
  assign busB = rf[Rb];
  assign rf[0] = 0;
  genvar i;
  generate                     
    for(i=1; i<16; i=i+1 )begin
      assign rfwen[i] = wen && waddr == i;
      Reg #(
        .WIDTH     (32   ),
        .RESET_VAL (32'b0)
      ) u_reg (
        .clk   (clk   ),
        .rst   (rst   ),
        .wen   (rfwen[i]),
        .din   (wdata ),
        .dout  (rf[i]   )
      );
    end
  endgenerate
endmodule

module ContrGen(
  input rst,
  input [4:0] op_6_2,
  input [2:0] func3,
  input func7_5,
  input inst20,
  input inst21,
  input clk,
  output [2:0] ExtOp,
  output [3:0] ALUctr,
  output ALUAsrc,
  output [1:0] ALUBsrc,
  output Regw,
  output [2:0] branch,
  output MemtoReg,
  output [2:0] MemOp,
  output MemWr
);
reg [22:0] ctr;
// 1:csrALU 1:csrw 1:csrpc 1:csrcause  1:MemWr 1:MemtoReg 3: MemOp 3: branch  1: RegWr 4: ALUctr, 1: ALUAsrc, 2: ALUBsrc[1:0], ExtOp[2:0]
always @(*) begin
      case (op_6_2)
        5'b00000: begin
`ifndef SYNTHESIS
         // lsi_count(pc);
`endif
          case (func3)
            3'b000: ctr = 23'b00000100000010000001000; // lb 
            3'b001: ctr = 23'b00000100100010000001000; // lh
            3'b010: ctr = 23'b00000101000010000001000; // lw
            3'b100: ctr = 23'b00000110000010000001000; // lbu
            3'b101: ctr = 23'b00000110100010000001000; // lhu
            default: begin 
	      ctr = {23{1'b1}};
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
	    end
          endcase
        end
        5'b00100: begin
`ifndef SYNTHESIS
         // ali_count(pc);
`endif
          case (func3)
            3'b000: ctr = 23'b00000011100010000001000; // addi
            3'b001: ctr = 23'b00000011100010001001000; // slli
            3'b010: ctr = 23'b00000011100010010001000; // slti
            3'b011: ctr = 23'b00000011100011010001000; // sltiu
            3'b100: ctr = 23'b00000011100010100001000; // xori
            3'b101: ctr = func7_5 ? 23'b00000011100011101001000 : 23'b00000011100010101001000; // srai
            3'b110: ctr = 23'b00000011100010110001000; // ori
            3'b111: ctr = 23'b00000011100010111001000; // andi
            default: begin 
	      ctr = {23{1'b1}}; 
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
	    end
          endcase
        end
        5'b00101: begin
`ifndef SYNTHESIS
         // ali_count(pc);
`endif
	ctr = 23'b00000011100010000101001; // auipc
	end
        5'b01000: begin
`ifndef SYNTHESIS
          //lsi_count(pc);
`endif
          case (func3)
            3'b000: ctr = 23'b00001000000000000001010; // sb
            3'b001: ctr = 23'b00001000100000000001010; // sh
            3'b010: ctr = 23'b00001001000000000001010; // sw
            default: begin
	      ctr = {23{1'b1}};
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
	    end
          endcase
        end
        5'b01100: begin
`ifndef SYNTHESIS
          //ali_count(pc);
`endif
          case (func3)
            3'b000: ctr = func7_5 ? 23'b00000011100011000000111 : 23'b00000011100010000000111; // add
            3'b001: ctr = 23'b00000011100010001000111; // sll
            3'b010: ctr = 23'b00000011100010010000111; // slt
            3'b011: ctr = 23'b00000011100011010000111; // sltu
            3'b100: ctr = 23'b00000011100010100000111; // xor
            3'b101: ctr = func7_5 ? 23'b00000011100011101000111 : 23'b00000011100010101000111;
            3'b110: ctr = 23'b00000011100010110000111; // or
            3'b111: ctr = 23'b00000011100010111000111; // and
            default: begin
	      ctr = {23{1'b1}};
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
	    end
          endcase
        end
        5'b01101: begin
`ifndef SYNTHESIS
        //ali_count(pc);
`endif
	ctr = 23'b00000011100010011001001; // lui
	end
        5'b11000: begin
`ifndef SYNTHESIS
          //cfi_count(pc);
`endif
          case (func3)
            3'b000: ctr = 23'b00000011110000010000011; // beq
            3'b001: ctr = 23'b00000011110100010000011; // bne
            3'b100: ctr = 23'b00000011111000010000011; // blt
            3'b110: ctr = 23'b00000011111001010000011; // bltu
            3'b101: ctr = 23'b00000011111100010000011; // bge
            3'b111: ctr = 23'b00000011111101010000011; // bgeu
            default: begin 
	      ctr = {23{1'b1}}; 
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
	    end
          endcase
        end
        5'b11001: begin
`ifndef SYNTHESIS
          //cfi_count(pc);
`endif
	ctr = 23'b00000011101010000110000; // jalr
	end
        5'b11011: begin 
`ifndef SYNTHESIS
          //cfi_count(pc);
`endif
	ctr = 23'b00000011100110000110100; // jal 
	end
        5'b11100: begin
`ifndef SYNTHESIS
          //csr_count(pc);
`endif
          case (func3)
            3'b001: ctr = 23'b01000011100010011001000; // csrrw
            3'b010: ctr = 23'b11000011100010011001000; // csrrs
            3'b000: begin
              if (inst20) begin 
	        ctr = {23{1'b1}};
`ifndef SYNTHESIS
	        set_npc_state(2,0); 
`endif
	      end //ebreak
              else if (inst21) begin ctr = 23'b00100011101000000000111; end // mret
              else begin ctr = 23'b01110011101000000101111; end // ecall
            end
            default: begin 
	      ctr = {23{1'b1}}; 
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
	    end
          endcase
        end
        default: begin 
	  ctr = {23{1'b1}};
`ifndef SYNTHESIS
	      set_npc_state(3,0); 
`endif
        end
      endcase
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
endmodule

module ysyx_23060221_Idu(
  input clk,
  input rst,
  input [31:0] inst,
  output [3:0] aluctr,
  output aluasrc,
  output [1:0] alubsrc,
  output [2:0] branch,
  output [4:0] Ra,
  output [4:0] Rb,
  output [4:0] waddr,
  output [2:0] memop,
  output memtoreg,
  output memwr,
  output [31:0] imm,
  output regw,
  output [2:0] extop,
  input stall,
  output IDU_ready,
  output IDU_valid,
  input EXU_ready,
  input IFU_valid
);

  assign Ra = inst[19:15];
  assign Rb = inst[24:20];
  assign waddr = inst[11:7];

  reg IDU_ready_reg, IDU_valid_reg;
  wire syn_IFU_IDU = (IFU_valid & IDU_ready);
  wire syn_IDU_EXU = (IDU_valid & EXU_ready);
  assign IDU_ready = (~IDU_valid | EXU_ready);
  assign IDU_valid = IDU_valid_reg & ~stall;
  always @(posedge clk) begin
    if (rst) IDU_valid_reg <= 0;
    else if (syn_IFU_IDU) IDU_valid_reg <= 1;
    else if (syn_IDU_EXU) IDU_valid_reg <= 0;
  end

  ContrGen cg (
  .rst(rst),
  .op_6_2 (inst[6:2]), 
  .func3 (inst[14:12]),
  .func7_5 (inst[30]),
  .inst20(inst[20]),
  .inst21(inst[21]),
  .ExtOp(extop), 
  .ALUctr(aluctr), 
  .ALUAsrc(aluasrc), 
  .ALUBsrc(alubsrc), 
  .Regw(regw),
  .branch(branch),
  .MemOp(memop),
  .MemtoReg(memtoreg),
  .MemWr(memwr),
  .clk(clk)
  );

  ImmGen ig (inst, extop, imm);

endmodule
