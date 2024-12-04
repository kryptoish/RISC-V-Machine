    MOV R0,N         // R0 = address of variable N
    LDR R0,[R0]      // R0 = 4
    MOV R1,#0        // R1 = 0; R1 is "i"
    MOV R2,#0        // R2 = 0; R2 is "sum"
    MOV R3,amount    // R3 = base address of array "amount"
    MOV R4,#1        // R4 = 1

LOOP:                // for(i=0; i<N; i++) sum = sum + amount[i]; 
    ADD R5,R3,R1     // R5 = address of amount[i]
    LDR R5,[R5]      // R5 = amount[i]
    ADD R2,R2,R5     // sum = sum + amount[i]
    ADD R1,R1,R4     // i++
    CMP R1,R0
    BLT LOOP         // if i < N goto LOOP

    MOV R3,result
    STR R2,[R3]      // result = sum
    HALT

N:
    .word 4
amount:
    .word 50
    .word 200
    .word 100
    .word 500
result:
    .word 0xBADD
