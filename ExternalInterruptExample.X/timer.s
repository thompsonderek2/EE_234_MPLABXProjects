.ifndef TIMER_S
#  insert guard code here
    
.data
msFlag: .word 0
 
.text
    # Timer1
    # Timer 1 interrupt registers
# Flag - IFS0<4>
# Enable - IEC0<4>
# Priority - IPC1<4:2>
# Sub-Priority - IPC1<1:0>
    # timer 1 registers
# TMR1CON; TMR1; PR1   
.ent setupTMR1
setupTMR1:
    # Disable the timer
    SW $zero, T1CON
    
    # set input clk to PBCLK - T1CON<1> = 0; (already done)
    # period register = (timer frequency)*N = (fPBCLK/prescaler)*N; (1/N)seconds = ftimer/N
    # PR counts in whole numbers, depending on resolution choose prescaler
    # that will give whole number
    
    # prescaler of 64 - set T1CON<5:4> = 0b10
    LI $t0, 0b100000
    SW $t0, T1CONSET
    
    # clear timer count register
    SW $zero, TMR1
    
    LI $t0, 625
    SW $t0, PR1
    
    # Set Priority of ext interrupt 3
    # Priority = ; Sub-Priority = 0;
    # IPC1<4:2> = 5; IPC1<1:0> = 1 
    LI $t0, 0b11111
    SW $t0, IPC3CLR	    # Clear out any priority given to ext int 3 previously
    
    LI $t0, 0b10101    # sets priority to 0b101, sub-priority to 0b01
    SW $t0, IPC3SET
    
    LI $t0, 1 << 4
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious interrupt)
    
    JR $ra
.end setupExtInt3

.ent delayms
    delayms:
    ADDi $s0, $s0, -1 # copy from 
    
    MOVE $s0, $a0
    
    # turn on timer 1 - T1CON<15> = 1
    LI $t0, 1 << 15
    SW $t0, TICONSET
    
    delaymsLoop:
    sw $zero, msFlag
    waitloop:
	LW $t0, msFlag
	beq $t0, 1, endwaitloop
    j waitloop
    endwaitloop:
    
    ADDI $s0, $s0, -1
    BEQZ $s0, enddelaymsLoop
    j delaymsLoop
    enddelaymsLoop:
    
    # turn off timer 1 - T1CON<15> = 0
    jr $ra
.end delayms
