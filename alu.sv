module ALU(Ain, Bin, op, out, status);
	input [1:0] op;
	input [15:0] Ain, Bin;
	output [2:0] status;
	output reg [15:0] out;

	assign status[2] = out[15];
	assign status[1] = (out[15] ^ Ain[15]) & ~(out[15] ^ Bin[15]);
	assign status[0] = (out == 0);

	always_comb case (op)
		2'b00: out = Ain + Bin;
		2'b01: out = Ain - Bin;
		2'b10: out = Ain & Bin;
		2'b11: out = ~Bin;
	endcase
endmodule: ALU

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
