# 8-bit-CPU
A design for an 8-bit CPU in VHDL completed for a university lab project. Twelve one-byte instructions are stored in program memory and are encoded as 8-bit values, the most significant four of which signify a specific Opcode. When implemented on an FPGA, this CPU can receive user input (four bits at a time), store up to 8 values in its register, perform simple math operations, and display the Opcode of the instruction it is currently executing. 
 
The instructions are:  
LDA A,R[r] - 0001 0rrr - Load value from register R[rrr] into accumulator.  
STA R[r],A - 0010 0rrr - Store value from accumulator into register R[rrr].  
LDI A,imm - 0011 0000 xxxx xxxx - Load immediate value xxxx xxxx into accumulator.  
ADD A,R[r] - 0100 0rrr - Add value in accumulator and register R[rrr]. Store result in accumulator.  
SUB A,R[r] - 0101 0rrr - Subtract value in accumulator and register R[rrr]. Store result in accumulator.  
SHFL A - 0110 00xx - Shift value in accumulator left by xx-bits.  
SHFR A - 0111 00xx - Shift value in accumulator right by xx-bits.  
IN A - 1000 0000 - Read user input into lower nibble of accumulator.  
IN A - 1000 0001 - Read user input into upper nibble of accumulator.  
OUT A - 1001 0000 - Output result from accumulator to display.   
HALT - 1010 0000 - Stop execution.
JMPZ - 1100 0000 000a aaaa - If zero flag is set, jump to memory address 000a aaaa.  

