.ifndef TIMER_S
TIMER_S:
    
.data
msFlag: .word 0

.text     
# Timer1
# Timer 1 Registers
# T1CON; TMR1; PR1
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
    # Priority = 5; Sub-Priority = 1;
    # IPC1<4:2> = 5; IPC1<1:0> = 1 
    LI $t0, 0b11111
    SW $t0, IPC1CLR   # Clear out any priority given to timer1 previously
    
    LI $t0, 0b10101   # sets priority to 0b101, sub-priority to 0b01
    SW $t0, IPC1SET
    
    LI $t0, 1 << 4
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
    
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
    # Prescaler of 64 - Set T2CON<6:4> = 0b110
    LI $t0, 0b110 << 4
    SW $t0, T2CONSET
    
    # clear the timer
    SW $zero, TMR2
    
    # set the timer count value;
    # setting up the PWM frequency:
    # f_PWM = f_PBCLK / (prescaler * (PR2 + 1))
    # f_PWM * (prescaler * (PR2 + 1)) = f_PBCLK
    # (f_PBCLK / f_PWM) = prescaler * (PR2 + 1)
    # (f_PBCLK / f_PWM)*(1/prescaler) - 1 = PR2
    # (40MHz / 20kHz) * (1/8) - 1 = 249
    LI $t0, 650 # with a prescaler of 8 and PR2 of 499, f_PWM = 20kHz
    SW $t0, PR2
      
        # Set Priority of Timer 2
    # Priority = 5; Sub-Priority = 0;
    # IPC1<4:2> = 5; IPC1<1:0> = 1 
    LI $t0, 0b11111
    SW $t0, IPC1CLR   # Clear out any priority given to timer1 previously
    
    LI $t0, 0b11001   # sets priority to 0b110, sub-priority to 0b01
    SW $t0, IPC1SET
    
    LI $t0, 1 << 8
    SW $t0, IEC0SET # Enable the interrupt: 
		    # T1IE: Interrupt Enable Control bit in IEC0 interrupt register
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
		    # T1IF: Interrupt Flag Status bit in IFS0 interrupt register
    	    
      
    JR $ra
.end setupTMR2

.ent startTMR2
startTMR2:
    LI $t0, 1 << 15
    SW $t0, T2CONSET
    
    JR $ra    
.end startTMR2
    
# Timer3
# Timer 3 Registers
# T3CON; TMR3; PR3

.ent setupTMR3
setupTMR3:
    # Disable the timer
    SW $zero, T3CON
    
    # Set input clk to PBCLK - T3CON<1> = 0; (already done)
    # Set input clk as 16-bit timer - T3CON<3> = 0; (already done)
    # Prescaler of 256 - Set T3CON<6:4> = 0b110
    LI $t0, 0b111 << 4
    SW $t0, T3CONSET
    
    # clear the timer
    SW $zero, TMR3
    
    # set the timer count value;
    # setting up the PWM frequency:
    # f_PWM = f_PBCLK / (prescaler * (PR2 + 1))
    # f_PWM * (prescaler * (PR2 + 1)) = f_PBCLK
    # (f_PBCLK / f_PWM) = prescaler * (PR2 + 1)
    # (f_PBCLK / f_PWM)*(1/prescaler) - 1 = PR2
    # (40MHz / 20kHz) * (1/8) - 1 = 249
    LI $t0, 0xFFFF # with a prescaler of 8 and PR2 of 499, f_PWM = 20kHz
    SW $t0, PR3
      
        # Set Priority of Timer 3
    # Priority = 2; Sub-Priority = 2;
    # IPC1<4:2> = 2; IPC1<1:0> = 2 
    LI $t0, 0b11111
    SW $t0, IPC1CLR   # Clear out any priority given to timer1 previously
    
    LI $t0, 0b01010   # sets priority to 0b110, sub-priority to 0b10
    SW $t0, IPC1SET
    
    LI $t0, 1 << 12
    SW $t0, IEC0SET # Enable the interrupt: 
		    # T1IE: Interrupt Enable Control bit in IEC0 interrupt register
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
		    # T1IF: Interrupt Flag Status bit in IFS0 interrupt register
    	    
      
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
    ADDI $sp, $sp, -4
    SW $s0, 0($sp)
    
    MOVE $s0, $a0
    
    # turn on timer 1 - T1CON<15> = 1
    LI $t0, 1 << 15
    SW $t0, T1CONSET
    
    delaymsLoop:
	SW $zero, msFlag
	waitLoop:
	    LW $t0, msFlag
	    BNEZ $t0, endwaitLoop
	j waitLoop
	endwaitLoop:
	ADDI $s0, $s0, -1
	BEQZ $s0, enddelaymsLoop
	j delaymsLoop
    enddelaymsLoop:
    
    # turn off timer 1 - T1CON<15> = 0
    LI $t0, 1 << 15
    SW $t0, T1CONCLR
    
    LW $s0, 0($sp)
    ADDI $sp, $sp, 4
    
    jr $ra   
.end delayms

.endif
    





