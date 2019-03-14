.ifndef TIMER_S
TIMER_S:
    
.data
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

# set up timers 2 and 3 as a type B combined 32 bit timer (page 175 of PIC32MX5XX/6XX/7XX Family Data Sheet)
    
# ? TimerY provides the interrupt enable, interrupt flag and interrupt priority control bits 
    # the external interrupts will just shift the value of the period register left or right by 2 to
    # double or halve the timer and store the value back to the period register. .
    # in the case of timers 2 and 3 being paired, timer 3 provides the interrupt flag and interrupt priority
    
.ent setupTMR32
    setupTMR32:
    # Disable timers 2 and 3
    SW $zero, T2CON   
    SW $zero, T3CON
    
    # TxCON is the timer control register
    # Configures timers 2&3 as 32-bit timer: T2CON<3> = 1
    # Set input clk to PBCLK - T2CON<1> = 0; (already done)
    # Prescaler of 64 - Set T2CON<6:4> (TCKPS<2:0>) = 0b1100000
    LI $t0, 0b1101000
    SW $t0, T2CONSET
    
    # clear the timer
    SW $zero, TMR2
    SW $zero, TMR3
    
    # set the timer count value;
    # PR = (f_PBCLK / prescaler) * t
    # (40MHz / 64) * 1s = 652 5000 = 0x9 8968 = 0b1001 1000 1001 0110 1000
    SW $zero, PR2
    # SW $zero, PR3
    LI $t0, 0x98969
    SW $t0, PR2
    # LI $t0, 0x9
    # SW $t0, PR3
    
    # ? TimerY provides the interrupt enable, interrupt flag and interrupt priority control bits
    # Set Priority of Timer 3
    # Priority = 5; Sub-Priority = 1;
    # IPC2<4:2> = 5; IPC2<1:0> = 1 
    LI $t0, 0b11111
    SW $t0, IPC3CLR   # Clear out any priority given to timer3 previously
    
    LI $t0, 0b10100   # sets priority to 0b101, sub-priority to 0b01
    SW $t0, IPC3SET
    
    LI $t0, 1 << 12
    SW $t0, IEC0SET # Enable the interrupt
		    # T2IE: Interrupt Enable Control bit in IEC0 interrupt register
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
		    # T2IF: Interrupt Flag Status bit in IFS0 interrupt register
    JR $ra
.end setupTMR32
    
# Specific behavior in 32-bit Timer mode:
# ? TimerX is the master timer; TimerY is the slave timer
# ? TMRx count register is least significant half word of the 32-bit timer value
# ? TMRy count register is most significant half word of the 32-bit timer value
# ? PRx period register is least significant half word of the 32-bit period value
# ? PRy period register is most significant half word of the 32-bit period value
# ? TimerX control bits (TxCON) configure the operation for the 32-bit timer pair
# ? TimerY control bits (TyCON) have no effect
# ? TimerX interrupt and status bits are ignored
# ? TimerY provides the interrupt enable, interrupt flag and interrupt priority control bits
#     
    
    
    
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
    


