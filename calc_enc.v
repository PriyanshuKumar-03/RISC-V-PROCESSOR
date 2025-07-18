// alu_op generator 

module calc_enc(input btnl,btnc,btnr,
                output [3:0] alu_op);

wire btnc_bar,A1,A2,btnl_bar,btnr_bar,B1,B2,C1,C2,C3,D2,D3,D4;

// alu_op[0] circuit
not invA1(btnc_bar,btnc);
and andA1(A1,btnc_bar,btnr);
and andA2(A2,btnl,btnr);
or orA1(alu_op[0],A1,A2);

// alu_op[1] circuit
not invB1(btnl_bar,btnl);
and andB1(B1,btnl_bar,btnc);
not invB2(btnr_bar,btnr);
and andB2(B2,btnc,btnr_bar);
or  orB1(alu_op[1],B1,B2);

// alu_op[2] circuit
and andC1(C1,btnr,btnc);
and andC2(C2,btnl,btnc_bar);
and andC3(C3,C2,btnr_bar);
or  orC1(alu_op[2],C1,C3);

// alu_op[3] circuit
and andD1(D2,btnl,btnc);
and andD2(D3,btnr,C2);
and andD3(D4,D2,btnr_bar);
or  orD1(alu_op[3],D3,D4);


endmodule
