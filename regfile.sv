module regfile(clk, data_in, write, reg_w, reg_a, reg_b, out_a, out_b);
	input clk, write;
	input [2:0] reg_w, reg_a, reg_b;
	input [15:0] data_in;
	output reg [15:0] out_a, out_b;

	wire [7:0] load;
	reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

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

	always_ff @(negedge clk) begin
		if (load[0]) R0 <= data_in;
		if (load[1]) R1 <= data_in;
		if (load[2]) R2 <= data_in;
		if (load[3]) R3 <= data_in;
		if (load[4]) R4 <= data_in;
		if (load[5]) R5 <= data_in;
		if (load[6]) R6 <= data_in;
		if (load[7]) R7 <= data_in;
	end
endmodule: regfile
