#include "switches.h"

// NOTE: Function will only setup switches plugged into bottom row of Digilent Pro MX7 PORT JA
void setup_switches(void)
{
	// Review Appendix C of Digilent Pro MX7 Reference Manual for pinout locations
	// Review Section 12 (I/O) of PIC32 Family Reference Manual for more info on TRISx, PORTx, LATx
 
    // Assuming Switch Pmod is plugged into Bottom Row of MX7 Port JA
    // SW1-4 <--> RB07-10
	// Set pins 7, 8, 9, and 10 of TRISB to inputs (1)
    //DDPCONbits.JTAGEN = 0;
    //TRISBSET = 0x780;
    TRISBSET = 0b1000000000; //JF-07, RE09
    TRISASET = 0b110010; //JF-08, RA01 AND JF-09, RA04 AND JF-10, RA05
    
    
    
	
	// PORTB reused for various pieces of hardware, specifically the analog to digital converter
	// We need to disable the pins as analog pins to use as digital pins (disable ADC pins to use the switch module)
	// Review Section 12 of Digilent Pro MX7 Reference Manual for more info
    //AD1PCFGSET = 0xFFFF; // Change AN01-AN16 to Digital pins not Analog
}

unsigned int get_switches(void)
{
    // switch_state[0] == SW1, ...
    unsigned int switch_state = 0;
    
	// This will neatly arrange the contents of switch state while removing all other data read
	// from the PORTs (we only want the switch information and nothing else)
	
	// Map physical switch pins to new variable to hold organized button data
	// switch_state[0] = PORTB[7] 
	// switch_state[1] = PORTB[8]
	// switch_state[2] = PORTB[9]
	// switch_state[3] = PORTB[10]
    //switch_state = (PORTB & 0x780) >> 7;
    switch_state = ((PORTE & 0x200) >> 9)|((PORTA & 0x30) >> 2)|(PORTA & 0x2);
    
    return switch_state;
}