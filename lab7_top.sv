`define M_NOP 2'b00
`define M_READ 2'b10
`define M_WRITE 2'b01

module lab7_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;

	wire clk, write, N, V, Z;
	wire [1:0] mem_cmd;
	wire [8:0] mem_addr;
	wire [15:0] din, dout, mem_data;

	ram #(16, 8) MEM(clk, mem_addr[7:0], write, din, dout);
	cpu CPU(clk, reset, mem_data, mem_cmd, mem_addr, din, N, V, Z);

	assign clk = KEY[0];
	assign reset = ~KEY[1];

	assign mem_data = (mem_cmd == `M_READ & ~mem_addr[8])
		? dout : {16{1'bz}};
	assign write = mem_cmd == `M_WRITE & ~mem_addr[8];
endmodule: lab7_top

module ram(clk, addr, write, din, dout);
	parameter data_width = 32;
	parameter addr_width = 4;
	parameter filename = "data.txt";

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
