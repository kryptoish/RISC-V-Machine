radix define states {
	"3'b000" "RESET",
	"3'b001" "HALT",
	"3'b010" "FETCH",
	"3'b011" "DECODE",
	"3'b100" "EXECUTE",
	"3'b101" "MEMORY",
	"3'b110" "WRITEBACK",
	-default default
}
radix define memory {
	"2'b00" "NOP",
	"2'b01" "WRITE",
	"2'b10" "READ",
	-default default
}

add wave -noupdate /lab7bonus_tb/err
add wave -noupdate /lab7bonus_tb/DUT/CPU/clk
add wave -noupdate /lab7bonus_tb/DUT/CPU/reset
add wave -noupdate /lab7bonus_tb/DUT/CPU/instruction
add wave -noupdate -radix hexadecimal /lab7bonus_tb/DUT/CPU/PC
add wave -noupdate -radix hexadecimal /lab7bonus_tb/DUT/CPU/pc_next
add wave -noupdate -radix states /lab7bonus_tb/DUT/CPU/FSM/state
add wave -noupdate -expand -group {Instruction decoder} /lab7bonus_tb/DUT/CPU/opcode
add wave -noupdate -expand -group {Instruction decoder} /lab7bonus_tb/DUT/CPU/op
add wave -noupdate -expand -group {Instruction decoder} /lab7bonus_tb/DUT/CPU/sh
add wave -noupdate -expand -group {Instruction decoder} /lab7bonus_tb/DUT/CPU/Rn
add wave -noupdate -expand -group {Instruction decoder} /lab7bonus_tb/DUT/CPU/Rd
add wave -noupdate -expand -group {Instruction decoder} /lab7bonus_tb/DUT/CPU/Rm
add wave -noupdate -expand -group {Instruction decoder} -radix hexadecimal /lab7bonus_tb/DUT/CPU/sximm5
add wave -noupdate -expand -group {Instruction decoder} -radix hexadecimal /lab7bonus_tb/DUT/CPU/sximm8
add wave -noupdate -divider {PIPELINE REGISTERS}
add wave -noupdate -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/aout
add wave -noupdate -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/bout
add wave -noupdate -divider {CONTROL SIGNALS}
add wave -noupdate -expand -group {CPU Signals} /lab7bonus_tb/DUT/CPU/pc_reset
add wave -noupdate -expand -group {CPU Signals} /lab7bonus_tb/DUT/CPU/pc_load
add wave -noupdate -expand -group {CPU Signals} /lab7bonus_tb/DUT/CPU/ir_load
add wave -noupdate -expand -group {CPU Signals} /lab7bonus_tb/DUT/CPU/addr_sel
add wave -noupdate -expand -group {CPU Signals} -radix memory /lab7bonus_tb/DUT/CPU/mem_cmd
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/write
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/loada
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/loadb
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/loadc
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/loads
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/loadm
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/asel
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/bsel
add wave -noupdate -expand -group {Datapath Signals} /lab7bonus_tb/DUT/CPU/csel
add wave -noupdate -divider OUTPUT
add wave -noupdate -radix hexadecimal /lab7bonus_tb/DUT/CPU/mem_addr
add wave -noupdate /lab7bonus_tb/DUT/CPU/out
add wave -noupdate -expand -group Status /lab7bonus_tb/DUT/CPU/DP/N
add wave -noupdate -expand -group Status /lab7bonus_tb/DUT/CPU/DP/V
add wave -noupdate -expand -group Status /lab7bonus_tb/DUT/CPU/DP/Z
add wave -noupdate -divider REGISTERS/MEMORY
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate -expand -group Registers -radix hexadecimal /lab7bonus_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate -radix decimal /lab7bonus_tb/DUT/MEM/mem
