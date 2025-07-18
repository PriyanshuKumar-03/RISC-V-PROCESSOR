// register file

module regfile
             #(parameter DATAWIDTH = 32)
              (input clk, write,
               input [4:0] readReg1,
               input [4:0] readReg2,
               input [4:0] writeReg,
               input [DATAWIDTH-1:0] writeData,
               output reg [DATAWIDTH-1:0] readData1,
               output reg [DATAWIDTH-1:0] readData2);


integer i;
reg [DATAWIDTH-1:0] register[DATAWIDTH-1:0]; // creates 32 registers of 32 bits


initial begin                                // initializing all registers with 32'b0
       for(i=0; i<DATAWIDTH; i=i+1) begin
                register[i]=32'b0;
       end
end
 




always @(posedge clk) 
begin 
     if(write) begin
      register[writeReg] = writeData;
     end
      readData1 <= register[readReg1];
      readData2 <= register[readReg2];
end

endmodule