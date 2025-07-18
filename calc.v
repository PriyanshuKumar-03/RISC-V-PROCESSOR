// calculator circuit

module calc(input clk,btnc,btnl,btnu,btnr,btnd,
            input [15:0] sw,
            output reg [15:0] led);


wire [31:0] result;
wire [3:0] alu_op;
wire [31:0] op2;
wire [31:0] op1;


calc_enc ALUOP(btnl,btnc,btnr,alu_op);


assign op2 = {{16{sw[15]}},sw[15:0]};


alu ALU(op1,op2,alu_op,result,zero);


//accumulator
always @(posedge clk)
begin
       if(btnu) 
          led <= 16'b0;
       else if(btnd)
          led <= result[15:0];         
end


assign op1 = {{16{led[15]}},led[15:0]};


endmodule



















