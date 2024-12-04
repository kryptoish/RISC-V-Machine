`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

module lab7bonus_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output reg [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    reg [8:0] mem_addr;
    reg [7:0] read_address, write_address, next_LEDR, onto_LEDR;
    reg write, enable;
    reg [15:0] dout, din, read_data, write_data, ir;
    wire [1:0] mem_cmd;
    reg msel;
    wire N, V, Z;


    RAM MEM(.clk (~KEY[0]),
            .read_address (read_address),
            .write_address (write_address),
            .write (write),
            .din (din),
            .dout (dout)
            );

    cpu CPU(.clk (~KEY[0]),
            .reset (~KEY[1]),
            .read_data (read_data),
            .write_data(write_data),
            .mem_addr(mem_addr),
            .mem_cmd(mem_cmd),
            .N(N),
            .V(V),
            .Z(Z)
            );


    always_comb begin
        msel = mem_addr[8]; //checks the last bit to check the indicated address. 0 would mean below 255 and 1 would mean abouve 256
        write  =  ({mem_cmd, msel} == {`MWRITE, 1'b0}); //write choosing
        enable = ({mem_cmd, msel} == {`MREAD, 1'b0}); //the and gates and stuff

        write_address = mem_addr[7:0];
        read_address = mem_addr[7:0];
        din = write_data;

        read_data = enable ? dout : {16{1'bz}}; //tri-state driver
    end  
endmodule


// Ram block obtained form slide set 11
module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule
