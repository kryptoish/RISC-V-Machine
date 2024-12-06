To-do
=====

- PR for IF/FD, ID/EX, EX/MEM, MEM/WB.
	- Put inside CPU file.
- HDU Unit.
- Forwarding Unit.
- Make RAM read/write to two addresses.
- REGFILE NEGEDGE.

Control signals needed for each stage
-------------------------------------

pc_reset, pc_load, pc_sel, ir_load, addr_sel, mem_cmd,
reg_w_sel, reg_a_sel, reg_b_sel, write, loada, loadb,
loadc, loads, loadm, asel, bsel, csel, vsel, halt

ram(clk, write, write_addr, inst_addr, data_addr, in, inst_out, data_out);

IF/ID

- Instruction
	- opcode
	- op
	- Rn
	- Rd
	- sh
	- Rm
	- sximm8
	- sximm5
	- cond
- pc_reset
- pc_load
- pc_sel
- ir_load
<!-- - reg_w_sel
- reg_a_sel
- reg_b_sel -->
- reg_w
- reg_a
- reg_b
- write

ID/EX

- (opcode)
- op
- Rn
- Rd
- Rm
- sximm5

- asel
- bsel

EX/MEM

- opcode
- Rn
- Rd
- Rm

<!-- - mem_cmd
- write_addr
- data_addr -->
- mem_write

MEM/WB

- opcode
- op
- newcontrol signal for mux

- vsel ???

HDU:

if hazard detected in memred, then stall IFID write and PCwrite.
Maybe also make something that stalls IDEX. when something has been stalled send a signal to forward alu output (in MEM stage) directly to the EX stage mux for aout and bout.

Forwarding:

Forwarding unit chceks if a stall i