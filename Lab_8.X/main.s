.include "UART.s"
.include "SPI.s"
.include "Buttons.s"
.include "outputCompare.s"
.include "timers.s"
.include "RoboMAL.s"
    
.global main
    
 .data
    # clearDisp: .byte 0x1B, '[', 'j', 0
    setCursorType: .byte 0x1B, '[', '2', 'c', 0
    myString: .asciiz "Hello World!"  
    
.text
 
.ent main
main:
    
    DI	# disables all interrupts
    
    # jal setupLEDs
    
    jal setupTMR2
    jal startTMR2
    jal setupOC1
    jal setupOC3
    
    LI $t0, 1 << 12
    SW $t0, INTCONSET
    
    jal setupTMR1
    
    EI	# re-enable all interrupts
    
    jal setupUART1
    jal setupUART2
    jal setupButtons
    
    LA $a0, clearDisp
    jal sendString
    
    LA $a0, setCursorType
    jal sendString
    
    LA $t2, ROBO_Instruction
    
    loop:
	# Get Insruction Phase
	
	waitforchar:
	LW $t0, U1STA
	ANDI $t1, $t0, 1
	BEQZ $t1, waitforchar
	LI $t1, 2
	MOVE $t3, $t2
	DIV $t3, $t1
	MFHI $t1
	BNEZ $t1, opCode
    
     	LB $a0, U1RXREG
	# store this data to robomal memory
	
	LI $t3, 0x33
	BEQ $t3, $a0, clearOERR
	
	SB $a0, 0($t2)
	ADDI $t2, $t2, 3
	
	j loop
	
	opCode:
	LB $a0, U1RXREG
	SB $a0, 0($t2)
	ADDI $t2, $t2, 1
	
	j loop
	
# 	LW $t0, U1STA
# 	ANDI $t1, $t0, 1
# 	BEQZ $t1, loop

	clearOERR:
	LI $t0, 0b10
	SW $t0, U1STACLR 
	
	SLL $a0, $a0, 24
	SW $a0, 0($t2)
	

	# RoboMAL Program Run Phase
	
	jal runProgram
	
    j loop
    
.end main

# Hook to timer 1 handler
.section .vector_4, code
j tmr1Handler

.text
    
.ent tmr1Handler
tmr1Handler:
    DI # disable global interrupts - don't want an interrupt to interrupt this interrupt
    
    ADDI $sp, $sp, -4	# Using t0, make sure to preserve it
    SW $t0, 0($sp)
    
    LI $t0, 1		# trigger interrupt flag high to designate 1 ms has elapsed
    SW $t0, msFlag    
    
    # Clear the interrupt flag
    LI $t0, 1 << 4
    SW $t0, IFS0CLR # Clears the interrupt flag
    
    LW $t0, 0($sp)
    ADDI $sp, $sp, 4
    
    EI	    # re-enable global interrupts
    ERET    # exception return, set PC = EPC    
.end tmr1Handler



