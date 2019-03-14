.ifndef INPUTCAPTURE_S
INPUTCAPTURE_S:
   
# IC2 ? JD-01, digital pin 24, RD09

.ent setupIC3
    setupIC3:
    
# Sensor A & B are in pins JD-03 (RC04) and JD-04 (RD10)
# IC3 monitors the state of pin JD-04, digital pin 27, RD10

# Setting IC pin as inputs
LI $t0, 0b10000000000
SW $t0, TRISDSET
SW $t0, LATDCLR

# clear all IC3 registers

    
# ICxCON: Input Capture x Control Register
#   ICxCON<7> = 1; ICTMR: Input Capture x Timer Select bit;
    # 1 = TMR2 contents are captured on capture event
#   ICxCON<6:5> = 01; Interrupt on every second capture event
#   ICxCON<2:0> = 001; Edge capture mode, every edge
    
LI $t0, 0b10100001
SW $t0, IC3CONSET
    
# Set input capture priorities
    
    # Priority = 6; Sub-Priority = 0;
    # IPC3<12:10> = 3; IPC3<9:8> = 0
    LI $t0, 0b11111 << 8
    SW $t0, IPC4CLR # Clear out any priority given to IC3 previously
    
    LI $t0, 0b10100 << 8 # sets priority to 0b101, sub-priority to 0b00
    SW $t0, IPC4SET 
    
    LI $t0, 1 << 13
    SW $t0, IEC0SET # Enable the interrupt
    SW $t0, IFS0CLR # Clears the interrupt flag (avoiding potential spurious 
		    # interrupt)

# The Input Capture module captures the 16-bit value of the selected timer (Timer2 or Timer3),
# when a capture event occurs.
# A capture event is defined as a write of a timer value into the
# capture buffer.
    
# // Enable Capture Interrupt And Timer2
    # IPC0bits.IC1IP = 1; // Setup IC1 interrupt priority level
    # IFS0bits.IC1IF = 0; // Clear IC1 Interrupt Status Flag
    # IEC0bits.IC1IE = 1; // Enable IC1 interrupt
    
# reset the timer every time an input capture is read.  
# this way, the timer starts at zero, when the input is captured.
    
.end setupIC3
.endif


