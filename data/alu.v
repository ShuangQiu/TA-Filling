
module alu ( ain, bin, sel, zout );
  input [1:0] ain;
  input [1:0] bin;
  output [1:0] zout;
  input sel;
  wire   n12, n13, n14, n15, n16, n17, n18;

  AO7 U11 ( .A(sel), .B(n12), .C(n13), .Z(zout[1]) );
  AO3 U12 ( .A(n14), .B(sel), .C(ain[1]), .D(bin[1]), .Z(n13) );
  MUX21L U13 ( .A(n15), .B(n16), .S(bin[1]), .Z(n12) );
  NR2 U14 ( .A(ain[1]), .B(n14), .Z(n16) );
  IV U15 ( .A(n17), .Z(n14) );
  EN U16 ( .A(n17), .B(ain[1]), .Z(n15) );
  MUX21L U17 ( .A(n18), .B(n17), .S(sel), .Z(zout[0]) );
  ND2 U18 ( .A(bin[0]), .B(ain[0]), .Z(n17) );
  EN U19 ( .A(bin[0]), .B(ain[0]), .Z(n18) );
endmodule

