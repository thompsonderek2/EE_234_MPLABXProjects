


.include "timer.s"
.include "outputCompare.s"
.include "buttons.s"
        
.global main
    
.text
    
    
.ent main
main:
    DI	# disables all interrupts
       
    jal setupButtons
    jal setupOC1
    jal setupOC3
    jal setupTMR2
    jal startTMR2
    
    # Turn on multi-vector mode to support multiple interrupt requests
    # INTCON<12> = 1
    LI $t0, 1 << 12
    SW $t0, INTCONSET
    
    jal setupTMR1
    
    EI	# re-enable all interrupts
    
    loop:
    
# 	jal getButtons
# 	beq $v0, 0b001, btn1pressed
# 	beq $v0, 0b010, btn2pressed
# 	beq $v0, 0b011, btn12pressed
# 	
# 	nobtnpressed:
# 	    j waitfordepressed
# 	    
# 	btn1pressed:
# 	    # increment duty cycle by 10%
# 	    # duty cycle % = OC1RS / (PR + 1)
# 	    # OC1RS = (duty cycle %) * (PR + 1)
# 	    # OC1RS = 5% * (249 + 1)
# 	    LW $t0, OC1RS
# 	    ADDI $t0, $t0, -25
# 	    SW $t0, OC1RS
# 	    
# 	    LW $t0, OC3RS
# 	    ADDI $t0, $t0, -25
# 	    SW $t0, OC3RS
# 	    j waitfordepressed
# 	btn2pressed:
# 	    # decrement duty cycle by 10%
# 	    # duty cycle % = OC1RS / (PR + 1)
# 	    # OC1RS = (duty cycle %) * (PR + 1)
# 	    # OC1RS = 5% * (249 + 1)
# 	    LW $t0, OC1RS
# 	    ADDI $t0, $t0, 25
# 	    SW $t0, OC1RS
# 	    
# 	    LW $t0, OC3RS
# 	    ADDI $t0, $t0, 25
# 	    SW $t0, OC3RS
# 	    
# 	    j waitfordepressed
# 	btn12pressed:
# 	    # stop the motor
# 	    SW $zero, OC1RS
# 	    SW $zero, OC3RS
# 	    j waitfordepressed
# 	waitfordepressed:
# 	    jal getButtons
# 	    beq $v0, 0b011, btn12pressed
#  	    beqz $v0, loop
# 	    j waitfordepressed
# 		
#         SW $zero, counter # clear counter in timer.s to 0
#     
# # the H-bridge module will have JD-07 (RD01) be the dir pin
#     LI $t0, 0b10
#     SW $t0, LATDSET 
# # the H-bridge module will have JD-01 (RD09) be the dir pin
#     LI $t0, 0b1000000000
#     SW $t0, LATDCLR

    # Set motors to go
    LW $t0, OC1RS
    ADDI $t0, $t0, 1000
    SW $t0, OC1RS

#     LW $t0, OC3RS
#     ADDI $t0, $t0, 25
#     SW $t0, OC3RS
    
 #   wait for 2 seconds
    	LI $a0, 1000
	jal delayms
    
     LW $t0, OC1RS
     ADDI $t0, $t0, -1000
     SW $t0, OC1RS
     
	LI $a0, 1000
	jal delayms
    
# 
#     LW $t0, OC3RS
#     ADDI $t0, $t0, -25
#     SW $t0, OC3RS
    
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
    