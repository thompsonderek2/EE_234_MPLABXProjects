//DEREK THOMPSON
//01/31/2018
//EE 234
//IN-CLASS ASSIGNMENT 1
//KEYPAD I/O

#include "keypad.h"
#include "led.h"
#pragma config ICESEL = ICS_PGx1 // ICE pin selection

int main (void)
{
    
    int ctr,i;
    unsigned int keys = 0;
    
	// Need to setup all hardware for our program first
    setup_leds();
    setupKYPAD();
    
	// loop runs endlessly checking the state of the keypad, assigns it to
    //var. keys.  this integer is passed to writeKYPDtoLEDs(keys) and is 
    //used to select a case.

    while (1)
    {
        keys = readKYPD();
        writeKYPDtoLEDs(keys);
        
    }
    
    return 0;
}
