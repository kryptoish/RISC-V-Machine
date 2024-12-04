    MOV R6,stack_begin
    LDR R6,[R6]       // initialize stack pointer
    MOV R4, result    // R4 contains address of result
    MOV R3,#0
    STR R3,[R4]       // result = 0;
    MOV R0,#1         // R0 contains first parameter
    MOV R1,#5         // R1 contains second parameter
    MOV R2,#9         // R2 contains third parameter
    MOV R3,#20        // R3 contains fourth parameter
    BL  leaf_example  // call leaf_example(1,5,9,20);
    STR R0,[R4]       // result = leaf_example(1,5,9,20);  
    HALT
leaf_example:
    STR R4,[R6]       // save R4 for use afterwards
    STR R5,[R6,#-1]   // save R5 for use afterwards
    ADD R4,R0,R1      // R4 = g + h
    ADD R5,R2,R3      // R5 = i + j
    MVN R5,R5         // R5 = ~(i + j)
    ADD R4,R4,R5      // R4 = (g + h) + ~(i + j)
    MOV R5,#1
    ADD R4,R4,R5      // R4 = (g + h) - (i + j)
    MOV R0,R4         // R0 = return value (g + h) - (i + j) 
    LDR R5,[R6,#-1]   // restore saved contents of R5
    LDR R4,[R6]       // restore saved contents of R4
    BX  R7            // return control to caller
stack_begin:
    .word 0xFF
result:
    .word 0xCCCC
