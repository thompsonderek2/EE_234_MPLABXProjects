.include "RoboMAL.s"
.include "LED.s"
.include "Buttons.s"
.include "outputCompare.s"
.include "timer.s"
    
    
.global main
    
.data
 
counter: .word 0


    
.text
    
.ent main
main:
    
    jal setupLEDs
    jal setupButtons
    jal setupTMR1
    jal setupTMR32
    jal setupOC1
    jal setupOC3
    
    loop:
	 jal runProgram

	
    j loop

.end main


    
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
      
    countup:
    LW $t0, counter
    ADDI $t0, $t0, 1
    SW $t0, counter
    
    # Clear the interrupt flag in bit IFS0<12>
    LI $t0, 1 << 12
    SW $t0, IFS0CLR 
    
    LW $t1, 4($sp)
    LW $t0, 0($sp)
    ADDI $sp, $sp, 8
    
    EI
    ERET
    
.end tmr3Handler
