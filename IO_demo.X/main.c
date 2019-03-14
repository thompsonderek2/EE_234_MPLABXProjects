#include "button.h"
#include "led.h"
#include "switches.h"

// This sets the configuration of the debugger to on
// If you want to run your project in debug mode, make sure to include this line somewhere
// NOTE: you may usually see this line in the config.c file along with other configuration selections
#pragma config ICESEL = ICS_PGx1 // ICE pin selection

int main (void)
{
    unsigned int buttons = 0; 	// holds a 3-bit value of button press data
    unsigned int switches = 0;	// holds a 4-bit value of switch flip data
    int count = 0;
    int delay,i = 0;
    
	// Need to setup all hardware for our program first
    setup_leds();
    setup_buttons();
    setup_switches();
    
	// Embedded applications run forever
    while (1)
    {
        do//"press any button before moving along with the code"
        { //efficeint; calls function once and stores the value in a variable
            buttons = get_buttons();
          
        }while (buttons == 0);
        
        //dummy delay to fix debounce problem with buttons
        for(delay = 0; delay < 100000; delay++){
            i++; //put a dummy var in the loop so that the comp does not skip loop
        }
        
        count++;
        set_led_state(count);
        
        do
        { //makes a "trap" so that the system won't cycle through with a singe button press
            buttons = get_buttons();
            
        }while (buttons != 0);
        
        
    }
    
    return 0;
}
