
module b01 ( line1, line2, reset, outp, overflw, clock );
  input line1, line2, reset, clock;
  output outp, overflw;
  wire   N58, N59, N60, N61, N62, n5, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47;
  wire   [2:0] stato;

  FD2 \stato_reg[0]  ( .D(N58), .CP(clock), .CD(n5), .Q(stato[0]) );
  FD2 \stato_reg[1]  ( .D(N59), .CP(clock), .CD(n5), .Q(stato[1]), .QN(n30) );
  FD2 \stato_reg[2]  ( .D(N60), .CP(clock), .CD(n5), .Q(stato[2]), .QN(n29) );
  FD2 overflw_reg ( .D(N62), .CP(clock), .CD(n5), .Q(overflw) );
  FD2 outp_reg ( .D(N61), .CP(clock), .CD(n5), .Q(outp) );
  IV U30 ( .A(reset), .Z(n5) );
  EN U31 ( .A(n31), .B(n32), .Z(N61) );
  NR2 U32 ( .A(n29), .B(n33), .Z(n32) );
  EN U33 ( .A(line2), .B(line1), .Z(n31) );
  MUX21L U34 ( .A(n34), .B(n35), .S(n29), .Z(N60) );
  NR2 U35 ( .A(n33), .B(n36), .Z(n35) );
  AO7 U36 ( .A(stato[0]), .B(n37), .C(n30), .Z(n34) );
  AO3 U37 ( .A(n29), .B(n38), .C(n39), .D(n40), .Z(N59) );
  ND3 U38 ( .A(n41), .B(n30), .C(stato[0]), .Z(n40) );
  AO7 U39 ( .A(n36), .B(n29), .C(n33), .Z(n39) );
  MUX21L U40 ( .A(n30), .B(stato[0]), .S(n37), .Z(n38) );
  IV U41 ( .A(n42), .Z(n37) );
  AO3 U42 ( .A(stato[1]), .B(n43), .C(n44), .D(n45), .Z(N58) );
  MUX21L U43 ( .A(n46), .B(n36), .S(n33), .Z(n45) );
  NR2 U44 ( .A(n30), .B(stato[0]), .Z(n33) );
  IV U45 ( .A(n41), .Z(n36) );
  NR2 U46 ( .A(n42), .B(n29), .Z(n46) );
  NR2 U47 ( .A(line1), .B(line2), .Z(n42) );
  ND2 U48 ( .A(N62), .B(n41), .Z(n44) );
  AN3 U49 ( .A(stato[0]), .B(n29), .C(stato[1]), .Z(N62) );
  MUX21L U50 ( .A(stato[0]), .B(n47), .S(n41), .Z(n43) );
  ND2 U51 ( .A(line1), .B(line2), .Z(n41) );
  NR2 U52 ( .A(stato[2]), .B(stato[0]), .Z(n47) );
endmodule

