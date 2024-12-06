// NEED TO CHANGE TO
//	cpu CPU(clk, reset, inst, data, mem_cmd, mem_addr, cpu_out, N, V, Z, halt);

module cpu(clk, reset, mem_data, mem_cmd, mem_addr, out, N, V, Z, halt);
	input clk, reset;
	input [15:0] mem_data;
	output N, V, Z, halt;
	output [1:0] mem_cmd;
	output [15:0] out;
	output reg [8:0] mem_addr;

	wire stall;

	/*
	 * Pipeline signals.
	 *
	 * Naming convention:
	 *	<stage>_<signalname>
	 *		Wire that connects the two pipeline registers on
	 *		either side of <stage>.
	 *	<signalname>
	 *		Wire that is connected to the combinational logic
	 *		at the stage it is used; e.g., ``op'' at the
	 *		execute stage.
	 *	<stage>_{alu, mem}_out
	 *		Output of {ALU, memory} at <stage>.
	 *
	 * Organisation:
	 *	By whichever stages the wires are connected at.
	 *
	 * Footnote:
	 *	MEM --- prefix for memory stage.
	 *	mem --- CPU input/output signals for RAM module communication.
	 */

	/* Instruction fetch. */
	// PC, etc...

	/* Instruction decode. */
	wire ID_write, ID_asel, ID_bsel, ID_loads, ID_mem_write;
	wire [1:0] op, ID_sh, ID_vsel;
	wire [2:0] opcode, cond, Rn, Rd, Rm, reg_a, reg_b, reg_w_sel, reg_a_sel, reg_b_sel, ID_reg_w;
	wire [4:0] ID_imm5;
	wire [7:0] ID_imm8;
	wire [15:0] inst, ID_a, ID_b;

	/* Execute. */
	wire asel, bsel, loads, EX_mem_write, EX_write;
	wire [1:0] alu_op, sh, EX_vsel;
	wire [2:0] status, EX_reg_w;
	wire [4:0] imm5;
	wire [7:0] EX_imm8;
	wire [15:0] ain, bin, cin, alu_out, c;

	// /* Memory. */
	// wire mem_write;
	// wire [15:0] mem_data_in, mem_data_out;

	// /* Writeback. */
	// wire write;
	// wire [1:0] vsel;
	// wire [15:0] out, mdata;

	register #(9) U0(clk, pc_load, pc_next, PC);

	/* Instruction fetch. */

	assign inst_addr = PC;

	PR_IF_ID PR0(clk, stall, inst_next, inst);

	/* Instruction decode. */

	/* Decoder. */
	assign {opcode, op, Rn, Rd, ID_sh, Rm} = inst;
	assign cond = inst[10:8];
	assign ID_imm5 = inst[4:0];
	assign ID_imm8 = inst[7:0];

	/* Selector for REGFILE read/write registers. */
	always_comb begin
		case (reg_w_sel)
			3'b100: ID_reg_w = Rn;
			3'b010: ID_reg_w = Rd;
			3'b001: ID_reg_w = Rm;
			default: ID_reg_w = 3'bzzz;
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

	regfile REGFILE(clk, rf_in, write, reg_w, reg_a, reg_b, ID_a, ID_b);

	control CTL(opcode, op, ID_write, reg_w_sel, reg_a_sel, reg_b_sel, ID_asel, ID_bsel, ID_vsel, ID_loads);

	PR_ID_EX PR1(clk, {op, ID_sh, ID_imm5, ID_asel, ID_bsel, ID_loads}, {ID_mem_write},
		{ID_imm8, ID_write, ID_reg_w, ID_vsel}, ID_a, ID_b, {alu_op, sh, imm5, asel, bsel, loads},
		{EX_mem_write}, {EX_imm8, EX_write, EX_reg_w, EX_vsel}, ain, bin);

	/* Combinational logic for execute stage. */
	EXEC EX(alu_op, asel, bsel, imm5, ain, bin, fwd_mem_ex, fwd_wb_ex,
		status, alu_out, c);

	/* Status register. */
	register #(3) SR(clk, loads, status, {N, V, Z});

	PR_EX_MEM PR2(clk, {EX_mem_write}, {EX_write, EX_reg_w, EX_vsel},
		alu_out, c, {mem_write}, {MEM_write, MEM_reg_w, MEM_vsel},
		MEM_alu_out, MEM_c);

	assign data_addr = MEM_alu_out;
	assign mem_data_in = MEM_c;

	PR_MEM_WB PR3(clk, {MEM_write, MEM_reg_w, MEM_vsel}, MEM_alu_out,
		mem_data_out, {write, reg_w, vsel}, output, mdata);

	/* Multiplexer for REGFILE input. */
	always_comb case (vsel)
		2'b00: rf_in = output;
		2'b01: rf_in = mdata;
		2'b10: rf_in = sximm8;
		2'b11: rf_in = {7'b0, PC};
	endcase

	// datapath DP(clk, reg_w, reg_a, reg_b, write, loada, loadb, loadc, loads,
	// 	loadm, op, sh, asel, bsel, csel, vsel, sximm5, sximm8,
	// 	mem_data, PC, N, V, Z, out, data_address);

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
		if (load) out <= in;
endmodule: register

/* EX. */

module EXEC(op, asel, bsel, imm5, ain, bin, fwd_mem_ex, fwd_wb_ex, status, out, c);
	input [1:0] op, asel, bsel;
	input [4:0] imm5;
	input [15:0] ain, bin, fwd_mem_ex, fwd_wb_ex;
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
			2'b11: bout = {{11{imm5[4]}}, imm5};
		endcase
	end
endmodule

/*
 * Pipeline registers.
 *
 * Naming conventions:
 *	ctl_<stage>_in, ctl_<stage>_out
 *		Control signals for <stage>.
 *	a_in, b_in, a_out, b_out
 *		Pipeline registers for data.
 *	c_in, c_out
 *		ALU bypass (for STR operations).
 *	alu_in, alu_out
 *		ALU result of operation.
 *	mem_data_in, mem_data_out
 *		Data from memory.
 *
 * Control signals/inputs for each stage:
 *	Decode
 *	- reg_a
 *	- reg_b
 *	- csel
 *	Execute
 *	- op
 *	- asel
 *	- bsel
 *	- imm5
 *	Memory
 *	- mem_write
 *	Writeback
 *	- write
 *	- reg_w
 */

module PR_IF_ID(clk, stall, in, out);
	input clk, stall;
	input [15:0] in;
	output reg [15:0] out;

	always @(posedge clk)
		if (~stall)
			out <= in;
endmodule: PR_IF_ID

module PR_ID_EX(clk, ctl_ex_in, ctl_mem_in, ctl_wb_in, a_in, b_in,
		ctl_ex_out, ctl_mem_out, ctl_wb_out, a_out, b_out);
	input clk, ctl_mem_in;
	input [3:0] ctl_wb_in;
	input [9:0] ctl_ex_in;
	input [15:0] a_in, b_in;
	output reg ctl_mem_out;
	output reg [3:0] ctl_wb_out;
	output reg [9:0] ctl_ex_out;
	output reg [15:0] a_out, b_out;

	always @(posedge clk) begin
		ctl_ex_out <= ctl_ex_in;
		ctl_mem_out <= ctl_mem_in;
		ctl_wb_out <= ctl_wb_in;
		a_out <= a_in;
		b_out <= b_in;
	end
endmodule: PR_ID_EX

module PR_EX_MEM(clk, ctl_mem_in, ctl_wb_in, alu_in, c_in,
		ctl_mem_out, ctl_wb_out, alu_out, c_out);
	input clk, ctl_mem_in;
	input [3:0] ctl_wb_in;
	input [15:0] alu_in, c_in;
	output reg ctl_mem_out;
	output reg [3:0] ctl_wb_out;
	output reg [15:0] alu_out, c_out;

	always @(posedge clk) begin
		ctl_mem_out <= ctl_mem_in;
		ctl_wb_out <= ctl_wb_in;
		ex_out <= alu_out;
		c_out <= c_in;
	end
endmodule: PR_EX_MEM

module PR_MEM_WB(clk, ctl_wb_in, alu_in, mem_data_in,
		ctl_wb_out, alu_out, mem_data_out);
	input clk;
	input [3:0] ctl_wb_in;
	input [15:0] alu_in, mem_data_in;
	output reg [3:0] ctl_wb_out;
	output reg [15:0] alu_out, mem_data_out;

	always @(posedge clk) begin
		ctl_wb_out <= ctl_wb_in;
		alu_out <= alu_in;
		mem_data_out <= mem_data_in;
	end
endmodule: PR_MEM_WB
