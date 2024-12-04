 module ALU(Ain,Bin,ALUop,out,Z);
   input [15:0] Ain, Bin;
   input [1:0] ALUop;
   output reg [15:0] out;
   output reg [2:0] Z; //Z[0] = zero flag, Z[1] = neg flag, Z[2] = overflow flag

 always_comb begin 
   case(ALUop)
      2'b00 : out = Ain + Bin; //add Ain and Bin
      2'b01 : out = Ain - Bin; //subtract Ain and Bin
      2'b10 : out = Ain & Bin; //AND Ain and Bin
      2'b11 : out = ~Bin; //Negate Bin
   endcase 

   //make it better by putting it into the add and subtraction above
   Z[0] = out[15]; //negative
   Z[1] = (ALUop == 2'b00) ? ((Ain[15] == Bin[15]) && (out[15] != Ain[15])) : 
   (ALUop == 2'b01) ? ((Ain[15] != Bin[15]) && (out[15] != Ain[15])) : 1'b0; //improvements could be made
   Z[2] = out == {16{1'b0}}; //zero
 end 
 endmodule 