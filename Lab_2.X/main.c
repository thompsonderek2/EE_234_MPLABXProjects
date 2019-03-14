#include "button.h"
#include "led.h"
#include "switches.h"


// This sets the configuration of the debugger to on
// If you want to run your project in debug mode, make sure to include this line somewhere
// NOTE: you may usually see this line in the config.c file along with other configuration selections
#pragma config ICESEL = ICS_PGx1 // ICE pin selection

int game();

int main (void)
{

    
	// Need to setup all hardware for our program first
    setup_leds();
    setup_buttons();
    setup_switches();
   
    
//	 Embedded applications run forever
//    while (1)
//    {
//		// read buttons pressed
//        buttons = get_buttons();
//		// read switches flipped
//        switches = get_switches();
//		
//		// set LEDs to the sum of buttons and switches
//        set_led_state(switches+buttons);
//    }
    while (1){

        if(game()){
            set_led_state(0b0100);
            delay(500);
            
            set_led_state(0b0000);
            delay(500);
            set_led_state(0b0100);
            delay(500);
            set_led_state(0b0000);
            delay(500);
            set_led_state(0b0100);
            delay(500);
            set_led_state(0b0000);
        }
        else{
             set_led_state(0b1000);
            delay(500);
            
            set_led_state(0b0000);
            delay(500);

            set_led_state(0b1000);
            delay(500);
            set_led_state(0b0000);
            delay(500);
            set_led_state(0b1000);
            delay(500);
            set_led_state(0b0000);
        }

    }
    
    
    return 0;
}

int game(){
    
    unsigned int buttons = 0; 	// holds a 3-bit value of button press data
    unsigned int switches = 0;	// holds a 4-bit value of switch flip data
    unsigned int simon_sequence[8] = {0b0001, 0b1000, 0b0100, 0b1000, 0b0001, 0b1000, 0b0100, 0b0010};
     
    unsigned int i,j,k,ctr;
    
    unsigned int player_sequence[8] = {0};
    buttons = get_buttons();
    ctr = 0;
    i=0;
    while(buttons == 0){
        buttons = get_buttons();
        
    }

     for (i; i<8; i++){
        for(j=0; j<=i; j++){
               delay(1000);
               set_led_state(simon_sequence[j]);
               delay(1000);
               set_led_state(0b0000);
           }


       for (ctr = 0; ctr <= i; ctr++){
           do{
               switches = get_switches();
               set_led_state(switches);
           }while (switches == 0);
           player_sequence[ctr] = switches;
           delay(2000);
        }

       while(switches != 0){
          switches = get_switches();
          set_led_state(switches);
       }

       for(k=0; k <= i; k++){
           if (simon_sequence[k] != player_sequence[k]){
               return 0;
           }
       }

    } 


         return 1;
}