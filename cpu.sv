module cpu(clk, reset, mem_data, mem_cmd, mem_addr, out, N, V, Z);
	input clk, reset;
	input [15:0] mem_data;
	output N, V, Z;
	output [1:0] mem_cmd;
	output [15:0] out;
	output reg [8:0] mem_addr;

	wire pc_reset, pc_load, ir_load, addr_sel, write, loada, loadb, loadc,
		loads, loadm, asel, bsel, csel;
	wire [1:0] op, sh;
	wire [2:0] opcode, Rn, Rd, Rm, reg_w_sel, reg_a_sel, reg_b_sel;
	wire [3:0] vsel;
	wire [8:0] PC, pc_next, data_address;
	wire [15:0] instruction, sximm5, sximm8;
	reg [2:0] reg_w, reg_a, reg_b;

	register #(16) U0(mem_data, ir_load, clk, instruction);
	register #(9) U1(pc_next, pc_load, clk, PC);

	statemachine FSM(clk, reset, opcode, op, pc_reset, pc_load, ir_load,
		addr_sel, mem_cmd, reg_w_sel, reg_a_sel, reg_b_sel, write,
		loada, loadb, loadc, loads, loadm, asel, bsel, csel, vsel);

	datapath DP(clk, reg_w, reg_a, reg_b, write, loada, loadb, loadc, loads,
		loadm, op, sh, asel, bsel, csel, vsel, sximm5, sximm8, mem_data,
		PC, N, V, Z, out, data_address);

	assign pc_next = pc_reset ? 9'b0 : (PC + 1);
	assign mem_addr = addr_sel ? PC : data_address;

	/* Instruction decoder. */
	assign {opcode, op, Rn, Rd, sh, Rm} = instruction;
	assign sximm8 = {{8{instruction[7]}}, instruction[7:0]};
	assign sximm5 = {{11{instruction[4]}}, instruction[4:0]};

	/* Selector for REGFILE read/write registers. */
	always_comb begin
		reg_w = 3'bzzz;
		reg_a = 3'bzzz;
		reg_b = 3'bzzz;
		case (reg_w_sel)
		3'b100: reg_w = Rn;
		3'b010: reg_w = Rd;
		3'b001: reg_w = Rm;
		endcase
		case (reg_a_sel)
		3'b100: reg_a = Rn;
		3'b010: reg_a = Rd;
		3'b001: reg_a = Rm;
		endcase
		case (reg_b_sel)
		3'b100: reg_b = Rn;
		3'b010: reg_b = Rd;
		3'b001: reg_b = Rm;
		endcase
	end
endmodule: cpu
