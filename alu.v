// 32-bit ALU

module alu(input [31:0] op1,op2,
           input [3:0] alu_op,
           output reg [31:0] result,         // the result is a reg type because is used in a always block 
           output  zero);                     // zero is high when result = 0

parameter [3:0] ALUOP_AND = 4'b0000;         // 0000 -> op1 & op2
parameter [3:0] ALUOP_OR = 4'b0001;          // 0001 -> op1 | op2  
parameter [3:0] ALUOP_ADD = 4'b0010;         // 0010 -> op1 + op2
parameter [3:0] ALUOP_SUB = 4'b0110;         // 0110 -> op1 - op2
parameter [3:0] ALUOP_SLT = 4'b0100;         // 0100 ->if(op1 < op2) then result = 00..01 else result = 00..00 
parameter [3:0] ALUOP_SLR = 4'b1000;         // 1000 -> op1 >> op2[4:0] 
parameter [3:0] ALUOP_SLL = 4'b1001;         // 1001 -> op1 << op2[4:0]
parameter [3:0] ALUOP_SAR = 4'b1010;         // 1010 -> op1 >>>  op2[4:0]
parameter [3:0] ALUOP_XOR = 4'b0101;         // 0101 -> op1 ^ op2

                       

always @(*) begin                            // if any input changes begin the following

case(alu_op)

ALUOP_AND : result = op1 & op2;
ALUOP_OR  : result = op1 | op2;
ALUOP_SUB : result = op1 - op2;
ALUOP_XOR : result = op1 ^ op2;
ALUOP_SLT : result = ($signed(op1) < $signed(op2))? 32'b1:32'b0;  
ALUOP_SLR : result = op1 >> op2[4:0];
ALUOP_SLL : result = op1 << op2[4:0];
ALUOP_SAR : result = $unsigned($signed(op1) >>> op2[4:0]);
ALUOP_ADD : result = op1 + op2;

default result = 32'bX;
endcase
end

assign zero = (result == 0)?1:0;

endmodule
