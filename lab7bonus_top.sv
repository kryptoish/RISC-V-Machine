`define M_NOP 2'b00
`define M_READ 2'b10
`define M_WRITE 2'b01

module lab7bonus_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;

	wire clk, write, N, V, Z, halt;
	wire [1:0] mem_cmd;
	wire [8:0] write_addr, inst_addr, data_addr;
	wire [15:0] cpu_out, mem_inst, mem_addr, inst, data;

	ram #(16, 8) MEM(clk, write, write_addr, inst_addr, data_addr, cpu_out, mem_inst, mem_data);
	cpu CPU(clk, reset, inst, data, mem_cmd, mem_addr, cpu_out, N, V, Z, halt);

	disp U0(cpu_out[3:0], HEX0);
	disp U1(cpu_out[7:4], HEX1);
	disp U2(cpu_out[11:8], HEX2);
	disp U3(cpu_out[15:12], HEX3);
	disp U4({1'b0, N, V, Z}, HEX4);

	assign clk = CLOCK_50;
	assign reset = ~KEY[1];
	assign LEDR[8] = halt;

endmodule: lab7bonus_top

module ram(clk, write, write_addr, inst_addr, data_addr, in, inst_out, data_out);
	parameter data_width = 32;
	parameter addr_width = 4;
	parameter filename = "data.txt";

	input clk;
	input write;
	input [addr_width-1:0] write_addr, inst_addr, data_addr;
	input [data_width-1:0] in;
	output reg [data_width-1:0] inst_out, data_out;

	reg [data_width-1:0] mem [2**addr_width-1:0];

	initial $readmemb(filename, mem);

	always @(negedge clk) begin
		if (write) mem[write_addr] <= in;
		inst_out <= mem[inst_addr];
		data_out <= mem[data_addr];
	end
endmodule: ram

module disp(in, out);
	input [3:0] in;
	output reg [6:0] out;

	always_comb case (in)
		4'h0: out = 7'b1000000;
		4'h1: out = 7'b1111001;
		4'h2: out = 7'b0100100;
		4'h3: out = 7'b0110000;
		4'h4: out = 7'b0011001;
		4'h5: out = 7'b0010010;
		4'h6: out = 7'b0000010;
		4'h7: out = 7'b1111000;
		4'h8: out = 7'b0000000;
		4'h9: out = 7'b0010000;
		4'ha: out = 7'b0001000;
		4'hb: out = 7'b0000011;
		4'hc: out = 7'b0100111;
		4'hd: out = 7'b0100001;
		4'he: out = 7'b0000110;
		4'hf: out = 7'b0001110;
	endcase
endmodule: disp
