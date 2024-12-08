module regfile(clk, data_in, write, reg_w, reg_a, reg_b, out_a, out_b);
	input clk, write;
	input [2:0] reg_w, reg_a, reg_b;
	input [15:0] data_in;
	output reg [15:0] out_a, out_b;

	wire [7:0] load;
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

	register #(16) U0(data_in, load[0], clk, R0);
	register #(16) U1(data_in, load[1], clk, R1);
	register #(16) U2(data_in, load[2], clk, R2);
	register #(16) U3(data_in, load[3], clk, R3);
	register #(16) U4(data_in, load[4], clk, R4);
	register #(16) U5(data_in, load[5], clk, R5);
	register #(16) U6(data_in, load[6], clk, R6);
	register #(16) U7(data_in, load[7], clk, R7);

	assign load = {8{write}} & (8'b1 << reg_w);

	always_comb begin
		case (reg_a)
		0: out_a = R0;
		1: out_a = R1;
		2: out_a = R2;
		3: out_a = R3;
		4: out_a = R4;
		5: out_a = R5;
		6: out_a = R6;
		7: out_a = R7;
		endcase

		case (reg_b)
		0: out_b = R0;
		1: out_b = R1;
		2: out_b = R2;
		3: out_b = R3;
		4: out_b = R4;
		5: out_b = R5;
		6: out_b = R6;
		7: out_b = R7;
		endcase
	end
endmodule: regfile

module register(in, load, clk, out);
	parameter n = 1;
	input [n-1:0] in;
	input load, clk;
	output reg [n-1:0] out;

	always_ff @(posedge clk)
		if (load) out = in;
endmodule: register
