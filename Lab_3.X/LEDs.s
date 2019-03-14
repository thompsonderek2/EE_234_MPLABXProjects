 .ifndef LEDS_S
     LEDS_S:

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
    SW $t0, LATGCLR # LATGCLR sets the values of the leds to 0 (inverses the values in $t0
    
    ANDI $t0, $a0, 0xF
    SLL $t0, $t0, 12 # shifts the value from the buttons stored in a0 over 12 so that it lines up with the LEDs
    SW $t0, LATGSET	# sets the value of the buttons that has been shifted to the LEDs
    
    JR $ra # returns to original function
.end setLEDs
     
.endif





