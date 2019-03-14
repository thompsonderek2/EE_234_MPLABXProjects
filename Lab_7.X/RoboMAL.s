
.ifndef ROBOMAL_S

ROBOMAL_S:
    
# .include "LED.s"
.include "timers.s"
    
    
.data
 # Von Neumann Architecture RoboMAL
 ROBO_Program: .word 0x10000011, 0x12000011, 0x21000010, 0x31000006, 0x41000090, 0x30000007, 0x40000090, 0x42000001, 0x44000003, 0x33000000, 80, 0 
    
# Harvard Architecture RoboMAL   
# ROBO_Instruction: .word 0x10000001, 0x12000001, 0x21000000, 0x31000006, 0x41000090, 0x30000007, 0x40000090, 0x42000000, 0x44000003, 0x33000000
# ROBO_Instruction: .word 0x10000000, 0x12000000, 0x11000000, 0x33000000 # lights up onboard LEDs when respective switch is flipped
# ROBO_Instruction: .word 0x10000001, 0x12000001, 0x21000000, 0x31000006, 0x41000090, 0x30000007, 0x40000090, 0x43000000, 0x44000003, 0x33000000
# ROBO_Instruction: .word 0x42000000, 0x4400000A, 0x43000000, 0x4400000A, 0x33000000 # FORWARD, BRAKE, BACKWARDS, BRAKE
# ROBO_Instruction: .word 0x5000002D, 0x5400000A, 0x5100002D, 0x5400000A, 0x5200002D, 0x5500000A, 0x5300002D, 0x5500000A, 0x33000000 # LEFT FORWARD, BRAKE, LEFT BACKWARD, BRAKE, RIGHT FORWARD, BRAKE, RIGHT BACKWARD
# ROBO_Instruction: .word 0x5200001E, 0x5500000A, 0x4200000A, 0x44000001, 0x50000064, 0x5400000A, 0x4200000A, 0x44000001, 0x50000064, 0x5400000A, 0x4200000A, 0x44000001, 0x33000000 # Triangle
# ROBO_Instruction: .word 0x4200000A, 0x44000001, 0x52000050, 0x5500000A, 0x4200000A, 0x44000001, 0x52000050, 0x5500000A, 0x4200000A, 0x44000001, 0x52000050, 0x5500000A, 0x4200000A, 0x44000001, 0x33000000 # Square
# ROBO_Instruction: .word 0x500000C8, 0x5400000A, 0x500000C8, 0x5400000A, 0x52000168, 0x5500000A, 0x33000000 # circle and figure 8
# ROBO_Instruction: .word 0x5200001E, 0x5500000A, 0x4200000A, 0x44000001, 0x50000064, 0x5400000A, 0x4200000A, 0x44000001, 0x50000064, 0x5400000A, 0x4200000A, 0x44000001, 0x4200000A, 0x44000001, 0x52000050, 0x5500000A, 0x4200000A, 0x44000001, 0x52000050, 0x5500000A, 0x4200000A, 0x44000001, 0x52000050, 0x5500000A, 0x4200000A, 0x44000001, 0x500000C8, 0x5400000A, 0x500000C8, 0x5400000A, 0x52000168, 0x5500000A, 0x33000000
# ROBO_Instruction: .word 0x10000001, 0x12000001, 0x30000010, 0x30000010, 0x30000010, 0x3000000E, 0x3000000C, 0x30000010, 0x3000000E, 0x3000000E, 0x3000000E, 0x3000000C, 0x43000032, 0x30000011, 0x51000032, 0x30000011, 0x53000032, 0x33000000
# ROBO_Instruction: .word 0x10000001, 0x12000001, 0x34000005, 0x35000007, 0x36000009, 0x43000001, 0x3000000A, 0x51000001, 0x3000000A, 0x53000001, 0x33000000
  ROBO_Instruction: .word 0x10000001, 0x12000001, 0x34000007, 0x35000009, 0x3600000B, 0x3700000D, 0x3800000F, 0x42000005, 0x30000010, 0x40000003, 0x30000010, 0x41000003, 0x30000010, 0x40000040, 0x30000010, 0x41000040, 0x33000000
ROBO_Data: .word 80, 0 
 
 Operation: .word Data_Transfer_Instructions, Arithmetic_Instructions, Branch_Instructions, Robot_Control_Instructions, One_Motor_Control
 
 Data_Transfer_Instructions: .word READ, WRITE, LOAD, STORE
 
 Arithmetic_Instructions: .word _ADD, SUBTRACT, MULTIPLY, 0
 
 Branch_Instructions: .word BRANCH, BRANCHEQ, BRANCHNE, HALT, BRANCHIFFWD, BRANCHIFLEFT_SHARP, BRANCHIFRIGHT_SHARP, BRANCHIFLEFT_SLIGHT, BRANCHIFRIGHT_SLIGHT
 
 Robot_Control_Instructions: .word LEFT, RIGHT, FORWARD, BACKWARD, BRAKE
 
 One_Motor_Control: .word LEFT_FWD, LEFT_BCKWD, RIGHT_FWD, RIGHT_BCKWD
    
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
    
#     # Find the address of the data memory cell
#     JAL load_Data
#     
#     # configure pins 0:7 to be outputs
#     LI $t1, 0xFF	# TRISECLR = 0xFF
#     SW $t1, TRISECLR
#     # clear the pins
#     SW $t1, LATECLR
#     
#     # set the pins with the contents of $v0
#     SW $v0, LATESET
#     
#     J endExecute
#     
# # Loads a word from a specific data
# # memory cell into s0
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
    # write to motors, LEDs, other outputs to turn off
    
    # SIMULATION
    LI $a0, 0
    # JAL setLEDs
    
    # restarts the program
    J runProgram
    
# Branch to a specific address in data
# memory if s0 is not zero.
BRANCHIFFWD: 
    
    LI $t0, 0
    BEQ $s0, $t0,  bieq
    
    LI $t0, 0b10010000
    BEQ $s0, $t0,  bieq
    
    LI $t0, 0b11110000
    BEQ $s0, $t0,  bieq
    
#     LI $t0, 0b11010000
#     BEQ $s0, $t0,  bieq2
#     
#     LI $t0, 0b10110000
#     BEQ $s0, $t0,  bieq2
    
    J endExecute
    bieq:
    MOVE $s1, $s4
    J endExecute

# Branch to a specific address in data
# memory if s0 is not zero.
BRANCHIFRIGHT_SHARP: 
    
    LI $t0, 0b00010000
    BEQ $s0, $t0,  bieq1
    
    LI $t0, 0b00110000
    BEQ $s0, $t0,  bieq1
    
    LI $t0, 0b01110000
    BEQ $s0, $t0,  bieq1
   
    
    J endExecute
    bieq1:
    MOVE $s1, $s4
    J endExecute
    
BRANCHIFRIGHT_SLIGHT: 
    
    LI $t0, 0b10110000
    BEQ $s0, $t0,  bieq2
  
    J endExecute
    bieq2:
    MOVE $s1, $s4
    J endExecute
    
# Branch to a specific address in data
# memory if s0 is not zero.
BRANCHIFLEFT_SHARP: 
    
    LI $t0, 0b10000000
    BEQ $s0, $t0,  bieq3
    
    LI $t0, 0b11000000
    BEQ $s0, $t0,  bieq3
    
    LI $t0, 0b11100000
    BEQ $s0, $t0,  bieq3
    
    
    J endExecute
    bieq3:
    MOVE $s1, $s4
    J endExecute
    
BRANCHIFLEFT_SLIGHT: 
     
    LI $t0, 0b11010000
    BEQ $s0, $t0,  bieq4
    
    J endExecute
    bieq4:
    MOVE $s1, $s4
    J endExecute
    
# Turn the robot left some specified
# number of degrees between [0:99].
LEFT: 
    
# the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
    
    LI $t0, 400
    SW $t0, OC1RS
# Divide output compare register by operand, load divisor into $t1 
    DIV $t0, $s4
    MFLO $t1
    LW $t0, OC1RS
# Subtract the divisor from the contents of output compare register
    SUB $t0, $t0, $t1
    SW $t0, OC1RS

    LI $t0, 400
    SW $t0, OC3RS
# Divide output compare register by operand, load divisor into $t1    
    DIV $t0, $s4
    MFLO $t1
    LW $t0, OC3RS
# Add the divisor from the contents of output compare register 
    ADD $t0, $t0, $t1
    SW $t0, OC3RS
    
    # wait for $s4 seconds
    MOVE $t0, $s4
#     LI $t1, 10
#     MUL $t0, $t0, $t1
    LI $t0, 5
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC3RS
    SW $zero, OC1RS
        
    J endExecute
    
# Turn the robot right some specified
# number of degrees between [0:99].
RIGHT: 
    
# the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET

    LI $t0, 400
    SW $t0, OC3RS
# Divide output compare register by operand, load divisor into $t1 
    DIV $t0, $s4
    MFLO $t1
    LW $t0, OC3RS
# Subtract the divisor from the contents of output compare register
    SUB $t0, $t0, $t1
    SW $t0, OC3RS

    LI $t0, 400
    SW $t0, OC1RS
# Divide output compare register by operand, load divisor into $t1    
    DIV $t0, $s4
    MFLO $t1
    LW $t0, OC1RS
# Add the divisor from the contents of output compare register 
    ADD $t0, $t0, $t1
    SW $t0, OC1RS
    
    # wait for $s4 seconds
    # MOVE $t0, $s4
#     LI $t1, 10
#     MUL $t0, $t0, $t1
    LI $t0, 5
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC3RS
    SW $zero, OC1RS

    
    J endExecute
    
# Move the robot forward at slow (00),
# medium (01), or fast speed (10).
FORWARD: 

    # the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
# Set motors to go
    LW $t0, OC1RS
    ADDI $t0, $t0, 400
    SW $t0, OC1RS

    LW $t0, OC3RS
    ADDI $t0, $t0, 400
    SW $t0, OC3RS
    
    # wait for $s4 seconds
    MOVE $t0, $s4
#     LI $t1, 10
#     MUL $t0, $t0, $t1
    
    MOVE $a0, $t0
    jal delayms
    
    SW $zero, OC3RS
    SW $zero, OC1RS
    
    J endExecute
    
# Move the robot backward at slow (00),
# medium (01), or fast speed (10).
BACKWARD:  
    SW $zero, counter # clear counter in timer.s to 0
    
# the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDSET 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDCLR
# Set motors to go
    LW $t0, OC1RS
    ADDI $t0, $t0, 400
    SW $t0, OC1RS

    LW $t0, OC3RS
    ADDI $t0, $t0, 400
    SW $t0, OC3RS
    
#     # wait for $s4 seconds
#     MOVE $t0, $s4
#     LI $t1, 100
#     MUL $t0, $t0, $t1
#     MOVE $a0, $t0
#     jal delayms
#     
#     SW $zero, OC3RS
#     SW $zero, OC1RS
    
    J endExecute
    
RIGHT_BCKWD:
    # the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDSET 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDCLR
# Set motors to go
    LW $t0, OC3RS
    ADDI $t0, $t0, 400
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
        # the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
    
    LW $t0, OC3RS
    ADDI $t0, $t0, 450
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
    # the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDSET 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDCLR
# Set motors to go
    LW $t0, OC1RS
    ADDI $t0, $t0, 400
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
        # the H-bridge module will have JD-07 (RD01) be the dir pin
    LI $t0, 0b10
    SW $t0, LATDCLR 
# the H-bridge module will have JD-01 (RD09) be the dir pin
    LI $t0, 0b1000000000
    SW $t0, LATDSET
# Set motors to go
    LW $t0, OC1RS
    ADDI $t0, $t0, 450
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
    
    # write to both motors to slow down by value in $s0
    LW $t0, OC1RS
    ADDI $t0, $t0, -500
    SW $t0, OC1RS

    LW $t0, OC3RS
    ADDI $t0, $t0, -500
    SW $t0, OC3RS
    
    # wait for $s4 seconds
    MOVE $t0, $s4
    LI $t1, 1000
    MUL $t0, $t0, $t1
    MOVE $a0, $t0
    jal delayms
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







