module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output reg [15:0] sout;
    
    always_comb begin
        case (shift)
            //no shift
            2'b00: sout = in;
            2'b01: sout = in << 1; //left bit shift
            2'b10: sout = in >> 1; //right bit shift
            2'b11: begin 
                sout = in >> 1;
                sout[15] = sout[14]; //in[15] copied to to MSB after right bit shift
            end
        endcase
    end
endmodule
