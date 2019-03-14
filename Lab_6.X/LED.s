 .ifndef LED_S
     LED_S:

# LEDs Library
# This library only works for Digilent ProMX795F512L Board
# void setupLEDs(void)
# void setLEDs(int num)
    
.text
    
# void setupLEDs(void)
.ent setupLEDs
setupLEDs:
    # PORTG 12-15 LEDs
    LI $t0, 0xF000	# TRISGCLR = 0xF000
    SW $t0, TRISGCLR
    
    SW $t0, LATGCLR	# LATGCLR = 0xF000
    
    JR $ra
.end setupLEDs
    
# void setLEDs(int num)
.ent setLEDs
setLEDs:
    # Display a 4-bit number to LEDs
    LI $t0, 0xF000
    SW $t0, LATGCLR
    
    SLL $t0, $a0, 12
    SW $t0, LATGSET	
    
    JR $ra
.end setLEDs
     
.endif








