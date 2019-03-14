 .ifndef INPUTCAPTURE_S
 INPUTCAPTURE_S:
.data
    IC_counter1: .word 0
    IC_counter2: .word 0
    # store buffer values for IC3
    IC_buffread1: .word 0
    IC_buffread2: .word 0
    # store buffer values for IC5
    IC_buffread3: .word 0
    IC_buffread4: .word 0
    IC3_flag: .word 0
    IC5_flag: .word 0
.text
 
 .ent setupIC3
    setupIC3:
    # JD04 - RD10 as output
    # Setting feeback pin as input
    LI $t0, 0b10000000000
    SW $t0, TRISDSET
    SW $t0, LATDCLR
    
    # IC3CON IC3BUF
    # Clear all associated hardware registers
    SW $zero, IC3CON
    SW $zero, IC3BUF
    
    # Set Priority interrupt
    # Priority = 4; Sub-Priority = 0;
    # IPC3<12:10> = 110; IPC3<9:8> = 00 
    # Clear out any priority given previously
    LI $t0, 0b11111 << 8
    SW $t0, IPC3CLR	    

    # sets int priority to 0b110, sub-priority to 0b00
    LI $t0, 0b11000 << 8  
    SW $t0, IPC3SET
    
    # IC3CON<15> = 0 (turn on the output compare module)
    # IC3CON<9> = 1 (capture rising edge first)
    # IC3CON<8> = 0 (setting the input capture as a 16-bit value)
    # IC3CON<7> = 0 (set timer 3 )
    # IC3CON<6:5> = 00 (interrupt every on every capture event)
    # IC3CON<2:0> = 101 (capture every 16th rising edge)
    LI $t3, 0b0000001000000001
    SW $t3, IC3CONSET
    
    # #    Enable Input Capture ICxCON <15> =1
    # LI $t0, 1 << 15
    # SW $t0, IC3CONSET
    
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
    # Priority = 6; Sub-Priority = 1;
    # IPC5<12:10> = 110; IPC5<9:8> = 01 
    # Clear out any priority given previously
    LI $t0, 0b11111 << 8
    SW $t0, IPC5CLR	  

    # sets priority to 0b110, sub-priority to 0b01
    LI $t0, 0b11001 << 8  
    SW $t0, IPC5SET
    
    # IC5CON<15> = 0 (turn on the output compare module)
    # IC5CON<9> = 1 (capture rising edge first)
    # IC5CON<8> = 0 (setting the input capture as a 16-bit value)
    # IC5CON<7> = 0 (set timer 3 )
    # IC5CON<6:5> = 00 (interrupt every on every capture event)
    # IC5CON<2:0> = 101 (capture every 16th rising edge)
    LI $t3, 0b0000001000000001
    SW $t3, IC5CONSET

    # #    Enable Input Capture ICxCON <15> =1
    # LI $t0, 1 << 15
    # SW $t0, IC5CONSET
    
    # Enable the interrupt
    LI $t0, 1 << 21
    SW $t0, IEC0SET 
    # Clears the interrupt flag (avoiding potential spurious interrupt)
    SW $t0, IFS0CLR 
    
    JR $ra
.end setupIC5
    
.endif
    
    