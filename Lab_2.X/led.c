#include "led.h"

void delay (delay){
    unsigned int i,j;
    for (i=0; i<=delay; i++){
        for (j=0; j<30; j++);
    }
}

void setup_leds(void)
{
	// Review Appendix C of Digilent Pro MX7 Reference Manual for pinout locations
	// Review Section 12 (I/O) of PIC32 Family Reference Manual for more info on TRISx, PORTx, LATx
    
    // LD1-4 <--> RG12-15
	// Clear pins 12, 13, 14, and 15 of TRISG to outputs (0)
    TRISGCLR = 0xF000;
    // Because the Microcontroller drives the LEDs, let's initialize the LEDs to all off (clear their data bits)
	LATGCLR = 0xF000;
    
}

void set_led_state (unsigned int led_data)
{    
	// This will write the least significant 4-bits of led_data out to the LEDs
	
	// Map led_data bits  to physical LEDs
	// LATG[12] = led_data[0]
	// LATG[13] = led_data[1]
	// LATG[14] = led_data[2]
	// LATG[15] = led_data[3]
	// First clear out old data to the LEDs
    LATGCLR = 0xF000;
	// Now set the LEDs on if the corresponding mapped bit is a 1 in the led_data variable
    LATGSET = (led_data & 0xF) << 12;
    
	// There are many ways write the same piece of code. 
	// This commented out code takes more steps but does the same thing as the code above
	/*
    unsigned int temp_state = 0;
    temp_state = PORTG;
    temp_state &= 0xFFFF0FFF;
    temp_state |= (button_state & 0xF) << 12;
    LATG = temp_state;*/
}