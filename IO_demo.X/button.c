#include "button.h"

void setup_buttons(void)
{
	// Review Appendix C of Digilent Pro MX7 Reference Manual for pinout locations
	// Review Section 12 (I/O) of PIC32 Family Reference Manual for more info on TRISx, PORTx, LATx
    
	// RG06 <--> BTN1; RG07 <--> BTN2; RA00 <--> BTN3
	// Set pins 6 and 7 of TRISG to inputs (1)
    TRISGSET = 0b11000000;
	// Set pin 0 of TRISA to input (1) 
    TRISASET = 0b1;
    
	// TRISA pin 0 is reused for various pieces of hardware (disable other uses to use as button)
	// Review Section 4.1 of Digilent Pro MX7 Reference Manual for more info
    DDPCONbits.JTAGEN = 0; // Disable JTAG controller so we can use button 3 
}

unsigned int get_buttons(void)
{
    // button_state[0] == BTN1, button_state[1] == BTN2, button_state[2] == BTN3
    unsigned int button_state = 0;
    
	// This will neatly arrange the contents of button state while removing all other data read
	// from the PORTs (we only want the button press information and nothing else)
	
	// Map physical button pins to new variable to hold organized button data
	// button_state[0] = PORTG[6] 
	// button_state[1] = PORTG[7]
	// button_state[2] = PORTA[0]
    button_state = ((PORTG & 0b11000000) >> 6) | ((PORTA & 0b1) << 2);
    
    return button_state;
}
