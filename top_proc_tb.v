module top_proc_tb;


reg clk,rst;
wire [31:0] instr,dReadData,dWriteData;
wire [31:0] PC,dAddress,WriteBackData;


top_proc TOP_PROC(clk,rst,instr,dReadData,PC,dAddress,dWriteData,MemWrite,MemRead,WriteBackData);



INSTRUCTION_MEMORY I_M(clk,{PC[8:0]},instr);

DATA_MEMORY D_M(clk,MemWrite,dAddress[8:0],dWriteData,dReadData);

//clock generation
initial begin
  clk = 1;
  forever #10 clk = ~clk;    // Clock period T = 20 ns
end


initial begin

rst = 1;
#10 rst = 0;


end
endmodule