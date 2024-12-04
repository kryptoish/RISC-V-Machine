`define STATE_RESET	3'b000
`define STATE_IF	3'b001
`define STATE_DECODE	3'b010
`define STATE_EXEC	3'b011
`define STATE_MEM	3'b100
`define STATE_WRITE	3'b101

module statemachine(clk, reset, opcode, op, pc_reset, pc_load, ir_load,
		addr_sel, mem_cmd, reg_w_sel, reg_a_sel, reg_b_sel, write,
		loada, loadb, loadc, loads, loadm, asel, bsel, csel, vsel);
	input clk, reset;
	input [1:0] op;
	input [2:0] opcode;
	output reg pc_reset, pc_load, ir_load, addr_sel, write, loada, loadb,
		loadc, loads, loadm, asel, bsel, csel;
	output reg [1:0] mem_cmd;
	output reg [2:0] reg_w_sel, reg_a_sel, reg_b_sel;
	output reg [3:0] vsel;

	reg [3:0] state;

	always_comb begin
		{pc_reset, pc_load, ir_load, addr_sel, mem_cmd, reg_w_sel,
			reg_a_sel, reg_b_sel, write, loada, loadb, loadc, loads,
			loadm, asel, bsel, csel, vsel} = 28'b0;

		casex ({state, opcode, op})
		/* Reset state. */
		{`STATE_RESET, 5'bxxx_xx}:
			{pc_reset, pc_load, addr_sel, mem_cmd}
				= 5'b111_10;

		/* Instruction fetch. */
		{`STATE_IF, 5'bxxx_xx}:
			{pc_load, ir_load, addr_sel, mem_cmd} = 5'b111_10;

		/* MOV immediate to register. */
		{`STATE_DECODE, 5'b110_10}:
			{addr_sel, mem_cmd, reg_w_sel, write, vsel}
				= 11'b1_10_100_1_0100;

		/* MOV register to register. */
		{`STATE_DECODE, 5'b110_00}:
			{reg_b_sel, loadb} = 4'b001_1;
		{`STATE_EXEC, 5'b110_00}:
			{loadc, asel} = 2'b11;
		{`STATE_WRITE, 5'b110_00}:
			{addr_sel, mem_cmd, reg_w_sel, write, vsel}
				= 11'b1_10_010_1_0001;

		/* General ALU operations. */
		{`STATE_DECODE, 5'b101_xx}:
			{reg_a_sel, reg_b_sel, loada, loadb} = 8'b100_001_11;

		/* ADD. */
		{`STATE_EXEC, 5'b101_00}:
			loadc = 1'b1;
		{`STATE_WRITE, 5'b101_00}:
			{addr_sel, mem_cmd, reg_w_sel, write, vsel}
				= 11'b1_10_010_1_0001;

		/* CMP. */
		{`STATE_EXEC, 5'b101_01}:
			{addr_sel, mem_cmd, loads} = 4'b1_10_1;

		/* AND. */
		{`STATE_EXEC, 5'b101_10}:
			loadc = 1'b1;
		{`STATE_WRITE, 5'b101_10}:
			{addr_sel, mem_cmd, reg_w_sel, write, vsel}
				= 11'b1_10_010_1_0001;

		/* MVN. */
		{`STATE_EXEC, 5'b101_11}:
			loadc = 1'b1;
		{`STATE_WRITE, 5'b101_11}:
			{addr_sel, mem_cmd, reg_w_sel, write, vsel}
				= 11'b1_10_010_1_0001;

		/* LDR. */
		{`STATE_DECODE, 5'b011_xx}:
			{reg_a_sel, loada} = 4'b100_1;
		{`STATE_EXEC, 5'b011_xx}:
			{loadm, bsel} = 2'b11;
		{`STATE_MEM, 5'b011_xx}:
			mem_cmd = 2'b10;
		{`STATE_WRITE, 5'b011_xx}:
			{addr_sel, mem_cmd, reg_w_sel, write, vsel}
				= 11'b1_10_010_1_0010;

		/* STR. */
		{`STATE_DECODE, 5'b100_xx}:
			{reg_a_sel, reg_b_sel, loada, loadb} = 8'b100_010_11;
		{`STATE_EXEC, 5'b100_xx}:
			{loadc, loadm, bsel, csel} = 4'b1111;
		{`STATE_MEM, 5'b100_xx}:
			mem_cmd = 2'b01;
		{`STATE_WRITE, 5'b100_xx}:
			{addr_sel, mem_cmd} = 3'b1_10;
		default: begin end
		endcase
	end

	always_ff @(posedge clk) casex ({reset, state, opcode, op})
		/* Reset. */
		10'b1_xxxx_xxx_xx:
			state <= `STATE_RESET;
		{1'b0, `STATE_RESET, 5'bxxx_xx}:
			state <= `STATE_IF;

		/* Beginning of instruction cycle. */
		{1'b0, `STATE_IF, 5'bxxx_xx}:
			state <= `STATE_DECODE;

		/* HALT. */
		{1'b0, `STATE_DECODE, 5'b111_xx}:
			state <= `STATE_DECODE;

		/* MOV immediate to register. */
		{1'b0, `STATE_DECODE, 5'b110_10}:
			state <= `STATE_IF;

		/* MOV register to register. */
		{1'b0, `STATE_DECODE, 5'b110_00}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b110_00}:
			state <= `STATE_WRITE;
		{1'b0, `STATE_WRITE, 5'b110_00}:
			state <= `STATE_IF;

		/* ADD. */
		{1'b0, `STATE_DECODE, 5'b101_00}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b101_00}:
			state <= `STATE_WRITE;
		{1'b0, `STATE_WRITE, 5'b101_00}:
			state <= `STATE_IF;

		/* CMP. */
		{1'b0, `STATE_DECODE, 5'b101_01}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b101_01}:
			state <= `STATE_IF;

		/* AND. */
		{1'b0, `STATE_DECODE, 5'b101_10}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b101_10}:
			state <= `STATE_WRITE;
		{1'b0, `STATE_WRITE, 5'b101_10}:
			state <= `STATE_IF;

		/* MVN. */
		{1'b0, `STATE_DECODE, 5'b101_11}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b101_11}:
			state <= `STATE_WRITE;
		{1'b0, `STATE_WRITE, 5'b101_11}:
			state <= `STATE_IF;

		/* LDR. */
		{1'b0, `STATE_DECODE, 5'b011_xx}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b011_xx}:
			state <= `STATE_MEM;
		{1'b0, `STATE_MEM, 5'b011_xx}:
			state <= `STATE_WRITE;
		{1'b0, `STATE_WRITE, 5'b011_xx}:
			state <= `STATE_IF;

		/* STR. */
		{1'b0, `STATE_DECODE, 5'b100_xx}:
			state <= `STATE_EXEC;
		{1'b0, `STATE_EXEC, 5'b100_xx}:
			state <= `STATE_MEM;
		{1'b0, `STATE_MEM, 5'b100_xx}:
			state <= `STATE_WRITE;
		{1'b0, `STATE_WRITE, 5'b100_xx}:
			state <= `STATE_IF;

		/* Should not happen. Otherwise, an error occurred. */
		default:
			state <= `STATE_RESET;
	endcase
endmodule: statemachine
