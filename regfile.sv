module regfile(data_in,writenum,write,readnum,clk,data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output reg [15:0] data_out;
    
    // This file is made explicit and long for easy readability
    // e.g
    // The always_comb can have only one case (readnum to data_out change)
    // The always_ff in turn will only have one if and one case (write and writenum to R0-R7)
    // make file more efficient

    reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    
    always_comb begin
        //read num for data_out
        case (readnum)
            3'b000: data_out = R0;
            3'b001: data_out = R1;
            3'b010: data_out = R2;
            3'b011: data_out = R3;
            3'b100: data_out = R4;
            3'b101: data_out = R5;
            3'b110: data_out = R6;
            3'b111: data_out = R7;
        endcase
    end

    always_ff @(posedge clk) begin
        if (write) begin //only load into register if write is on = 1
            case (writenum)
                // Check load select and put data_in into R0-7 depending
                3'b000: R0 <= data_in;
                3'b001: R1 <= data_in;
                3'b010: R2 <= data_in;
                3'b011: R3 <= data_in;
                3'b100: R4 <= data_in;
                3'b101: R5 <= data_in;
                3'b110: R6 <= data_in;
                3'b111: R7 <= data_in;
            endcase
        end
    end

endmodule