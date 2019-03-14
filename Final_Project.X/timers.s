.ifndef TIMER_S
TIMER_S:
    # included for feedBack function
    .include "outputCompare.s"
    .include "inputCapture.s"
    
.data
counter: .word 0
msFlag: .word 0

.text     
# Timer1
# Timer 1 Registers
# TMR1CON; TMR1; PR1
# Timer 1 Interrupt Registers
# Flag - IFS0<4>; Enable - IEC0<4>;
# Priority - IPC1<4:2>; Sub-Priority - IPC1<1:0>

.ent setupTMR1
setupTMR1:
    # Disable the timer
    SW $zero, T1CON
    
    # Set input clk to PBCLK - T1CON<1> = 0; (already done)
    # Prescaler of 64 - Set T1CON<5:4> = 0b10
    LI $t0, 0b100000
    SW $t0, T1CONSET
    
    # clear the timer
    SW $zero, TMR1
    
    # set the timer count value;
    # PR = (f_PBCLK / prescaler) * t
    # (40MHz / 64) * 1ms = 650
    LI $t0, 650
    SW $t0, PR1
    
    # Set Priority of Timer 1
    # Priority = 5; Sub-Priority = 0;
    # IPC1<4:2> = 5; IPC1<1:0> = 0 
    LI $t0, 0b11111
    SW $t0, IPC1CLR   # Clear out any priority given to timer1 previously
    
    LI $t0, 0b11000   # sets priority to 0b110, sub-priority to 0b00
    SW $t0, IPC1SET
    
    LI $t0, 1 << 4
    SW $t0, IEC0SET # Enable the interrupt: 
		    # T1IE: Interrupt Enable Control bit in IEC0 interrupt register
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
		    # T1IF: Interrupt Flag Status bit in IFS0 interrupt register
    
    JR $ra
.end setupTMR1

# Timer2
# Timer 2 Registers
# T2CON; TMR2; PR2

.ent setupTMR2
setupTMR2:
    # Disable the timer
    SW $zero, T2CON
    
    # Set input clk to PBCLK - T2CON<1> = 0; (already done)
    # Set input clk as 16-bit timer - T2CON<3> = 0; (already done)
    # Prescaler of 8 - Set T2CON<6:4> = 0b011
    LI $t0, 0b011 << 4
    SW $t0, T2CONSET
    
    # clear the timer
    SW $zero, TMR2
    
    # set the timer count value;
    # setting up the PWM frequency:
    # f_PWM = f_PBCLK / (prescaler * (PR2 + 1))
    # f_PWM * (prescaler * (PR2 + 1)) = f_PBCLK
    # (f_PBCLK / f_PWM) = prescaler * (PR2 + 1)
    # (f_PBCLK / f_PWM)*(1/prescaler) - 1 = PR2
    LI $t0, 249 # with a prescaler of 8 and PR2 of 249, f_PWM = 20kHz
    SW $t0, PR2
      
        # Set Priority of Timer 2
    # Priority = 6; Sub-Priority = 1;
    # IPC1<4:2> = 5; IPC1<1:0> = 1 
    LI $t0, 0b11111
    SW $t0, IPC2CLR   # Clear out any priority given to timer2 previously
    
    LI $t0, 0b11001   # sets priority to 0b110, sub-priority to 0b01
    SW $t0, IPC2SET
    
#     LI $t0, 1 << 8
#     SW $t0, IEC0SET # Enable the interrupt: 
# 		    # T1IE: Interrupt Enable Control bit in IEC0 interrupt register
#     SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
# 		    # T1IF: Interrupt Flag Status bit in IFS0 interrupt register
    	    
    JR $ra
.end setupTMR2

.ent startTMR2
startTMR2:
    LI $t0, 1 << 15
    SW $t0, T2CONSET
    
    JR $ra    
.end startTMR2
    
    
.ent setupTMR3
setupTMR3:
    # Disable the timer
    SW $zero, T3CON
    
    # Set input clk to PBCLK - T2CON<1> = 0; (already done)
    # Set input clk as 16-bit timer - T2CON<3> = 0; (already done)
    # Prescaler of 8 - Set T2CON<6:4> = 0b011
    LI $t0, 0b011 << 4
    SW $t0, T3CONSET
    
    # clear the timer
    SW $zero, TMR3
    
    # set the timer count value;
    # PR = (f_PBCLK / prescaler) * t
    # MAX OUT PR to limit the number of turnover
    LI $t0, 0xFFFF
    SW $t0, PR3
      
        # Set Priority of Timer 2
    # Priority = 6; Sub-Priority = 0;
    # IPC1<4:2> = 6; IPC1<1:0> = 1 
    LI $t0, 0b11111
    SW $t0, IPC3CLR   # Clear out any priority given to timer1 previously
    
    LI $t0, 0b11010   # sets priority to 0b110, sub-priority to 0b10
    SW $t0, IPC3SET
    
#     LI $t0, 1 << 12
#     SW $t0, IEC0SET # Enable the interrupt: 
# 		    # T1IE: Interrupt Enable Control bit in IEC0 interrupt register
#     SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
# 		    # T1IF: Interrupt Flag Status bit in IFS0 interrupt register
    	    
    JR $ra
.end setupTMR3

.ent startTMR3
startTMR3:
    LI $t0, 1 << 15
    SW $t0, T3CONSET
    
    JR $ra    
.end startTMR3
    
# a0 = number of ms to delay
.ent delayms
delayms:
    ADDI $sp, $sp, -8
    SW $s0, 0($sp)
    SW $s1, 4($sp)
    SW $ra, 8($sp)
    
    MOVE $s0, $a0
    MOVE $s1, $a0
    SRL $s1, $s1, 4
    # turn on timer 1 - T1CON<15> = 1
    LI $t0, 1 << 15
    SW $t0, T1CONSET
     
    # turn on IC3 

    LI $t0, 1 << 15
    SW $t0, IC3CONSET
    
    # turn on IC5
    LI $t0, 1 << 15

     LI $t0, 1 << 15
    SW $t0, IC3CONSET
    
    # turn on IC5
     LI $t0, 1 << 15

    SW $t0, IC5CONSET
    
    delaymsLoop:
	SW $zero, msFlag
	waitLoop:
	    LW $t0, msFlag
	    BNEZ $t0, endwaitLoop
	    jal feedBack
	j waitLoop
	endwaitLoop:
	ADDI $s0, $s0, -1
	# call feedBack function for IC after .25 sec delay
	ADDI $s1, $s1, -1
	BNEZ $s1, skipfeedBack
# 	jal feedBack3
# 	jal feedBack5
# jal feedBack
	skipfeedBack:
    
	BEQZ $s0, enddelaymsLoop
	j delaymsLoop
    enddelaymsLoop:
    
    # turn off timer 1 - T1CON<15> = 0
    LI $t0, 1 << 15
    SW $t0, T1CONCLR
    
    # turn off IC3 
     LI $t0, 1 << 15
    SW $t0, IC3CONCLR
    
    # turn off IC5
     LI $t0, 1 << 15
    SW $t0, IC5CONCLR
    
    
    sW $zero, IC_counter1
    sW $zero, IC_counter2
    
    LW $s0, 0($sp)
    LW $s1, 4($sp)
    LW $ra, 8($sp)
    ADDI $sp, $sp, 8
    
    jr $ra   
.end delayms 
    

# .ent feedBack3 
# feedBack3:
#     ADDI $sp, $sp, -12
#     SW $t0, 0($sp)
#     SW $t1, 4($sp)
#     SW $t2, 8($sp)
# 
#     
#     
# 	LW $t1, IC_buffread1
# 	LW $t2, IC_buffread2
# 	subu $t2, $t2, $t1
# 	# guess for number of timer2 cycles between capture events
# 	LI $t0, 20
#  	BEQ $t0, $t2, endFeedback3
#  	# BEQz $t2, skipfeedBack
# 	
# 	SUB $t2, $t0, $t2
# 	
# 	BLTZ $t2, reduce_OC1RS
# 	BGTZ $t2, increase_OC1RS
# 
# 	increase_OC1RS:
# 	LI $t1, 250 # 100% PWM duty cycle
# 	LW $t0, OC1RS
# 	SUB $t1, $t1, $t2
# 	beqz $t1, endFeedback3
# 	ADDI $t0, $t0, 10
# 	SW $t0, OC1RS
# 	j endFeedback3
# 
# 	reduce_OC1RS:
# 	LW $t0, OC1RS
# 	beqz $t1, endFeedback3
# 	ADDI $t0, $t0, -10
# 	SW $t0, OC1RS
# 	j endFeedback3
# 
#     endFeedback3:
#     
#     LW $t2, IC_buffread1
#     SW $t2, IC_buffread2
#     
#     LW $t0, 0($sp)
#     LW $t1, 4($sp)
#     LW $t2, 8($sp)
#     ADDI $sp, $sp, 12
#     
#     jr $ra
# .end feedBack3
#     
# .ent feedBack5 
# feedBack5:
#     ADDI $sp, $sp, -12
#     SW $t0, 0($sp)
#     SW $t1, 4($sp)
#     SW $t2, 8($sp)
#     
# 	LW $t1, IC_buffread3
# 	LW $t2, IC_buffread4
# 	subu $t2, $t2, $t1
# 	# guess for number of timer2 cycles between capture events
# 	LI $t0, 20
# 	BEQ $t0, $t2, endFeedback5
# 	# BEQz $t2, skipfeedBack
# 	
# 	SUB $t2, $t0, $t2
# 	
# 	BLTZ $t2, reduce_OC3RS
# 	BGTZ $t2, increase_OC3RS
# 
# 	increase_OC3RS:
# 	LI $t1, 250 # 100% PWM duty cycle
# 	LW $t0, OC3RS
# 	SUB $t1, $t1, $t2
# 	beqz $t1, endFeedback5
# 	ADDI $t0, $t0, 10
# 	SW $t0, OC3RS
# 	j endFeedback5
# 
# 	reduce_OC3RS:
# 	LW $t0, OC3RS
# 	beqz $t1, endFeedback5
# 	ADDI $t0, $t0, -10
# 	SW $t0, OC3RS
# 	j endFeedback5
# 
#     endFeedback5:
#     
#     LW $t2, IC_buffread3
#     SW $t2, IC_buffread4
#     
#     LW $t0, 0($sp)
#     LW $t1, 4($sp)
#     LW $t2, 8($sp)
#     ADDI $sp, $sp, 12
#     
#     jr $ra
# .end feedBack5
    
.ent feedBack 
feedBack:
    ADDI $sp, $sp, -12
    SW $t0, 0($sp)
    SW $t1, 4($sp)
    SW $t2, 8($sp)
    
    
	LW $t0, IC_buffread1
	LW $t1, IC_buffread2
	subu $t0, $t1, $t0
	# guess for number of timer2 cycles between capture events
	LW $t1, IC_buffread3
	LW $t2, IC_buffread4
	subu $t1, $t2, $t1
	
	sub $t2, $t1, $t0
	
	beq $t1, $t0, endFeedback
	BlTZ $t2, reduce_OC3RS
	BgTZ $t2, reduce_OC1RS
	
	increase_OC1RS:
	LI $t1, 250 # 100% PWM duty cycle
	LW $t0, OC1RS
	SUB $t1, $t1, $t2
	beqz $t1, endFeedback
	ADDI $t0, $t0, 10
	SW $t0, OC1RS
	j endFeedback

	reduce_OC1RS:
	LW $t0, OC1RS
	beqz $t1, endFeedback
	ADDI $t0, $t0, -10
	SW $t0, OC1RS
	LI $t1, 250 # 100% PWM duty cycle
	LW $t0, OC3RS
	SUB $t1, $t1, $t2
	beqz $t1, endFeedback
	ADDI $t0, $t0, 10
	SW $t0, OC3RS
	j endFeedback

	increase_OC3RS:
	LI $t1, 250 # 100% PWM duty cycle
	LW $t0, OC3RS
	SUB $t1, $t1, $t2
	beqz $t1, endFeedback
	ADDI $t0, $t0, 10
	SW $t0, OC3RS
	j endFeedback

	reduce_OC3RS:
	LW $t0, OC3RS
	beqz $t1, endFeedback
	ADDI $t0, $t0, -50
	SW $t0, OC3RS
	LI $t1, 250 # 100% PWM duty cycle
	LW $t0, OC1RS
	SUB $t1, $t1, $t2
	beqz $t1, endFeedback
	ADDI $t0, $t0, 50
	SW $t0, OC1RS
	j endFeedback

    endFeedback:
    
    LW $t2, IC_buffread1
    SW $t2, IC_buffread2
    LW $t2, IC_buffread3
    SW $t2, IC_buffread4
    
    LW $t0, 0($sp)
    LW $t1, 4($sp)
    LW $t2, 8($sp)
    ADDI $sp, $sp, 12
    
    jr $ra
.end feedBack
    
    
.endif
