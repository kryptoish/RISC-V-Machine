/* Control signals. */
module control(opcode, op, reg_w_sel, reg_a_sel, reg_b_sel, asel, bsel, loads,
		mem_write, vsel, rf_write);
	input [1:0] op;
	input [2:0] opcode;
	output reg asel, bsel, loads, mem_write, rf_write;
	output reg [1:0] vsel;
	output reg [2:0] reg_w_sel, reg_a_sel, reg_b_sel;

	always_comb begin
		{reg_w_sel, reg_a_sel, reg_b_sel, asel, bsel, loads, mem_write,
			vsel, rf_write} = 16'b0;

		casex ({opcode, op})
			/* MOV immediate to register. */
			5'b110_10: begin
				/* Writeback. */
				{reg_w_sel, rf_write, vsel} = 6'b100_1_10;
			end

			/* MOV register to register. */
			5'b110_00: begin
				/* Decode. */
				reg_b_sel = 3'b001;
				/* Execute. */
				asel = 1'b1;
				/* Writeback. */
				{reg_w_sel, rf_write} = 4'b010_1;
			end

			/* ADD. */
			5'b101_00: begin
				/* Decode. */
				{reg_a_sel, reg_b_sel} = 6'b100_001;
				/* Execute. */
				{reg_w_sel, rf_write} = 4'b010_1;
			end

			/* CMP. */
			5'b101_01: begin
				/* Decode. */
				{reg_a_sel, reg_b_sel} = 6'b100_001;
				/* Execute. */
				loads = 1'b1;
			end

			/* AND. */
			5'b101_10: begin
				/* Decode. */
				{reg_a_sel, reg_b_sel} = 6'b100_001;
				/* Writeback. */
				{reg_w_sel, rf_write} = 4'b010_1;
			end

			/* MVN. */
			5'b101_11: begin
				/* Decode. */
				reg_b_sel = 3'b001;
				/* Writeback. */
				{reg_w_sel, rf_write} = 4'b010_1;
			end

			/* LDR. */
			5'b011_xx: begin
				/* Decode. */
				reg_a_sel = 3'b100; //make bypass for a
				/* Writeback. */
				{reg_w_sel, rf_write, vsel} = 6'b010_1_01;
			end

			/* STR. */
			5'b100_xx: begin
				/* Decode. */
				{reg_a_sel, reg_b_sel} = 3'b100_; //idk wot //reg_b gets bypassed
				/* Execute. */
				{asel, bsel} = 1'b1; //change bsel to 2 bits for sximm5
				/* Memory. */
				mem_write = 1'b1;
			end

			/* B, BEQ, BNE, BLT, BLE.*/
			5'b001_xx: begin
				/* Decode. */
				{pc_load, pc_sel} = 3'b1_01;
			end

			/* BL. */
			5'b010_11: begin
				/* Decode. */
				{pc_load, pc_sel, reg_w_sel, rf_write, vsel} //change write and vsel
				= 11'b1_11_100_1_1000;
			end

			/* BX. */
			5'b010_00: begin
				/* Decode. */
				{reg_b_sel} = 3'b010;
				/* Execute. */
				{pc_load, pc_sel} = 3'b1_10;
			end

			/* BLX. */
			5'b010_10: begin
				/* Decode. */
				{reg_b_sel} = 3'b010;
				/* Execute. */
				{pc_load, pc_sel, reg_w_sel, rf_write, vsel}
				= 11'b1_10_100_1_1000;
			end

			/* HALT. */
			5'b111_xx: begin
				{IF_ID_stall, pc_reset} = 2'b11;
			end

		endcase
	end
endmodule: control

/* Hazard control unit. */ //wiring needs to go down
module HDU(ID_EX_rd, EX_MEM_rd, MEM_WB_rd, IF_ID_rs, IF_ID_rt, opcode, 
	write, mem_write, reset, pc_load, stall, forward_a, forward_b);

	input [2:0] ID_EX_rd, EX_MEM_rd, MEM_WB_rd;
    	input [2:0] IF_ID_rs, IF_ID_rt;
	input [2:0] opcode;
	input write, mem_write;
	output reg reset, pc_load, stall;
	output reg [1:0] forward_a, forward_b;

	always_comb begin
		forward_a = 2'b00;
		forward_b = 2'b00;
		stall = 1'b0;
		load_pc = 1'b1; //might need to change
		reset = 1'b0;

		if (opcode == 3'b111) begin
			stall = 1'b1;
			load_pc = 1'b0;
			reset = 1'b1;
		end

		// Memory write forwarding
		if (mem_write && (EX_MEM_rd != 3'b000)) begin
			if (EX_MEM_rd == IF_ID_rs)
				forward_a = 2'b10;
			if (EX_MEM_rd == IF_ID_rt)
				forward_b = 2'b10;
		end

		// Writeback forwarding
		if (write && (MEM_WB_rd != 3'b000)) begin
			// Ensure no EX forwarding occurred
			if ((EX_MEM_rd != IF_ID_rs) && (MEM_WB_rd == IF_ID_rs))
				forward_a = 2'b01;
			if ((EX_MEM_rd != IF_ID_rt) && (MEM_WB_rd == IF_ID_rt))
				forward_b = 2'b01;
		end

		// Load-use hazard detection
		if (ID_EX_mem_read && 
		((ID_EX_rd == IF_ID_rs) || (ID_EX_rd == IF_ID_rt))) begin
			stall = 1'b1;
			pc_load = 1'b0;
		end
	end	
	
endmodule: HDU