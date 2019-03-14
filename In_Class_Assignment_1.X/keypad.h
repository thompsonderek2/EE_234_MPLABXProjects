#ifndef KEYPAD_H
#define	KEYPAD_H

#include <p32xxxx.h> // Defines PIC32MX memory regions 

void setupKYPAD(void);
unsigned int readKYPD(void);
void writeKYPDtoLEDs (unsigned int keypad_state);

#endif