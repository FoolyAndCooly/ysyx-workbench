module bypass(
  input [4:0] idexRs1,
  input [4:0] idexRs2,
  input [4:0] exlsRd,
  input exlswreg,
  input lswbwreg,
  input [4:0] lswbRd,
  output ca1,
  output ca2,
  output cb1,
  output cb2,
  input idexRs1able,
  input idexRs2able,
  input loadused
);
  assign ca1 = exlswreg & (exlsRd != 0) & ((exlsRd == idexRs1) & idexRs1able) & ~loadused;
  assign cb1 = exlswreg & (exlsRd != 0) & ((exlsRd == idexRs2) & idexRs2able) & ~loadused;
  assign ca2 = lswbwreg & (lswbRd != 0) & (((lswbRd == idexRs1) & (exlsRd != idexRs1)) & idexRs1able) & ~loadused;
  assign cb2 = lswbwreg & (lswbRd != 0) & (((lswbRd == idexRs2) & (exlsRd != idexRs2)) & idexRs2able) & ~loadused;
endmodule
