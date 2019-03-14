# ***************************************************************************************************************************
# * Author:                                                                                                                 *
# * Course: EE 234 Microprocessor Systems - Lab #                                                                           *
# * Project:                                                                                                                *
# * File: CodeTemplate.s                                                                                                    *
# * Description: This file is provided to help you get started with MIPS32 (.s) assembly programs.                          *
# *              You may use this template for getting started with .S files also, in which preprocessor directives         *
# *              are allowed.                                                                                               *                           
# *                                                                                                                         *
# * Inputs:                                                                                                                 *
# * Outputs:                                                                                                                *
# * Computations:                                                                                                           *
# *                                                                                                                         *
# * Revision History:                                                                                                       *
# *************************************************************************************************************************** 


# ***************************************************************************************************************************
# *                                                                                                                         *
# *                                           Include Files                                                                 *
# *                                                                                                                         *
# ***************************************************************************************************************************


# ***************************************************************************************************************************
# *                                                                                                                         *
# *                                           Global Symbols                                                                *
# *                                                                                                                         *
# ***************************************************************************************************************************

.GLOBAL main

# ***************************************************************************************************************************
# *                                                                                                                         *
# *                                           Data Segment                                                                  *
# *                                                                                                                         *
# ***************************************************************************************************************************

# This is where all variables are defined.
# We generally assign pointer/address registers to these variables and access them indirectly via these registers.

.DATA                        # The start of the data segment


# ***************************************************************************************************************************
# *                                                                                                                         *
# *                                           Code Segment                                                                  *
# *                                                                                                                         *
# ***************************************************************************************************************************

.TEXT                        # The start of the code segment

	                         
.ENT main                    # Setup a main entry point
main:

    jal setupLEDs
    
    LI $t0, 0xC0 
    SW $t0, TRISGSET
    
#     LI $t0, 0x1
#     SW $t0, TRISASET
    
    
    
    # Setup 
	loop:
		# Event loop
		# GET BUTTONS
		LW $t1, PORTG
		ANDI $t2, $t1, 0xC0    # PORTG & 0b11000000
		# Display buttons to LEDs
		LI $t0, 0xF000
		SW $t0, LATGCLR
		
		SLL $t2, $t2, 6    # LATGSET = t2 << 6
		SW $t2, LATGSET
		
				# Event loop
		# GET Switches from port E
		LW $t1, PORTE
		ANDI $t2, $t1, 0x200    # PORTE & 0b1000000000
		# Display switches to LEDs
		LI $t0, 0xF000
		SW $t0, LATGCLR
		
		SLL $t2, $t2, 3  # LATBSET = t2 << 3
		SW $t2, LATGSET
		
		# get switches from port A
		LW $t1, PORTA  # TRISASET = 0b110010;
		ANDI $t2, $t1, 0x30
		ANDI $t3, $t1, 0x2
		LI $t0, 0xF000
		SW $t0, LATGCLR
		SLL $t2, $t2, 10
		SLL $t3, $t3, 12
		SW $t2, LATGSET
		SW $t3, LATGSET
		
		
		
		
# 		MOVE $t0, $t1
# 		ORI $t0, $t1, $zero
		
		
		J loop               # Embedded programs require that they run forever! So jump back to the beginning of the loop
	
.END main

# ***************************************************************************************************************************
# *                                                                                                                         *
# *                                           Subroutine Definitions                                                        *
# *                                                                                                                         *
# ***************************************************************************************************************************

# The below comment block is required for all defined subroutines!
# ***************************************************************************************************************************
# * Function Name:                                                                                                          *
# * Description:                                                                                                            *
# *                                                                                                                         *
# * Inputs:		                                                                                                            *
# * Outputs:	                                                                                                            *
# * Computations:                                                                                                           *
# *                                                                                                                         *
# * Errors:                                                                                                                 *
# * Registers Preserved:                                                                                                    *
# *                                                                                                                         *
# * Preconditions:                                                                                                          *
# * Postconditions:                                                                                                         *
# *                                                                                                                         *
# * Revision History:                                                                                                       *
# ***************************************************************************************************************************

.ent setupLEDs
setupLEDs:
    
    # setup LEDs as outputs 
    # Clear pins PORTG 12-15
    # TRISGCLR = 0xF000;
    LI $t0, 0xF000
    SW $t0, TRISGCLR
    # LATGCLR = 0xF000
    SW $t0, LATGCLR
    
    JR $ra 
    
.end setupLEDs
    
.ent setup_switches
    
    
    
    
.end setup_switches