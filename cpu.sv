`define RST 5'b00000
`define GetA 5'b00001
`define GetB 5'b00010
`define operation 5'b00011
`define WriteReg 5'b00100
`define GetACMP 5'b00101
`define GetBCMP 5'b00110
`define GetBonly 5'b00111
`define IF1 5'b01000
`define IF2 5'b01001
`define UpdatePC 5'b01010
`define GetAddr 5'b01011
`define LoadAddr 5'b01100
`define StoreAddr 5'b01101
`define Dout 5'b01110
`define Dout2 5'b01111
`define Dout3 5'b10000
`define Dout4 5'b10001

`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

module cpu(clk,reset,read_data,write_data,mem_addr,mem_cmd,N,V,Z);
    input clk, reset;
    input [15:0] read_data;
    output reg [15:0] write_data;
    output reg [8:0] mem_addr;
    output reg [1:0] mem_cmd;
    output reg N, V, Z; 

    reg [15:0] inst_reg = 16'bx;
    reg [15:0] next_inst_reg, datapath_out;
    reg [2:0] opcode, readnum, writenum, Z_out;
    reg [1:0] op, nsel, shift, ALUop, vsel;
    reg loada, loadb, loadc, loads, write, asel, bsel, 
    load_ir, load_pc, reset_pc, addr_sel, load_addr;
    reg [15:0] sximm8;
    reg [15:0] sximm5;
    reg [4:0] present_state;

    reg [15:0] mdata;
    reg [8:0] PC, next_pc = 9'b0;
    reg [8:0] data_addr, next_data_addr;

    //three more internal wires
    //later change some of these to wires to make less expensive

    datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, 
                loadc, loads, writenum, write, Z_out, datapath_out, sximm5, sximm8, mdata);
    
    //if nsel == 00 -> rm nsel == 01 -> rd, nsel == 10 -> rn
    always_comb begin 
        
        {opcode, op} = inst_reg[15:11]; //decodin like crazy here
        if (opcode == 3'b100) shift = 2'b00;
        else shift = inst_reg[4:3];
        sximm5 = {{11{inst_reg[4]}}, inst_reg[4:0]};
        sximm8 = {{8{inst_reg[7]}} , inst_reg[7:0]}; //fix this back
        ALUop = op;

        case (nsel)
            2'b00: {readnum, writenum} = {2{inst_reg[2:0]}}; //Rm
            2'b01: {readnum, writenum} = {2{inst_reg[7:5]}}; //Rd
            2'b10: {readnum, writenum} = {2{inst_reg[10:8]}}; //Rn
            default: {readnum, writenum} = {writenum, readnum};
        endcase
        
        {Z, V, N} = Z_out; //give out all values
        write_data = datapath_out; 

        mdata = read_data;
        next_inst_reg = load_ir ? read_data : inst_reg; //load for instructions

        next_pc = reset_pc ? 9'b0 : (PC + 1'b1);
        mem_addr = addr_sel ? PC : data_addr;
        next_data_addr = load_addr ? datapath_out[8:0] : data_addr;
    end
    
    // next: first, second and third bit: nsel, second bit loada, third bit loadB, fouth bit asel, 
    // fifth bit bsel, sixth and 7th bit shift, 8th and 9th bit aluop, 10th bit loadc, 11bit vsel, 
    // 12bit write  
    always_ff @(posedge clk) begin
        inst_reg = next_inst_reg;
        data_addr = next_data_addr;
        if (load_pc) PC = next_pc;
        
        casex ({present_state, reset}) 
            //all roads lead to rome (`wait)
            {4'bxxxx, 1'b1} : {present_state, write, load_pc, reset_pc, load_ir} = {`RST, 4'b0110};
            {`RST, 1'b0} : {present_state, write, addr_sel, load_pc, reset_pc, mem_cmd} = {`IF1, 4'b0100, `MREAD};
            {`IF1, 1'b0} : {present_state, load_ir} = {`IF2, 1'b1};
            {`IF2, 1'b0} : {present_state, addr_sel, load_pc, load_ir, mem_cmd} = {`UpdatePC, 3'b010, `MNONE};
            //make IF1 states+, last state before below is UpdatePC

            {`UpdatePC, 1'b0} : begin
                casex ({opcode, op}) //op since ALUop == op
                    //move instructions
                    5'b11010: {present_state, nsel, vsel, write, load_pc} = {`WriteReg, 6'b101010}; // 2 clk cycles
                    5'b11000: {present_state, nsel, loada, loadb, load_pc} = {`GetBonly, 5'b00010}; // 3 clk cycles
                    //alu instructions
                    5'b101x0: {present_state, nsel, loada, load_pc} = {`GetA, 4'b1010}; //ADD & AND ---> 4 clk cycles //loads A
                    5'b10101: {present_state, nsel, loada, load_pc} = {`GetACMP, 4'b1010};  //CMP ---> 3 clk cycles //loads A
                    5'b10111: {present_state, nsel, loada, loadb, load_pc} = {`GetBonly, 5'b00010}; //MVN ---> 3 clk cycles //loads to B
                    //memory instructions
                    5'b01100: {present_state, nsel, loada, loadb, asel, bsel, load_pc, mem_cmd} = {`GetAddr, 7'b1010010, `MREAD}; //LDR
                    5'b10000: {present_state, nsel, loada, loadb, asel, bsel, load_pc} = {`GetAddr, 7'b1010010}; //STR
                    //HALT instruction
                    5'b111xx: {present_state, load_pc} = {`UpdatePC, 1'b0}; //will be stuck here until reset
                endcase
            end
            
            //ADD & AND branch
            {`GetA, 1'b0} : {present_state, nsel, loadb, loada} = {`GetB, 4'b0010}; //loads B
            {`GetB, 1'b0} : {present_state, asel, bsel, loadc, loads} = {`operation,  4'b0010}; //performs operations

            //for writing only from B to Rd
            {`GetBonly, 1'b0} : {present_state, asel, bsel, loadc, loads} = {`operation, 4'b1010};

            //Get the (shifted) memory address (LDR)
            {`GetAddr, 1'b0} : begin
                case (opcode) 
                    3'b011: {present_state, loada, loadb, loadc, load_addr, addr_sel, mem_cmd} = {`Dout, 5'b00110, `MREAD}; //might need an extra state for dout
                    3'b100: {present_state, loada, loadb, loadc, load_addr, addr_sel} = {`StoreAddr, 5'b00110};
                endcase  
            end
            {`Dout, 1'b0} : begin //wait for RAM
                case (opcode) 
                    3'b011: present_state = `Dout2;
                    3'b100: {present_state, loada, loadb, loadc, load_addr, mem_cmd} = {`Dout4, 4'b0010, `MWRITE};
                endcase
            end
            {`Dout2, 1'b0} : {present_state, load_addr} = {`LoadAddr, 1'b0};
            {`LoadAddr, 1'b0} : {present_state, nsel, vsel, write, loadc, load_addr, mem_cmd} = {`Dout3, 7'b0111100, `MREAD};
            {`Dout3, 1'b0} : {present_state, mem_cmd, write} = {`WriteReg, `MNONE, 1'b0};

            {`StoreAddr, 1'b0} : {present_state, nsel, loada, loadb, asel, bsel, load_addr} = {`Dout, 7'b0101101};
            {`Dout4, 1'b0} : {present_state, write} = {`WriteReg, 1'b0};

            //CMP branch
            {`GetACMP, 1'b0} : {present_state, nsel, loadb, loada} = {`GetBCMP, 4'b0010}; //loads B
            {`GetBCMP, 1'b0} : {present_state, asel, bsel, loadc, loads} = {`WriteReg,  4'b0001}; //performs operations and writes into status

            //write to Rd
            {`operation, 1'b0} : {present_state, nsel, vsel, write} = {`WriteReg, 5'b01001}; //writing into the register
             //waiter/reset
            {`WriteReg, 1'b0} : {present_state, loada, loadb, loadc, loads, mem_cmd} = {`RST, 4'b0000, `MNONE}; //extra cycle for values to got through (should I go reset or IF1)
        endcase      
    end
 endmodule