// datapath

module datapath
             #(parameter [31:0] INITIAL_PC = 32'h00400000)
              (input clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC,
               input [3:0] ALUCtrl,
               input [31:0] instr,
               input [31:0] dReadData,
               output zero,
               output reg [31:0] PC,
               output [31:0] dAddress,             //ALU result
               output [31:0] dWriteData,
               output reg [31:0] WriteBackData);
                               

parameter [2:0] R_type = 0;     // AND OR XOR SUB SLT SLA 
parameter [2:0] I_type = 1;     // ADI ORI XORI SUNI SLTI SLAI
parameter [2:0] S_type = 2;     // SW
parameter [2:0] L_type = 3;     // LW
parameter [2:0] B_type = 4;     // BEQ



wire [31:0] RegRead1,RegRead2,branch_offset,result;        //RegData value to be stored in Register File
reg [2:0] type;
reg [31:0] immediate,op2;

//PC Block
always @(posedge clk)
begin
      if(rst)
        PC <= INITIAL_PC;    // when rst=1 PC=h400000 ,rst is sychronous
      else if(loadPC) begin
              if(PCSrc)
                 PC <= PC + branch_offset;
              else
                 PC <= PC + 4;
         end
end



//Instruction Decode using the opcode
always @(instr[6:0])
begin
 if(instr[6:0] == 7'b0110011)
    type = 0;            // R-Type
 else if(instr[6:0] == 7'b0100011)
    type = 2;            // S-Type
 else if(instr[6:0] == 7'b0000011)
    type = 3;            // L-Type
 else if(instr[6:0] == 7'b0010011)
    type = 1;            // I-Type
 else if(instr[6:0] == 7'b1100011)
    type = 4;            // B-Type
else 
     type = 3'bx;
end


//Register File
regfile  R_F(clk,RegWrite,instr[19:15],instr[24:20],instr[11:7],WriteBackData,RegRead1,RegRead2);


//Immediate Generator
always @(type,instr) begin                            

  if(type == L_type || type == I_type)
                immediate = {{20{instr[31]}},instr[31:20]};
  else if(type == S_type)
                immediate = {{20{instr[31]}},instr[31:25],instr[11:7]};
  else if(type == B_type)
                immediate = {{20{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]};               
end


	
//Branch Target
assign branch_offset = immediate << 1 ;


//MUX to select Alu second's input
always @(immediate,RegRead2,ALUSrc) begin
     case(ALUSrc)
          1'b1 : op2 = immediate;
          1'b0 : op2 = RegRead2;
          default : op2 = 32'bx;
     endcase
end


//ALU
alu  A_L_U(RegRead1,op2,ALUCtrl,result,zero);


//MUX to Write Back
always @(dReadData,result,MemToReg) begin
     case(MemToReg)
          1'b1 : WriteBackData = dReadData;
          1'b0 : WriteBackData = result;
          default : WriteBackData = 32'bx;
     endcase
end

//
assign dAddress = result;

//
assign dWriteData = RegRead2;


endmodule





















