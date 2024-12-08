`define M_NOP 2'b00
`define M_READ 2'b10
`define M_WRITE 2'b01

module cpu_tb;
	reg err, clk, reset;

	tb_top DUT(clk, reset);

	initial forever begin
		clk = 0; #5;
		clk = 1; #5;
	end

	initial begin
		#2000;
		$display("Time limit reached.\n");
		$stop;
	end

	initial begin
		reset = 1'b1;
		#10;
		reset = 1'b0;
	end
endmodule: cpu_tb

module tb_top(input clk, input reset);
	wire write, N, V, Z;
	wire [1:0] mem_cmd;
	wire [8:0] mem_addr;
	wire [15:0] din, dout, mem_data;

	ram #(16, 8, "data_cpu_tb.txt") MEM(clk, mem_addr[7:0], write, din, dout);
	cpu CPU(clk, reset, mem_data, mem_cmd, mem_addr, din, N, V, Z);

	assign mem_data = (mem_cmd == `M_READ & ~mem_addr[8])
		? dout : {16{1'bz}};
	assign din = {16{1'bz}};
	assign write = mem_cmd == `M_WRITE & ~mem_addr[8];
endmodule: tb_top
