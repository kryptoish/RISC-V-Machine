module cpu(clk, reset, mem_data, mem_cmd, mem_addr, out, N, V, Z);
	input clk, reset;
	input [15:0] mem_data;
	output N, V, Z;
	output [1:0] mem_cmd;
	output [15:0] out;
	output reg [8:0] mem_addr;

	wire pc_reset, pc_load, ir_load, addr_sel, write, loada, loadb, loadc,
		loads, loadm, asel, bsel, csel;
	wire [1:0] pc_sel, op, sh;
	wire [2:0] opcode, cond, Rn, Rd, Rm, reg_w_sel, reg_a_sel, reg_b_sel;
	wire [3:0] vsel;
	wire [8:0] PC, data_address;
	wire [15:0] instruction, sximm5, sximm8;
	reg [2:0] reg_w, reg_a, reg_b;
	reg [8:0] pc_next;

	register #(16) U0(mem_data, ir_load, clk, instruction);
	register #(9) U1(pc_next, pc_load, clk, PC);

	statemachine FSM(clk, reset, opcode, op, pc_reset, pc_load, pc_sel,
		ir_load, addr_sel, mem_cmd, reg_w_sel, reg_a_sel,
		reg_b_sel, write, loada, loadb, loadc, loads, loadm, asel, bsel,
		csel, vsel);

	datapath DP(clk, reg_w, reg_a, reg_b, write, loada, loadb, loadc, loads,
		loadm, op, sh, asel, bsel, csel, vsel, sximm5, sximm8,
		mem_data, PC, N, V, Z, out, data_address);

	assign mem_addr = addr_sel ? PC : data_address;

	/* Instruction decoder. */
	assign {opcode, op, Rn, Rd, sh, Rm} = instruction;
	assign cond = instruction[10:8];
	assign sximm8 = {{8{instruction[7]}}, instruction[7:0]};
	assign sximm5 = {{11{instruction[4]}}, instruction[4:0]};

	always_comb begin
		/* Selector for REGFILE read/write registers. */
		case (reg_w_sel)
		3'b100: reg_w = Rn;
		3'b010: reg_w = Rd;
		3'b001: reg_w = Rm;
		default: reg_w = 3'bzzz;
		endcase
		case (reg_a_sel)
		3'b100: reg_a = Rn;
		3'b010: reg_a = Rd;
		3'b001: reg_a = Rm;
		default: reg_a = 3'bzzz;
		endcase
		case (reg_b_sel)
		3'b100: reg_b = Rn;
		3'b010: reg_b = Rd;
		3'b001: reg_b = Rm;
		default: reg_b = 3'bzzz;
		endcase

		/* Branching logic. */
		casex ({pc_reset, pc_sel})
		3'b1_xx:
			pc_next = 9'b0;
		3'b0_01: begin
			pc_next = PC + 1;
			case ({opcode, cond})
			/* B. */
			6'b001_000:
				pc_next = PC + 1 + sximm8[8:0];
			/* BEQ. */
			6'b001_001: if (Z)
				pc_next = PC + 1 + sximm8[8:0];
			/* BNE. */
			6'b001_010: if (~Z)
				pc_next = PC + 1 + sximm8[8:0];
			/* BLT. */
			6'b001_011: if (N !== V)
				pc_next = PC + 1 + sximm8[8:0];
			/* BLE. */
			6'b001_100: if (N !== V | Z)
				pc_next = PC + 1 + sximm8[8:0];
			endcase
		end
		/* BX, BLX. */
		3'b0_10:
			pc_next = out;
		/* BL. */
		3'b0_11:
			pc_next = PC + 1 + sximm8[8:0];
		/* Next address in memory. */
		default: pc_next = PC + 1;
		endcase
	end
endmodule: cpu
