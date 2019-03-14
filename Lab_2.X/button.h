#ifndef BUTTON_H
#define	BUTTON_H

#include <plib.h>    // Includes all majors functions and macros for PIC32MX development
#include <p32xxxx.h> // Defines PIC32MX memory regions 

// Function to setup buttons as inputs into our Microcontroller
void setup_buttons(void);

// Function to get the button press data and return the organized button data
// Returns a 3-bit value of {BTN3, BTN2, BTN1} (a 32-bit value is returned but bits 31-3 are 0-filled)
unsigned int get_buttons(void);

#endif
