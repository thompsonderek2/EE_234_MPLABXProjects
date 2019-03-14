.include "timer.s"
.include "buttons.s"
    
.global main
  
.data

counter: .word 0
counter2: .word 0
state: .word 0

    
.text

 
#  Requirements:
# - Pressing on-board BTN1 must start the up counter (counts 0 ? 15)
# - Pressing on-board BTN2 must start the down counter (counts 15 ? 0)
# - Pressing on-board BTN3 once must stop the counter
# - Pressing BTN3 twice must clear the counter (counter = 0) (the first press
# will stop the counter, the second press will reset the counter)
# - Flipping a switch, corresponding to INT3, from low to high triggers an
# interrupt to double the counter time
# - Flipping a switch, corresponding to INT4 from low to high triggers an
# interrupt to halve the counter time
    
.ent main
main:

    DI	# disables all interrupts
    
    jal setupLEDs
        
    # Turn on multi-vector mode to support multiple interrupt requests
    # INTCON<12> = 1
    LI $t0, 1 << 12
    SW $t0, INTCONSET
    
    # setup all interrupts  
    jal setupTMR1
    jal setupTMR32
    jal setupExtInt3
    jal setupExtInt4
    jal setupButtons
    
    EI	# re-enable all interrupts
    
    # turn on timer 2 - T1CON<15> = 1
    LI $t0, 1 << 15
    SW $t0, T2CONSET
    
    loop:
	LW $t0, state
	LI $t1, 0b1000
	BEQ $t0, $t1, restart_timer
	
	jal getButtons	
	BEQZ $v0, ignore
	SW $v0, state
	ignore:
	
     	LW $a0, counter2
 	jal setLEDs
	
	j loop
	
    restart_timer:
    
	LI $t1, 0b100
	jal getButtons
	BEQ $v0, $t1, reset
	BEQZ $v0, ignore2
	SW $v0, state
	ignore2:

    j loop
    
    reset:
	SW $zero, counter2
	LW $a0, counter2
 	jal setLEDs
    j loop
    
.end main
    
# Find the register and pin configurations to set up interrupts and timers in 
# table 7.1 on page 74 in the PIC32MX5XX/6XX/7XX Family Data Sheet

# Timer information in PIC32 Family Reference Manual Section 14. Timers
# Interrupt information in PIC32 Family Reference Manual Section 8. Interrupts
    
# INT3 - RA14
# Flag - IFS0<15>
# Enable - IEC0<15>
# Priority - IPC3<28:26>
# Sub-Priority - IPC3<25:24>
# Polarity - INTCON<3>    
.ent setupExtInt3
setupExtInt3:
    
    # Input Pin at RA14
    LI $t0, 1 << 14
    SW $t0, TRISASET
    
    # Set Polarity of ext interrupt 3
    # INTCONSET = 0b1000
    LI $t0, 0b1000
    SW $t0, INTCONSET
    
    # Set Priority of ext interrupt 3
    # Priority = 4; Sub-Priority = 0;
    # IPC3<28:26> = 4; IPC<25:24> = 0 
    LI $t0, 0b11111 << 24
    SW $t0, IPC3CLR	    # Clear out any priority given to ext int 3 
			    # previously
    
    LI $t0, 0b10100 << 24   # sets priority to 0b101, sub-priority to 0b01
    SW $t0, IPC3SET
    
    LI $t0, 1 << 15
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious 
		    # interrupt)
    
    JR $ra
.end setupExtInt3
    
.ent setupExtInt4
setupExtInt4:
    
    LI $t0, 1 << 15
    SW $t0, TRISASET
    
    # Sets the polarity of the interrupt (1 triggers on positive clock edge)
    # look up the pin in Section 8: Interrupts in the PIC32 family reference 
    # manual
    LI $t0, 0b10000
    SW $t0, INTCONSET
    
    # Set Priority of ext interrupt 4
    # Priority = 6; Sub-Priority = 0;
    # IPC4<28:26> = 3; IPC4<25:24> = 0
    LI $t0, 0b11111 << 24
    SW $t0, IPC4CLR # Clear out any priority given to ext int 4 previously
    
    LI $t0, 0b10100 << 24 # sets priority to 0b101, sub-priority to 0b00
    SW $t0, IPC4SET 
    
    LI $t0, 1 << 19
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious 
		    # interrupt)
    
    JR $ra
.end setupExtInt4

.ent setupLEDs
setupLEDs:
    LI $t0, 0xF000
    SW $t0, TRISGCLR
    SW $t0, LATGCLR
    
    JR $ra    
.end setupLEDs
    
.ent setLEDs
setLEDs:
    # clear LEDs
    LI $t0, 0xF000
    SW $t0, LATGCLR
    
    # set to value stored in a0
    MOVE $t0, $a0
    SLL $t0, $t0, 12
    SW $t0, LATGSET
    
    JR $ra    
.end setLEDs
    
# Hook to external interrupt 3 handler
.section .vector_15, code
j extInt3Handler

.text
    
.ent extInt3Handler
extInt3Handler:
    DI # disable global interrupts - don't want an interrupt to interrupt this 
       # interrupt
    
    ADDIU $sp, $sp, -8	# Using t0, make sure to preserve it
    SW $t0, 0($sp)
    SW $t1, 4($sp)
    
    # Double the time between timer interrupts
    LW $t0, PR2
    SLL $t0, $t0, 1
    BEQZ $t0, dontshifttoofarleft
    SW $t0, PR2
    dontshifttoofarleft:
    
    # Clear the interrupt flag
    LI $t0, 1 << 15
    
    SW $t0, IFS0CLR # Clears the interrupt flag
    
    LW $t0, 0($sp)
    LW $t1, 4($sp)
    ADDIU $sp, $sp, 8
    
    EI	    # re-enable global interrupts
    ERET    # exception return, set PC = EPC    
.end extInt3Handler
      
# Hook to external interrupt 4 handler
.section .vector_19, code
j extInt4Handler
   
.text
    
.ent extInt4Handler
extInt4Handler:
    
    DI # disable global interrupts - don't want an interrupt to interrupt this interrupt
    
    ADDI $sp, $sp, -4	# Using t0, make sure to preserve it
    SW $t0, 0($sp)
    
    # halve the time between timer interrupts
    SW $zero, TMR2
    LW $t0, PR2
    SRL $t0, $t0, 1
    BEQZ $t0, dontshifttoofarright
    SW $t0, PR2
    dontshifttoofarright:
    
    # Clear the interrupt flag
    LI $t0, 1 << 19
    
    SW $t0, IFS0CLR # Clears the interrupt flag
    
    LW $t0, 0($sp)
    ADDI $sp, $sp, 4
    
    EI	    # re-enable global interrupts
    ERET    # exception return, set PC = EPC
    
.end extInt4Handler
    
# Hook to timer 1 handler
.section .vector_4, code
j tmr1Handler

.text
    
.ent tmr1Handler
tmr1Handler:
    DI # disable global interrupts - don't want an interrupt to interrupt this 
	# interrupt
    
    ADDI $sp, $sp, -4	# Using t0, make sure to preserve it
    SW $t0, 0($sp)
    
    LI $t0, 1	    # trigger interrupt flag high to designate 1 ms has elapsed
    SW $t0, msFlag    
    
    # Clear the interrupt flag
    LI $t0, 1 << 4
    SW $t0, IFS0CLR # Clears the interrupt flag
    
    LW $t0, 0($sp)
    ADDI $sp, $sp, 4
    
    EI	    # re-enable global interrupts
    ERET    # exception return, set PC = EPC    
.end tmr1Handler
    
 # Hook to timer 3 handler
.section .vector_12, code
j tmr3Handler

.text
    
.ent tmr3Handler
tmr3Handler:
    DI 
    
    ADDI $sp, $sp, -8
    SW $t0, 0($sp)
    SW $t1, 4($sp)
    
    LW $t0, state
    
    LI $t1, 0b1
    BEQ $t0, $t1, countup
    
    LI $t1, 0b10
    BEQ $t0, $t1, countdown
    
    LI $t1, 0b100
    BEQ $t0, $t1, stop

    J skip
    
    countup:
    LW $t0, counter2
    ADDI $t0, $t0, 1
    SW $t0, counter2
    J skip
    
    countdown:
    LW $t0, counter2
    ADDI $t0, $t0, -1
    SW $t0, counter2
    J skip
    
    stop:
    LI $t0, 1000000
    debounce:
    ADD $t0, $t0, -1
    BNEZ $t0, debounce
    
    LI $t0, 0b1000
    SW $t0, state
    
    skip: 
    
    # Clear the interrupt flag in bit IFS0<12>
    LI $t0, 1 << 12
    SW $t0, IFS0CLR 
    
    LW $t1, 4($sp)
    LW $t0, 0($sp)
    ADDI $sp, $sp, 8
    
    EI
    ERET
    
.end tmr3Handler

    
