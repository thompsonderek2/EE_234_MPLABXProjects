
.include "keypad.s"
.include "switches.s"
.include "buttons.s"
.include "LEDs.s"    
    
#    The purpose of this program is to create a 4 bit binary calculator that is able to perform a variety of operations using one 
    and two operands collected from a hexidecimal keypad peripheral.
.global main

.data                        # The start of the data segment
# Switch table for managing the different operation labels
operation: .word addition, subtraction, multiplication, division, modulus, 
		 bitwiseAnd, bitwiseOr, bitwiseNor, bitwiseNOT, shiftLeft1, 
		 shiftRight1, rotateLeft1, rotateRight1, setILT, moveIf0
   
.text                        # The start of the code segment
                         
.ent main                    # Setup a main entry point
main:

    jal setupBoard # run setupBoard function to configure peripherals to the 
		   # correct settings.
   
    loop: # main loop for the program 
	    MOVE $v1, $zero

	    loop2: # waits until the first operand is gathered
		jal readKYPD # reads state of keypad
		MOVE $s3, $v1 # stores the first operand in $s3
		BEQZ $v1, loop2  # escape the loop if button(s) is pressed 
				 # ($v1 > 0)

	    jal get_switches # gets the value of switches and store in $v0
	    
	    MOVE $s2, $v0 # store switch states in function variable $s2
	        LI $t0, 0 # Initialize loop counter to 0 
	    MOVE $t2, $s3 # copy value in s3 to t2
	    
	    loop4: # converts the input from the keypad into a binary value.
		   # from the keypad, the operand's value is represented by the
		   # number of trailing 0s after the first 1.  This simple loop
		   # counts the number of trailing 0's and saves this as a 
		   # binary value to the 1st operand register
		   
		addi $t0, $t0, 1 # increment loop counter
		SRL $t2, $t2, 1	# shift $t2 to the right (decrement)
		bnez $t2, loop4 # If ($t2 != 0) Branch to loop
		ADDI $t0, $t0, -1 # subtract 1 from the final count
	    MOVE $s3, $t0 # store the counted number of zeros into the first 
			  # operand register
			  
	    # The below operations are for single operands. If the switches
	    # are set to any of the following configurations, the program
	    # will branch to any of the accompanying labels for the 
	    # operations. Before branching, the label return_after_op is 
	    # stored in the return address register so the program can 
	    # display the value returned by the operation to the LEDs when it
	    # returns from the branch
	    LA $ra, return_after_op # loads label into $ra
	    LI $t0, 0b1001 # bitwise NOT switch configuration
	    BEQ $s2, $t0, bitwiseNOT
	    LI $t0, 0b1010 # Shift Left 1
	    BEQ $s2, $t0, shiftLeft1
	    LI $t0, 0b1011 # Shift Right 1
	    BEQ $s2, $t0, shiftRight1
	    LI $t0, 0b1100 # RL 1
	    BEQ $s2, $t0, rotateLeft1
	    LI $t0, 0b1101 # RR 1
	    BEQ $s2, $t0, rotateRight1
	    
	    # ~1 second DELAY: the purpose of this delay is to prevent both 
	    # operands from being gathered before the button is unpressed.
	    LI $a0, 0 # $a0 = 0
	    LI $t0, 500000 # Initialize loop counter to 500000 
	    for_loop:
		addi $t0, $t0, -1 # Decrement loop counter
		bgtz $t0, for_loop # If ($t0 > 0) Branch to loop 
		
	    MOVE $v1, $zero
	    loop3: # gathers second operand
		jal readKYPD
		MOVE $s1, $v1 # stores the second operand in $s1
		BEQZ $v1, loop3  # escape the loop if button(s) is pressed
	    
	    # conversion of second operand into a binary value
	    LI $t0, 0 # Initialize loop counter to 0 
	    MOVE $t2, $s1
	    loop5:
		addi $t0, $t0, 1 # increment loop counter
		SRL $t2, $t2, 1	  # shift $t2 to the right
		bnez $t2, loop5 # If ($t2 = 0) Branch to loop
		ADDI $t0, $t0, -1
	    MOVE $s1, $t0 
	  
	    # Once two operands have been gathered, jump to the function that 
	    # contains the operations 
	    MOVE $a0, $s2
	    jal setOperation
	    return_after_op: # return here after single operand operation
	    MOVE $a0, $v0 # operation function stores its value in $v0.
			  # Copy into $a0 so this value can be passed into the
			  # setLEDs function.
	    jal setLEDs # Displays the final binary value to the LEDs
	    

    j loop # Embedded programs require that they run forever! 
	   # So jump back to the beginning of the loop
	
.end main
    
# void setupBoard(void)
# sets all inputs and outputs for current project
.ent setupBoard
setupBoard:
    ADDI $sp, $sp, -4 # pushed ra onto the stack to preserve it
    SW $ra, 0($sp) # point the address that the stack pointer is pointing to 
		   # (offset 0) to the current value of the return address.
		   # SW points a memory location to a register. 
		   
# preserving the return address on the stack is necessary when calling functions
# within a function, because the original return address gets overwritten
    
    # Setup LEDs as outputs
    jal setupLEDs
    
    # Setup Buttons as inputs    
    jal setupButtons
    
    # Setup switches as inputs
    jal setup_switches
    
    # Setup Keypad
    jal setupKYPD
    
    # pop ra off the stack
    LW $ra, 0($sp) # loads the value of the return address stored in memory 
		   # into the return address register
    addi $sp, $sp, 4 # moves the stack pointer 32bits back to it's original
		     # location
    jr $ra # jump to the ra register
.end setupBoard
   
 # this function contains the addresses for the operations that are referenced
 # using a switch table
.ent setOperation
    setOperation:
    
    LA $t1, operation

    SLL $a0, $a0, 2
  
    ADD $t0, $t1, $a0
    
    LW $t2, 0($t0)
    
    JR $t2
    
    addition:
	# add 1st operand to second operand
	ADD $v0, $s3, $s1 # add operands 1 and 2, store value in $v0
    j endcase

    subtraction:
	# subtract second operand from first operand
	SUB $v0, $s3, $s1
    j endcase
    
    multiplication:
	# multiply operands
	MUL $v0, $s3, $s1
    j endcase
    
    division:
	DIV $s3, $s1
	MFLO $v0
    j endcase
   
    modulus:
	DIV $s3, $s1
	MFHI $v0
    j endcase

    bitwiseAnd:
	AND $v0, $s3, $s1
    j endcase

    bitwiseOr:
	OR $v0, $s3, $s1
     j endcase   

    bitwiseNor:
	NOR $v0, $s3, $s1
    j endcase

    bitwiseNOT:
	NOT $v0, $s3
    JR $ra

    shiftLeft1:
	SLL $v0, $s3, 1
    JR $ra    

    shiftRight1:
	SRL $v0, $s3, 1
    JR $ra    

    rotateLeft1:
	ROTR $v0, $s3, -1
    JR $ra   

    rotateRight1:
	ROTR $v0, $s3, 1
    JR $ra   

    setILT:
	SLTU $v0, $s3, $s1
    J endcase

    moveIf0:
	MOVZ $v0, $s3, $s1
    J endcase   
    
    endcase:
    
#     # conditional statements, compare to $t0
#     LI $t1, 0b0000
#     BEQ $t0, $t1, addition
#     
#     LI $t1, 0b0001
#     BEQ $t0, $t1, subtraction
#     
#     LI $t1, 0b0010
#     BEQ $t0, $t1, multiplication
#     
#     LI $t1, 0b0011
#     BEQ $t0, $t1, division
#     
#     LI $t1, 0b0100
#     BEQ $t0, $t1, modulus
#     
#     LI $t1, 0b0101
#     BEQ $t0, $t1, bitwiseAnd
#     
#     LI $t1, 0b0110
#     BEQ $t0, $t1, bitwiseOr
   
    
#     returnToSetOperation:
#     LW $ra, 0($sp)
#     ADDI $sp, $sp, 4
    
    jr $ra
    
.end setOperation
    
    

    
    
    
    
    
    
    
    
    