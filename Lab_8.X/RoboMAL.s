
.ifndef ROBOMAL_S

ROBOMAL_S:
    
# .include "LED.s"
.include "timers.s"
.include "UART.s"
    
    
.data
 # Von Neumann Architecture RoboMAL
 # ROBO_Program: .word 0x10000011, 0x12000011, 0x21000010, 0x31000006, 0x41000090, 0x30000007, 0x40000090, 0x42000001, 0x44000003, 0x33000000, 80, 0 
    
# Harvard Architecture RoboMAL   
.align 2 # ensures the following data starts on a word boundary
ROBO_Instruction: .space 400
ROBO_Data: .word 80, 0 
 
 Operation: .word Data_Transfer_Instructions, Arithmetic_Instructions, Branch_Instructions, Robot_Control_Instructions, One_Motor_Control
 
 Data_Transfer_Instructions: .word READ, WRITE, LOAD, STORE
 
 Arithmetic_Instructions: .word _ADD, SUBTRACT, MULTIPLY
 
 Branch_Instructions: .word BRANCH, BRANCHEQ, BRANCHNE, HALT
 
 Robot_Control_Instructions: .word LEFT, RIGHT, FORWARD, BACKWARD, BRAKE
 
 One_Motor_Control: .word LEFT_FWD, LEFT_BCKWD, RIGHT_FWD, RIGHT_BCKWD
 
 forwardString: .asciiz "Forward" 
 backwardString: .asciiz "Backward"
 leftString: .asciiz "Left" 
 rightString: .asciiz "Right" 
 brakeString: .asciiz "Brake"
 haltString: .asciiz "Halt"
clearDisp: .byte 0x1B, '[', 'j', 0
    
.text

 # s0 = accumulator register
 # s1 = program counter
 # s2 = instruction register
 # s3 = opcode register
 # s4 = operand register 
 
.ent runProgram
runProgram:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # initialize my CPU registers to 0
    MOVE $s0, $zero
    MOVE $s1, $zero
    MOVE $s2, $zero
    MOVE $s3, $zero
    MOVE $s4, $zero
    
Roboloop:
    jal simulateClockCycle
    beq $s3, 0x3300, endProgram
    j Roboloop
endProgram:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
.end runProgram
 
.ent simulateClockCycle
simulateClockCycle:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal fetch
    jal decode
    jal execute
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
.end simulateClockCycle
    
 # s1 = program counter
 # s2 = instruction register
.ent fetch
fetch:
    # Getting instruction at base + 4*offset
    LA $t0, ROBO_Instruction # base of instruction memory
    SLL $t1, $s1, 2	     # PC * 4
    ADD $t0, $t0, $t1        # ROBO_Instruction + 4*PC
			     # ROBO_Instruction[PC]
    LW $s2, 0($t0)	     # fetch the instruction, store in s2
    # Assuming sequential program, prepare for next fetch
    ADDI $s1, $s1, 1	     # PC += 1
    
    JR $ra       
.end fetch
    
 # s2 = instruction register
 # s3 = opcode register
 # s4 = operand register 
.ent decode
decode:
    # break up instruction register into opcode and operand
    # instruction is 0x????_????
    # opcode is 0x????_0000
    # operand is 0x0000_????
    # LI $t0, 0xFFFF0000 # don't need to mask, shift right
    # AND $s3, $s2, $t0	 # empties lower bits for us
    SRL $s3, $s2, 16	# opcode is s3 = 0x????
    LI $t0, 0xFFFF
    AND $s4, $s2, $t0   # operand is s4 = 0x????
    
    JR $ra    
.end decode
    
.ent execute
execute:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
# Load the address for master table Operation
LA $t1, Operation
# LA $t5, Data_Transfer_Instructions
# mask off the first 4 digits to find sub-table
LI $t0, 0xF000
AND $t2, $s3, $t0
# shift over 4 HEX
SRL $t2, $t2, 12
LI $t0, 1
SUB $t2, $t2, $t0
SLL $t2, $t2, 2
    
    # opcode is s3 = 0x????
    
ADD $t2, $t2, $t1

LW $t2, 0($t2)


    
LI $t0, 0xF00
AND $t3, $s3, $t0 
SRL $t3, $t3, 6
    
ADD $t4, $t2, $t3
    
LW $t4, 0($t4)
    
JR $t4
    
# Reads PORTE 7:0 and stores it into a
# specific data memory cell.
READ:
    # ROBO_Data: .word 80, 0
    # Set pins 0:7 
    LI $t1, 0xF0
    SW $t1, TRISESET
    
    LW $t0, PORTE
    ANDI $t0, $t0, 0xF0
    
    # load the address of ROBO_Data to $t1
    LA $t1, ROBO_Data
    SLL $t2, $s4, 2
    ADD $t2, $t1, $t2
    # SW $zero, 0($t2)
    
    SW $t0, 0($t2)
    SW $t0, 0($t2)
    SW $t0, 0($t2)

    J endExecute
    
# Writes to PORTE 7:0 from a specific
# data memory cell.
WRITE:
    # PORTG 12-15 LEDs
    LI $t0, 0xF000	# TRISGCLR = 0xF000
    SW $t0, TRISGCLR
    
    SW $t0, LATGCLR	# LATGCLR = 0xF000
    
    JAL load_Data
    
    SLL $a0, $v0, 8
    
    SW $a0, LATGSET
    
    J endExecute
    

# Loads a word from a specific data
# memory cell into s0
LOAD:
    # get the address of the data memory cell
    JAL load_Data
    
    MOVE $s0, $v0
    
    J endExecute
    
# Stores a word from s0 into a specific
# data memory cell.
STORE:
    # get the address of the cell that want to store
    # the data in
    LA $t0, ROBO_Data
    SLL $t1, $s4, 2
    ADD $t1, $t1, $t0
    # Stores the contents of $s0 into the memory cell
    # on the stack
    SW $s0, 0($t1)
    
    J endExecute
    
# Adds a word from a cell in data memory
# to s0. The result is stored in s0.
_ADD:
    LA $t0, ROBO_Data
    SLL $t1, $s4, 2
    ADD $t1, $t1, $t0
    # load the value stored in the memory cell into $t0 
    LW $t0, 0($t1)
    # add the current value of $s0 to the value of the
    # memory cell and store in $s0
    ADD $s0, $s0, $t0
    
    J endExecute
    
# Subtracts a word from a cell in data
# memory from s0. The result is stored in
# s0.
SUBTRACT:
    JAL load_Data
    
    SUB $s0, $s0, $v0
    
    J endExecute
    
# Multiplies the word in s0 by a word in a
# specific data memory cell. The result is
# stored in s5:s0.
MULTIPLY:
    # Load the data stored in memory into $v0
    JAL load_Data
    # multiply values in registers $s0 and $v0
    MULT $s0, $v0
    # store the values in the upper half of acc. in $s5
    MFHI $s5
    # store the values in the lower half of acc. in $s0
    MFLO $s0
    
    J endExecute
    
# Branch to a specific address in data
# memory.
BRANCH:
    # change the program counter to the operand
    MOVE $s1, $s4
    J endExecute
    
# Branch to a specific address in data
# memory if s0 is zero.
BRANCHEQ: 
    # get the address in data memory
    BEQZ $s0, bietz
    J endExecute
    bietz:
    MOVE $s1, $s4
    
    
# Branch to a specific address in data
# memory if s0 is not zero.
BRANCHNE: 
    BNEZ $s0, binetz
    J endExecute
    binetz:
    MOVE $s1, $s4
    
# End of the program, robot stops.
HALT:
    LA $a0, clearDisp
    jal sendString
    LA $a0, haltString
    jal sendString
    
LA $t2, ROBO_Instruction
    
    j endExecute  
    
# Turn the robot left some specified
# number of degrees between [0:99].
LEFT: 
    LA $a0, clearDisp
    jal sendString
    LA $a0, leftString
    jal sendString
    
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
    
    LI $t0, 250
    SW $t0, OC3RS
    
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 100
    MUL $t0, $t0, $t1
    
    MOVE $a0, $t0
    jal delayms

    J endExecute
    
# Turn the robot right some specified
# number of degrees between [0:99].
RIGHT: 
    LA $a0, clearDisp
    jal sendString
    LA $a0, rightString
    jal sendString
    
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET

    LI $t0, 250
    SW $t0, OC1RS
    
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 100
    MUL $t0, $t0, $t1
    
    MOVE $a0, $t0
    jal delayms

    J endExecute
    
# Move the robot forward at slow (00),
# medium (01), or fast speed (10).
FORWARD: 
    LA $a0, clearDisp
    jal sendString
    LA $a0, forwardString
    jal sendString
    
    
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
# Set motors to go
    
    BEQZ $s4, slowFWD
    
    LI $t0, 1
    BEQ $s4, $t0, medFWD
    
    fastFWD:
    LI $t0, 250
    SW $t0, OC1RS
    SW $t0, OC3RS
    J endExecute
    
    medFWD:
    LI $t0, 225
    SW $t0, OC1RS
    SW $t0, OC3RS
    J endExecute 
    
    slowFWD:
    LI $t0, 200
    SW $t0, OC1RS
    SW $t0, OC3RS
    J endExecute
    
# Move the robot backward at slow (00),
# medium (01), or fast speed (10).
BACKWARD:  
    LA $a0, clearDisp
    jal sendString
    LA $a0, backwardString
    jal sendString
    
    SW $zero, counter # clear counter in timer.s to 0
    
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDSET 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDCLR
# Set motors to go
   
    BEQZ $s4, slowBKWD
    
    LI $t0, 1
    BEQ $s4, $t0, medBKWD
    
    fastBKWD:
    LI $t0, 250
    SW $t0, OC1RS
    SW $t0, OC3RS
    J endExecute
    
    medBKWD:
    LI $t0, 225
    SW $t0, OC1RS
    SW $t0, OC3RS
    J endExecute 
    
    slowBKWD:
    LI $t0, 200
    SW $t0, OC1RS
    SW $t0, OC3RS
    J endExecute
    
RIGHT_BCKWD:
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDSET 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDCLR
# Set motors to go
    LI $t0, 250
    SW $t0, OC3RS
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 10
    MUL $t0, $t0, $t1
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC3RS
    
    J endExecute  
RIGHT_FWD:
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
    
    LI $t0, 250
    SW $t0, OC3RS
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 10
    MUL $t0, $t0, $t1
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC3RS
    
    J endExecute
LEFT_BCKWD:
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDSET 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDCLR
# Set motors to go
    LI $t0, 250
    SW $t0, OC1RS
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 10
    MUL $t0, $t0, $t1
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC1RS
    
    J endExecute
LEFT_FWD:
# the H-bridge module FOR OC3 will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module FOR OC1 will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
# Set motors to go
    LI $t0, 250
    SW $t0, OC1RS
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 10
    MUL $t0, $t0, $t1
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC1RS
    
    J endExecute
# Slow the robot down for some number
# of seconds between [0:99].

BRAKE:

    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 1000
    MUL $t0, $t0, $t1
    MOVE $a0, $t0
    jal delayms
    
    LA $a0, clearDisp
    jal sendString
    LA $a0, brakeString
    jal sendString
    
    # write to both motors to slow down by value in $s0
    SW $zero, OC1RS
    SW $zero, OC3RS
   
    endExecute: 
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    JR $ra
    
.end execute
   
.ent load_Data
load_Data:
    
    LA $t0, ROBO_Data
    SLL $t1, $s4, 2
    ADD $t1, $t1, $t0
    LW $v0, 0($t1)
    LW $v0, 0($t1)
    LW $v0, 0($t1)
    
    JR $ra
.end load_Data
    
    
.ent delay
delay:
    
    MOVE $t0, $a0
    MOVE $t1, $a0
    loop1:
	ADDI $t0, $t0, -1
	loop2:
	    ADDI $t1, $t1, -1
	    BGTZ $t1, loop2
	BGTZ $t0, loop1
    JR $ra
.end delay
	    
.endif