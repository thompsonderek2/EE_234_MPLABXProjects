.include "RoboMAL.s"
.include "LED.s"
.include "Buttons.s"
.include "outputCompare.s"
.include "timer.s"
    
    
.global main
    
.data
    
.text
    
.ent main
main:
    DI	# disables all interrupts
    
    jal setupLEDs
    jal setupButtons
    jal setupTMR2
    jal startTMR2
    jal setupOC1
    jal setupOC3
    
    LI $t0, 1 << 12
    SW $t0, INTCONSET
    
    jal setupTMR1
    
    EI	# re-enable all interrupts
    
    loop:
     	jal getButtons
 	beq $v0, 0b001, btn1pressed
 	
 	nobtnpressed:
 	    j waitfordepressed
 	    
 	btn1pressed:
	    jal runProgram
 	   
	 
 	waitfordepressed:
 	    jal getButtons
 	    
  	    beqz $v0, loop
 	    j waitfordepressed
	
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
    



