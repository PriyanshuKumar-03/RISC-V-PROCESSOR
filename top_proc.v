// 5-cycle Control Unit

module top_proc
             #(parameter INITIAL_PC = 32'h00400000)
              (input clk,rst,
               input [31:0] instr,
               input [31:0] dReadData,
               output [31:0] PC,
               output [31:0] dAddress,
               output [31:0] dWriteData,
               output reg MemWrite,MemRead,
               output [31:0] WriteBackData);

parameter [2:0] IF = 3'b000;      // State 0
parameter [2:0] ID = 3'b001;      // State 1
parameter [2:0] EX = 3'b010;      // State 2
parameter [2:0] MEM = 3'b011;     // State 3 
parameter [2:0] WB = 3'b100;      // State 4

parameter [2:0] R_type = 0;     // AND OR XOR SUB SLT SLA 
parameter [2:0] I_type = 1;     // ADI ORI XORI SUNI SLTI SLAI
parameter [2:0] S_type = 2;     // SW
parameter [2:0] L_type = 3;     // LW
parameter [2:0] B_type = 4;     // BEQ

parameter [3:0] ALUOP_AND = 4'b0000;         // 0000 -> op1 & op2
parameter [3:0] ALUOP_OR = 4'b0001;          // 0001 -> op1 | op2  
parameter [3:0] ALUOP_ADD = 4'b0010;         // 0010 -> op1 + op2
parameter [3:0] ALUOP_SUB = 4'b0110;         // 0110 -> op1 - op2
parameter [3:0] ALUOP_SLT = 4'b0100;         // 0100 ->if(op1 < op2) then result = 11..11 else result = 00..00 
parameter [3:0] ALUOP_SLR = 4'b1000;         // 1000 -> op1 >> op2[4:0] 
parameter [3:0] ALUOP_SLL = 4'b1001;         // 1001 -> op1 << op2[4:0]
parameter [3:0] ALUOP_SAR = 4'b1010;         // 1010 -> op1 >>>  op2[4:0]
parameter [3:0] ALUOP_XOR = 4'b0101;         // 0101 -> op1 ^ op2

wire zero;
reg [2:0] current_state,next_state,type;    
reg loadPC,PCSrc,MemToReg,RegWrite,ALUSrc;  
reg [3:0] ALUCtrl;

always @(posedge clk)                             // current state assignement
//always @(posedge clk or posedge rst) 
begin
       if(rst)
          current_state <= IF;
       else
          current_state <= next_state;
end


always @(current_state or type)                           // next state assignement
begin
   case(current_state)
       IF :  next_state <= ID;
       ID :  next_state <= EX;
       EX : if(type == L_type || type == S_type)
             next_state <= MEM;
            else 
             next_state <= WB;    
       MEM : next_state <= WB;
       WB : next_state <= IF;
       default : next_state <= IF;
    endcase
end


//Each state output assignmemt
always @(current_state )//Moore FSM 
 begin
     case(current_state)
        MEM : begin
                  if(type == L_type) begin         // MemRead and MemWrite signals
                             MemRead = 1'b1;
                             MemWrite = 1'b0;
                   end
                   else if(type == S_type) begin
                              MemRead = 1'b0;
                              MemWrite = 1'b1;
                   end
                   else  begin
                              MemRead = 1'b0;
                              MemWrite = 1'b0;
                   end
               end
        WB : begin
                     loadPC = 1;
                     PCSrc = (type == B_type && zero == 1)?1:0;
                     if(type == L_type) begin
                           RegWrite = 1'b1;
                           MemToReg = 1'b1;
                     end             
                     else if(type == R_type || type == I_type) begin
                           RegWrite = 1'b1;
                           MemToReg = 1'b0;
                     end
                     else begin
                     RegWrite = 1'b0;
                     MemToReg = 1'b0;
                     end
              end  
        default : begin
                       MemRead = 1'b0;
                       MemWrite = 1'b0;
                       RegWrite = 1'b0;
                       MemToReg = 1'bx;
                       loadPC = 1'b0;
                       PCSrc = 1'bx;
                  end          
    endcase
end


//Decoder
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


//datapath 
datapath D_P(clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC,ALUCtrl,instr,
                          dReadData,zero,PC,dAddress,dWriteData,WriteBackData);

//ALUCtrl
always @(instr,type)
begin
      if(type == L_type || type == S_type)
              ALUCtrl = ALUOP_ADD;
      else if(type == B_type)
              ALUCtrl = ALUOP_SUB;
      else begin
            if(instr[14:12] == 3'b010)
              ALUCtrl = ALUOP_SLT;
             else if(instr[14:12] == 3'b100)
              ALUCtrl = ALUOP_XOR;
             else if(instr[14:12] == 3'b110)
              ALUCtrl = ALUOP_OR;
             else if(instr[14:12] == 3'b111)
              ALUCtrl = ALUOP_AND;
             else if(instr[14:12] == 3'b001)
              ALUCtrl = ALUOP_SLL;
             else if(instr[14:12] == 3'b101 && instr[31:25] == 7'b0)
              ALUCtrl = ALUOP_SLR;
             else if(instr[14:12] == 3'b101 && instr[31:25] == 7'b0100000)
              ALUCtrl = ALUOP_SAR;
             else if(instr[14:12] == 3'b000 && instr[31:25] == 7'b0100000)
              ALUCtrl = ALUOP_SUB;
             else 
              ALUCtrl = ALUOP_ADD;
      end
end



//ALUSrc
always @(type)
begin
        if(type == R_type || type == B_type)
            ALUSrc = 1'b0;
        else
            ALUSrc = 1'b1;
end

endmodule

