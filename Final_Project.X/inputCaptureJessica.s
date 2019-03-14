

.ifndef INPUTCAPTURE_S
    INPUTCAPTURE_S:

#     .include "timers.s"
#     
.data
  clockValue1: .word 0
  clockValue3: .word 0
 
  inputCapture3Iterator: .word 0
 
  inputCapture5Iterator: .word 0
 
.text 
.ent setupIC3
    setupIC3:
    # JD04 - RD10
    # IC3CON IC3BUF
    
    # Setting feeback pin as input
    LI $t0, 0b10000000000
    SW $t0, TRISDSET
    SW $t0, LATDCLR
    
    # Clear all associated hardware registers
    SW $zero, IC3CON
    SW $zero, IC3BUF
    
    # Set Priority interrupt
    # Priority = 4; Sub-Priority = 0;
    # IPC3<12:10> = 1; IPC3<9:8> = 0 
    LI $t0, 0b11111 << 8
    SW $t0, IPC3CLR	    # Clear out any priority given previously
    
    LI $t0, 0b10000 << 8  # sets priority to 0b001, sub-priority to 0b00
    SW $t0, IPC3SET
    
    # IC3CON<15> = 0 (turn off the input capture module)
    # IC3CON<8> = 0 (setting the input capture as a 16-bit value)
    # IC3CON<7> = 0 (set timer 3 )
    # IC3CON<2:0> = 0b001 
    
    
    LI $t3, 0b0000000010000001
    SW $t3, IC3CONSET
    
    LI $t0, 1 << 13
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
    
    JR $ra
.end setupIC3

    
.ent setupIC5
    setupIC5:
     # JD10 - RD12
    # Setting feedback pin as input
    LI $t0, 0b1000000000000
    SW $t0, TRISDSET
    
    # Clear all associated hardware registers
    SW $zero, IC5CON
    SW $zero, IC5BUF
    
    # Set Priority interrupt
    # Priority = 4; Sub-Priority = 1;
    # IPC5<12:10> = 1; IPC5<9:8> = 1 
    LI $t0, 0b11111 << 8
    SW $t0, IPC5CLR	  # Clear out any priority given previously
    
    LI $t0, 0b10001 << 8  # sets priority to 0b001, sub-priority to 0b01
    SW $t0, IPC5SET
    
    # IC5CON<15> = 0 (turn on the output compare module)
    # IC5CON<8> = 0 (setting the input capture as a 16-bit value)
    # IC5CON<7> = 0 (set timer 3 )
    # IC5CON<2:0> = 0b000 (setup to be off originally)
     LI $t3, 0b0000000010000001
    SW $t3, IC5CONSET
    
    LI $t0, 1 << 21
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
    
    JR $ra
.end setupIC5

.ent readIC3
    readIC3:
    LW $v0, IC3BUF
    JR $ra
.end readIC3
    
.ent readIC5
    readIC5:
    LW $v0, IC5BUF
    JR $ra
.end readIC5
    
.ent feedback3
    feedback3:
    ADDI $sp, $sp, -4  # pushed ra onto the stack to preserve it
    SW $ra, 0($sp)
    
LI $t3, 0b1000000000000000
    SW $t3, IC3CONSET
    
    
#     beginfeedback3loop:
    # stay in loop until interrupt calculation is done
# 	    LW $t2, clockValue3
# 	    BNEZ $t2, endfeedback3loop   # t2 will be last clock taken
# 	    LI $a0, 2000
# 	    jal delayms
	    LI $a0, 4000
 	jal delayRobo
	
# 	LI $t0, 0b1000000000000000  # turn off interrupts
# 	 SW $t0, IC3CONCLR
	 
	LW $v0, inputCapture3Iterator   # take counter amount and make it output
	MOVE $t0, $zero
	SW $t0, inputCapture3Iterator
	
	LI $t3, 0b1000000000000000
    SW $t3, IC3CONCLR
    
# 	j beginfeedback3loop
# 
#     endfeedback3loop:
#    LI $t3, 0b11
#    SW $t3, IC3CONCLR
#     
#     LI $t3, 0b111
#     SW $t3, IC3CONCLR  # turn off interrupt sensor
#     
   
#     
#     LW $t0, clockValue1
# #   LW $t1, clockValue2
#     LW $t2, clockValue3
#     
#    # Period T = .00401606/ frequency 20,000 Hz
#    SUB $t0, $t2, $t0   # difference of two clock cycles
#    LI $t1, 20000    # frequency 20000 Hz
#    
#     DIV $t0, $t0, $t1   # difference diveded by 20,000 Hz
#     MFLO $v0          # get result of rotations
#    
#     
#     
#     MOVE $t0, $zero
#     SW $t0, clockValue1    # set escape feedback to 0
# #   SW $t0, clockValue2    # set escape feedback to 0
#     SW $t0, clockValue3    # set escape feedback to 0
#     
	LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    
    JR $ra
    
.end feedback3
    
    .ent feedback5
    feedback5:
    
    ADDI $sp, $sp, -4  # pushed ra onto the stack to preserve it
    SW $ra, 0($sp)
    
#     jal startTMR3
LI $t3, 0b1000000000000000
    SW $t3, IC5CONSET
    
    
	LI $a0, 4000
 	jal delayRobo
	
# 	LI $t0, 0b1000000000000000  # turn off interrupts
# 	 SW $t0, IC5CONCLR
	 
	LW $v0, inputCapture5Iterator   # take counter amount and make it output
	MOVE $t0, $zero
	SW $t0, inputCapture5Iterator
	
	LI $t3, 0b1000000000000000
    SW $t3, IC5CONCLR
    
    
#     LI $t3, 0b1        # end timer
#     SW $t3, IC5CONCLR
    
#     LI $t3, 0b111
#     SW $t3, IC5CONCLR  # turn off interrupt sensor
    
#     LW $t0, clockValue1
# #   LW $t1, clockValue2
#     LW $t2, clockValue3
#     
#    # Period T = .00401606/ frequency 20,000 Hz
#    SUB $t0, $t2, $t0   # difference of two clock cycles
#    LI $t1, 20000    # frequency 20000 Hz
#    
#     DIV $t0, $t0, $t1   # difference diveded by 20,000 Hz
#     MFLO $v0          # get result of rotations
#    
#     
#     
#     MOVE $t0, $zero
#     SW $t0, clockValue1    # set escape feedback to 0
# #   SW $t0, clockValue2    # set escape feedback to 0
#     SW $t0, clockValue3    # set escape feedback to 0
    
	LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    
    JR $ra
    
.end feedback5
    
    .ent delayRobo
    
    
	delayRobo:
	MOVE $t5, $zero
	delayloopRobo:
	ADDI $t5, $t5, 1
	BNE $t5, $a0, delayloopRobo
	
	JR $ra
	
.end delayRobo


.endif





