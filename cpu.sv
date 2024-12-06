// NEED TO CHANGE TO
//	cpu CPU(clk, reset, inst, data, mem_cmd, mem_addr, cpu_out, N, V, Z, halt);

module cpu(clk, reset, mem_data, mem_cmd, mem_addr, out, N, V, Z, halt);
	input clk, reset;
	input [15:0] mem_data;
	output N, V, Z, halt;
	output [1:0] mem_cmd;
	output [15:0] out;
	output reg [8:0] mem_addr;

	wire pc_reset, pc_load, /*ir_load, addr_sel,*/ write, loada, loadb, loadc,
		loads, loadm, asel, bsel, csel;
	wire [1:0] pc_sel, op, sh, vsel;
	wire [2:0] opcode, cond, Rn, Rd, Rm, reg_w_sel, reg_a_sel, reg_b_sel;
	wire [8:0] PC, data_address;
	wire [15:0] instruction, sximm5, sximm8;
	reg [2:0] reg_w, reg_a, reg_b;
	reg [8:0] pc_next;

	register #(16) U0(clk, ir_load, mem_data, instruction);
	register #(9) U1(clk, pc_load, pc_next, PC);
	register #(3) U2(clk, loads, status, {N, V, Z});

	regfile REGFILE(clk, data_in, write, reg_w, reg_a, reg_b, out_a, out_b);

	// statemachine FSM(clk, reset, opcode, op, pc_reset, pc_load, pc_sel,
	// 	ir_load, addr_sel, mem_cmd, reg_w_sel, reg_a_sel,
	// 	reg_b_sel, write, loada, loadb, loadc, loads, loadm, asel, bsel,
	// 	csel, vsel, halt);

	datapath DP(clk, reg_w, reg_a, reg_b, write, loada, loadb, loadc, loads,
		loadm, op, sh, asel, bsel, csel, vsel, sximm5, sximm8,
		mem_data, PC, N, V, Z, out, data_address);

	/* PIPELINE REGISTERS. */

	PR_IF_ID PR0(clk, IF_ID_stall, mem_inst, inst);

	PR_ID_EX PR1(clk, ID_EX_stall, ID_EX_in, IDEX_out);

	PR_EX_MEM PR2(clk, EX_MEM_stall, EX_MEM_in, EXMEM_out);

	PR_MEM_WB PR3(clk, MEM_WB_stall, MEM_WB_in, MEMWB_out);

	// assign mem_addr = addr_sel ? PC : data_address;

	/* Instruction decoder. */
	assign {opcode, op, Rn, Rd, sh, Rm} = inst;
	assign cond = inst[10:8];
	assign sximm8 = {{8{inst[7]}}, inst[7:0]};
	assign sximm5 = {{11{inst[4]}}, inst[4:0]};

	/* Multiplexer for REGFILE input. */
	always_comb case (vsel)
		2'b00: data_in = datapath_out;
		2'b01: data_in = mdata;
		2'b10: data_in = sximm8;
		2'b11: data_in = {7'b0, PC};
	endcase

	/* Selector for REGFILE read/write registers. */
	always_comb begin
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
	end

	/* Branching logic. */
	always_comb casex ({pc_reset, pc_sel})
		3'b1_xx:
			pc_next = 9'b0;
		3'b0_01: begin
			pc_next = PC;
			case ({opcode, cond})
				/* B. */
				6'b001_000:
					pc_next = PC + sximm8[8:0];
				/* BEQ. */
				6'b001_001: if (Z)
					pc_next = PC + sximm8[8:0];
				/* BNE. */
				6'b001_010: if (~Z)
					pc_next = PC + sximm8[8:0];
				/* BLT. */
				6'b001_011: if (N !== V)
					pc_next = PC + sximm8[8:0];
				/* BLE. */
				6'b001_100: if (N !== V | Z)
					pc_next = PC + sximm8[8:0];
			endcase
		end
		/* BX, BLX. */
		3'b0_10:
			pc_next = out;
		/* BL. */
		3'b0_11:
			pc_next = PC + sximm8[8:0];
		/* Next address in memory. */
		default: pc_next = PC + 1;
	endcase
endmodule: cpu

/* General n-bit storage registers. */

module register(clk, load, in, out);
	parameter n = 1;
	input clk, load;
	input [n-1:0] in;
	output reg [n-1:0] out;

	always_ff @(posedge clk)
		if (load) out = in;
endmodule: register

////////////////////

/* EX. */

module EXEC(asel, bsel, sximm5, ain, bin, fwd_mem_ex, fwd_wb_ex, status, out, c);
	input [1:0] asel, bsel;
	input [15:0] sximm5, ain, bin, fwd_mem_ex, fwd_wb_ex;
	output [2:0] status;
	output [15:0] out, c;

	wire [2:0] status;
	wire [15:0] aout, bout, sout;

	shifter U0(bout, shift, sout);
	ALU U1(aout, bout, op, out, status);

	/* ALU bypass. */
	assign c = bin;

	always_comb begin
		case (asel)
			2'b00: aout = ain;
			2'b01: aout = fwd_mem_ex;
			2'b10: aout = fwd_wb_ex;
			2'b11: aout = 16'b0;
		endcase

		case (bsel)
			2'b00: bout = bin;
			2'b01: bout = fwd_mem_ex;
			2'b10: bout = fwd_wb_ex;
			2'b11: bout = sximm5;
		endcase
	end
endmodule


/////////////////// PIPELINE REGISTERS.

/* IF. */

module PR_IF_ID(clk, load, in, out);
	parameter data_width = 16;

	input clk, load;
	input [data_width-1:0] in;
	output reg [data_width-1:0] out;

	always @(posedge clk) begin
		if (load) begin
			out <= in;

		end
	end
endmodule: PR_IF_ID

/* ID. */

module PR_ID_EX(clk, load, in, out);
	parameter data_width = 16;

	input clk, load;
	input [data_width-1:0] in;
	output reg [data_width-1:0] out;

	always @(posedge clk) begin
		if (load) begin
			out <= in;
		end
	end
endmodule: PR_ID_EX

/* EX. */

module PR_EX_MEM(clk, load, in, out);
	parameter data_width = 16;

	input clk, load;
	input [data_width-1:0] in;
	output reg [data_width-1:0] out;

	always @(posedge clk) begin
		if (load) begin
			out <= in;
		end
	end
endmodule: PR_EX_MEM

/* MEM. */

module PR_MEM_WB(clk, load, in, out);
	parameter data_width = 16;

	input clk, load;
	input [data_width-1:0] in;
	output reg [data_width-1:0] out;

	always @(posedge clk) begin
		if (load) begin
			out <= in;
		end
	end
endmodule
