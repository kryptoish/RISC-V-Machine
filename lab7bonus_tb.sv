`define STATE_RESET	3'b000
`define STATE_HALT	3'b001
`define STATE_IF	3'b010
`define STATE_DECODE	3'b011
`define STATE_EXEC	3'b100
`define STATE_MEM	3'b101
`define STATE_WRITEBACK	3'b110

module lab7bonus_tb;
	reg err;
	reg [3:0] KEY;
	reg [9:0] SW;
	wire [9:0] LEDR;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	reg CLOCK_50;

	lab7bonus_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

	initial forever begin
		CLOCK_50 = 0; #5;
		CLOCK_50 = 1; #5;
	end

	initial begin
		KEY[1] = 0;
		#10;
		KEY[1] = 1;
		#2000;
		$stop;
	end
endmodule
