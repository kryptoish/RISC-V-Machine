module control(opcode, op);
	input [1:0] op;
	input [2:0] opcode;

	always_comb begin
		// RESET TO ZERO.

		casex ({opcode, op})
			/* MOV immediate to register. */
			5'b110_10: begin
				/* Decode. */
				{reg_w_sel, write, vsel} = 6'b100_1_10;
			end

			/* MOV register to register. */
			5'b110_00: begin
				/* Decode. */
				reg_b_sel = 3'b001;
				/* Execute. */
				asel = 1'b1;
				/* Writeback. */
				{reg_w_sel, write} = 4'b010_1;
			end

			/* ADD. */
			5'b101_00: begin
				/* Decode. */
				{reg_a_sel, reg_b_sel} = 6'b100_001;
				/* Execute. */
				{reg_w_sel, write} = 4'b010_1;
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
				{reg_w_sel, write} = 4'b010_1;
			end

			/* MVN. */
			5'b101_11: begin
				/* Decode. */
				reg_b_sel = 3'b001;
				/* Writeback. */
				{reg_w_sel, write} = 4'b010_1;
			end

			/* LDR. */
			5'b011_xx: begin
				/* Decode. */
				reg_a_sel = 3'b100;
				/* Execute. */
				// TODO: bypass?
				/* Memory. */
				// TODO: mem_cmd?
				/* Writeback. */
				{reg_w_sel, write, vsel} = 6'b010_1_01;
			end

			/* STR. */
			5'b100_xx: begin
				/* Decode. */
				{reg_a_sel, reg_b_sel} = 6'b100_010;
				/* Execute. */
				bsel = 1'b1;
				/* Memory. */
				// TODO: mem_cmd?
				/* Writeback. */
				// TODO: ????
			end

			5'b001_xx: begin
				/* Decode. */
				{pc_load, pc_sel} = 3'b1_01;
				/*  Execute. */
				{inst_addr} = 3'b1; //make it so we control write instead

			
			end
		endcase
	end
endmodule: control

module forwarding();
	
endmodule: forwarding

module HDU(memread/*change name*/, pc_load, IFID_stall, reset, /*three regs idk*/, );
	
	
endmodule: HDU