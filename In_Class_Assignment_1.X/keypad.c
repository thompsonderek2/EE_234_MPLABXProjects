#include "keypad.h"
#include "led.h"

//pins 1-4 are COL4-1 and pins 7-10 are ROW4-1
//this code only works if KYPD Pmod is plugged int Digilent PRO MX7 Port
void setupKYPAD(void)
{
    AD1PCFGSET = 0xFFFF;
    TRISBCLR = 0b1011100; //CLEARS BITS INDICATED WITH 1 TO 0 (AS OUTPUTS)
    TRISBSET = 0b11110000000;//SETS BITS INDICATED WITH ONES TO INPUTS
    
    
}
    
unsigned int readKYPD(void){
    unsigned int keypad_state =0;
    
    //READING COL1
    LATBSET = 0b11100;    //make sure other columns are high 
                          //COL2 LATBSET = 0b1001100;
    LATBCLR = 0b1000000;  //make COL1 low (0)             
                          //COL2 LATBCLR = 0b0010000;

    //Read rows of COL1
    //shift bit 7 over to 0 to correspond with button on calc 
    //(0) invert to store as a 1. 
    //(active low) then & with 0b1 to mask off others     
    //keypad_state[1] = COL1,ROW1 = ~PORTB[10] (BUTTON 1)
    keypad_state |= (~((PORTB & 0b10000000000)>>9) & 0b10);
    //keypad_state[4] = COL1,ROW2 = ~PORTB[9] (BUTTON 4)
    keypad_state |= (~((PORTB & 0b1000000000)>>5) & 0b10000);
    //keypad_state[7] = COL1,ROW3 = ~PORTB[8] (BUTTON 7)
    keypad_state |= (~((PORTB & 0b100000000)>>1) & 0b10000000);
      //keypad_state[0] = COL1,ROW4 = ~PORTB[7] (BUTTON 0)
    keypad_state |= (~((PORTB & 0b10000000)>>7) & 0b1);
    
    //READING COL2
    LATBSET = 0b1001100;
    LATBCLR = 0b0010000;
    
    //keypad_state[2] = COL2,ROW1 = ~PORTB[10] (BUTTON 2)
    keypad_state |= (~((PORTB & 0b10000000000)>>8) & 0b100);
    //keypad_state[5] = COL2,ROW2 = ~PORTB[9] (BUTTON 5)
    keypad_state |= (~((PORTB & 0b1000000000)>>4) & 0b100000);
    //keypad_state[8] = COL1,ROW3 = ~PORTB[8] (BUTTON 8)
    keypad_state |= (~((PORTB & 0b100000000)) & 0b100000000);
      //keypad_state[F] = COL1,ROW4 = ~PORTB[7] (BUTTON F)
    keypad_state |= (~((PORTB & 0b10000000)<<8) & 0x8000);
    
    //READING COL3
    LATBSET = 0b1010100;
    LATBCLR = 0b0001000;
    
    //keypad_state[3] = COL3,ROW1 = ~PORTB[10] (BUTTON 3)
    keypad_state |= (~((PORTB & 0b10000000000)>>7) & 0b1000);
    //keypad_state[6] = COL3,ROW2 = ~PORTB[9] (BUTTON 6)
    keypad_state |= (~((PORTB & 0b1000000000)>>3) & 0b1000000);
    //keypad_state[9] = COL3,ROW3 = ~PORTB[8] (BUTTON 9)
    keypad_state |= (~((PORTB & 0b100000000)<<1) & 0b1000000000);
      //keypad_state[E] = COL3,ROW4 = ~PORTB[7] (BUTTON E)
    keypad_state |= (~((PORTB & 0b10000000)<<7) & 0b100000000000000);
    
    //READING COL4
    LATBSET = 0b1011000;
    LATBCLR = 0b0000100;
    
    //keypad_state[A] = COL3,ROW1 = ~PORTB[10] (BUTTON A)
    keypad_state |= (~((PORTB & 0b10000000000)) & 0b10000000000);
    //keypad_state[B] = COL3,ROW2 = ~PORTB[9] (BUTTON B)
    keypad_state |= (~((PORTB & 0b1000000000)<<2) & 0b100000000000);
    //keypad_state[C] = COL3,ROW3 = ~PORTB[8] (BUTTON C)
    keypad_state |= (~((PORTB & 0b100000000)<<4) & 0b1000000000000);
    //keypad_state[D] = COL3,ROW4 = ~PORTB[7] (BUTTON D)
    keypad_state |= (~((PORTB & 0b10000000)<<6) & 0b10000000000000);
    
    return keypad_state;
}
//uses a case statement to select the appropriate led configuration
//to output binary number corresponding to the button on the keypad
//that is pressed
void writeKYPDtoLEDs (unsigned int keypad_state){
    switch (keypad_state)
    {
        //BUTTON 1
        case 0b10:
            set_led_state(0b0001);
            break;
        //BUTTON 2
        case 0b100:
            set_led_state (0b0010);
            break;
        //BUTTON 3
        case 0b1000:
            set_led_state (0b0011);
            break;
        //BUTTON 4
        case 0b10000:
            set_led_state (0b0100);
            break;
        //BUTTON 5
        case 0b100000:
            set_led_state (0b0101);
            break;
        //BUTTON 6
        case 0b1000000:
            set_led_state (0b0110);
            break;
        //BUTTON 7
        case 0b10000000:
            set_led_state (0b0111);
            break;
        //BUTTON 8
        case 0b100000000:
            set_led_state (0b1000);
            break;
        //BUTTON 9
        case 0b1000000000:
            set_led_state (0b1001);
            break;            
        //BUTTON A (10)
        case 0b10000000000:
            set_led_state (0b1010);
            break;
        //BUTTON B (11)
        case 0b100000000000:
            set_led_state (0b1011);
            break;
        //BUTTON C (12)
        case 0b1000000000000:
            set_led_state (0b1100);
            break;
        //BUTTON D (13)
        case 0b10000000000000:
            set_led_state (0b1101);
            break;
        //BUTTON E (14)
        case 0b100000000000000:
            set_led_state (0b1110);
            break;
        //BUTTON F (15)
        case 0b1000000000000000:
            set_led_state (0b1111);
            break;
            
        default:
            set_led_state (0);
    }
}