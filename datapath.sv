module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
                loadc, loads, writenum, write, Z_out, datapath_out, sximm5, sximm8, mdata);

    input clk;
    input write, loada, loadb, asel, bsel, loadc, loads;
    input [2:0] readnum, writenum;
    input [1:0] shift, ALUop, vsel;
    input [15:0] sximm8;
    input [15:0] sximm5; 
    input [15:0] mdata;

    output reg [15:0] datapath_out;
    output reg [2:0] Z_out;

    reg [15:0] data_in, in, Aout;
    reg [7:0] PC = 8'b0; // fix later
    reg [15:0] Ain, Bin = {16{1'b0}};
    wire [15:0] data_out, sout, out;
    wire [2:0] Z;
    //initialize all ins and outs and internal wires above

    regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);
    shifter SHIFTER(in,shift,sout);
    ALU     alu(Ain,Bin,ALUop,out,Z);

    //the three components

    always_comb begin
        case (vsel) 
            2'b00: data_in = datapath_out; //also known as C
            2'b01: data_in = {8'b0, PC};
            2'b10: data_in = sximm8; //immediate sign extended 
            2'b11: data_in = mdata;
        endcase
        
        Bin = bsel ? sximm5 : sout; //the Bin multiplexer
        Ain = asel ? ({16{1'b0}}) : Aout; //the Ain multiplexer 
    end

    always_ff @(posedge clk) begin
        //push all when clk is pressed
        if (loadb) in = data_out;
        if (loada) Aout = data_out;
        if (loadc) datapath_out = out;
        if (loads) Z_out = Z;
    end

endmodule
