module bypass(
  input [4:0] idexRs1,
  input [4:0] idexRs2,
  input [4:0] exlsRd,
  input [4:0] idexRd,
  input exlswreg,
  input lswbwreg,
  input [4:0] lswbRd,
  input [4:0] ifidRs1,
  input [4:0] ifidRs2,
  input ifidRs1able,
  input ifidRs2able,
  output ca1,
  output ca2,
  output cb1,
  output cb2,
  output ca3,
  output cb3,
  input idexRs1able,
  input idexRs2able,
  input loadused
);
  assign ca1 = exlswreg & (exlsRd != 0) & ((exlsRd == idexRs1) & idexRs1able) & ~loadused;
  assign cb1 = exlswreg & (exlsRd != 0) & ((exlsRd == idexRs2) & idexRs2able) & ~loadused;
  assign ca2 = lswbwreg & (lswbRd != 0) & (((lswbRd == idexRs1) & (exlsRd != idexRs1)) & idexRs1able) & ~loadused;
  assign cb2 = lswbwreg & (lswbRd != 0) & (((lswbRd == idexRs2) & (exlsRd != idexRs2)) & idexRs2able) & ~loadused;
  assign ca3 = lswbwreg & (lswbRd != 0) & (((lswbRd == ifidRs1) & (idexRd != ifidRs1) & (exlsRd != ifidRs1)) & ifidRs1able) & ~loadused;
  assign cb3 = lswbwreg & (lswbRd != 0) & (((lswbRd == ifidRs2) & (idexRd != ifidRs2) & (exlsRd != ifidRs2)) & ifidRs2able) & ~loadused;
endmodule
