module shifter(in, shift, sout);
	input [1:0] shift;
	input [15:0] in;
	output reg [15:0] sout;

	always_comb case (shift)
		2'b00: sout = in;
		2'b01: sout = {in[14:0], 1'b0};
		2'b10: sout = {1'b0, in[15:1]};
		2'b11: sout = {in[15], in[15:1]};
	endcase
endmodule: shifter
