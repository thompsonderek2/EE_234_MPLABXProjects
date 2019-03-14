#ifndef LED_H
#define	LED_H

#include <p32xxxx.h> // Defines PIC32MX memory regions 


// Function to setup LEDs as outputs from our Microcontroller
void setup_leds(void);

// Function to turn on the LEDs based on input  led_data variable
// sets the 4 LEDs to a 4-bit value inside of the led_data variable (stored in bits 3,2,1,0)
void set_led_state (unsigned int led_data);

#endif	/* LED_H */

