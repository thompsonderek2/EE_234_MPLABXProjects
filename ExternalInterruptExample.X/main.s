.include "timer.s"
    
.global main
  
.data

counter: .word 0
    
.text

.ent main
main:

    DI	# disables all interrupts
    
    jal setupLEDs
    
    # Turn on multi-vector mode to support multiple interrupt requests
    # INTCON<12> = 1
    LI $t0, 1 << 12
    SW $t0, INTCONSET
    
    # setup all interrupts    
    jal setupExtInt3
    jal setupExtInt4
    
    EI	# re-enable all interrupts
    
    loop:
	LW $a0, counter
	jal setLEDs
	LI $a0, 1000
	jal delayms
	LW $t0, counter
	ADDI $t0, $t0, 1
	SW $t0, counter
	
    j loop
    
.end main

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
    SW $t0, IPC3CLR	    # Clear out any priority given to ext int 3 previously
    
    LI $t0, 0b10000 << 24   # sets priority to 0b100, sub-priority to 0b00
    SW $t0, IPC3SET
    
    LI $t0, 1 << 15
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
    
    JR $ra
.end setupExtInt3
    
.ent setupExtInt4
setupExtInt4:
    
    LI $t0, 1 << 15
    SW $t0, TRISASET
    
    # Sets the polarity of the interrupt (1 triggers on positive clock edge) 
    # look up the pin in Section 8: Interrupts
    LI $t0, 0b10000
    SW $t0, INTCONSET
    
    # Set Priority of ext interrupt 3
    # Priority = 4; Sub-Priority = 0;
    # IPC4<28:26> = 3; IPC4<25:24> = 0
    LI $t0, 0b11111 << 24
    SW $t0, IPC4CLR	    # Clear out any priority given to ext int 4 previously
    
    LI $t0, 0b1100 << 24   # sets priority to 0b11, sub-priority to 0b00
    SW $t0, IPC3SET
    
    
    
    
    
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
    
.ent extInt3Handler
extInt3Handler:
    DI # disable global interrupts - don't want an interrupt to interrupt this interrupt
    
    ADDI $sp, $sp, -4	# Using t0, make sure to preserve it
    SW $t0, 0($sp)
    
    LW $t0, counter
    ADDI $t0, $t0, 1
    SW $t0, counter
    
    # Clear the interrupt flag
    LI $t0, 1 << 15
    
    SW $t0, IFS0CLR # Clears the interrupt flag
    
    LW $t0, 0($sp)
    ADDI $sp, $sp, 4
    
    EI	    # re-enable global interrupts
    ERET    # exception return, set PC = EPC    
.end extInt3Handler
   
    
# Hook to external interrupt 4 handler
.section .vector_19, code
j extInt4Handler
    
.ent extInt4Handler
extInt4Handler:
    
    DI # disable global interrupts - don't want an interrupt to interrupt this interrupt
    
    ADDI $sp, $sp, -4	# Using t0, make sure to preserve it
    SW $t0, 0($sp)
    
    LW $t0, counter
    ADDI $t0, $t0, 1
    SW $t0, counter
    
    # Clear the interrupt flag
    LI $t0, 1 << 19
    
    SW $t0, IFS0CLR # Clears the interrupt flag
    
    LW $t0, 0($sp)
    ADDI $sp, $sp, 4
    
    EI	    # re-enable global interrupts
    ERET    # exception return, set PC = EPC
    
.end extInt4Handler
    
.text
    
# ? TimerY provides the interrupt enable, interrupt flag and interrupt priority control bits 
    # the external interrupts will just shift the value of the period register left or right by 2 to
    # double or halve the timer and store the value back to the period register. .
    # in the case of timers 2 and 3 being paired, timer 3 provides the interrupt flag and interrupt priority