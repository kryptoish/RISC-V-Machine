module datapath(clk, reg_w, reg_a, reg_b, write, loada, loadb, loadc, loads,
		loadm, op, shift, asel, bsel, csel, vsel, sximm5, sximm8,
		mdata, PC, N, V, Z, datapath_out, data_address);
	input clk, write, loada, loadb, loadc, loads, loadm, asel, bsel, csel;
	input [1:0] op, shift;
	input [2:0] reg_w, reg_a, reg_b;
	input [3:0] vsel;
	input [8:0] PC;
	input [15:0] sximm8, sximm5, mdata;
	output N, V, Z;
	output [8:0] data_address;
	output reg [15:0] datapath_out;

	wire [2:0] status;
	wire [15:0] out_a, out_b, aout, bout, sout, ain, bin, out;
	reg [15:0] data_in;

	regfile REGFILE(clk, data_in, write, reg_w, reg_a, reg_b, out_a, out_b);
	shifter U0(bout, shift, sout);
	ALU U1(ain, bin, op, out, status);
	register #(16) REG_A(out_a, loada, clk, aout);
	register #(16) REG_B(out_b, loadb, clk, bout);
	register #(16) REG_C((csel ? out_b : out), loadc, clk, datapath_out);
	register #(9) REG_M(out[8:0], loadm, clk, data_address);
	register #(3) REG_S(status, loads, clk, {N, V, Z});

	assign ain = asel ? 16'b0 : aout;
	assign bin = bsel ? sximm5 : sout;

	/* One-hot signal: vsel. */
	always_comb begin
		data_in = {16{1'bz}};
		if (vsel[0]) data_in = datapath_out;
		if (vsel[1]) data_in = mdata;
		if (vsel[2]) data_in = sximm8;
		if (vsel[3]) data_in = {7'b0, PC + 1};
	end
endmodule: datapath
