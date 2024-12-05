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
	wire [8:0] mem_addr;
	wire [15:0] din, dout, mem_data;

	ram #(16, 8) MEM(clk, mem_addr[7:0], write, din, dout);
	cpu CPU(clk, reset, mem_data, mem_cmd, mem_addr, din, N, V, Z, halt);

	disp U0(din[3:0], HEX0);
	disp U1(din[7:4], HEX1);
	disp U2(din[11:8], HEX2);
	disp U3(din[15:12], HEX3);
	disp U4({1'b0, N, V, Z}, HEX4);

	assign clk = CLOCK_50;
	assign reset = ~KEY[1];
	assign LEDR[8] = halt;

	assign mem_data = (mem_cmd == `M_READ & ~mem_addr[8])
		? dout : {16{1'bz}};
	assign write = mem_cmd == `M_WRITE & ~mem_addr[8];
endmodule: lab7bonus_top

module ram(clk, addr, write, din, dout);
	parameter data_width = 32;
	parameter addr_width = 4;
	parameter filename = "data_lab8_check.txt";

	input clk;
	input [addr_width-1:0] addr;
	input write;
	input [data_width-1:0] din;
	output [data_width-1:0] dout;
	reg [data_width-1:0] dout;

	reg [data_width-1:0] mem [2**addr_width-1:0];

	initial $readmemb(filename, mem);

	always @ (posedge clk) begin
		if (write) mem[addr] <= din;
		dout <= mem[addr];
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
