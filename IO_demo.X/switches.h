#ifndef SWITCHES_H
#define	SWITCHES_H

#include <p32xxxx.h> // Defines PIC32MX memory regions 


// Function to setup switches as inputs into our Microcontroller
// NOTE: Function will only setup switches plugged into bottom row of Digilent Pro MX7 PORT JA
void setup_switches(void);

// Function to get the switch data and return the organized switch data
// Returns a 4-bit value of {SW4, SW3, SW2, SW1} (a 32-bit value is returned but bits 31-4 are 0-filled)
unsigned int get_switches(void);

#endif	/* SWITCHES_H */

