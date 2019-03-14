.include "buttons.s"
.include "LEDs.s"    
    
.global main

.data                        # The start of the data segment

.text                        # The start of the code segment
                         
.ent main                    # Setup a main entry point
main:
      
    jal setupBoard    
   
    loop:
	    # Event loop
	    jal getButtons
	    MOVE $a0, $v0
	    jal setLEDs
	    
	    

    j loop               # Embedded programs require that they run forever! So jump back to the beginning of the loop
	
.end main
    
# void setupBoard(void)
# sets all inputs and outputs for current project
.ent setupBoard
setupBoard:
    ADDI $sp, $sp, -4 # pushed ra onto the stack to preserve it
    SW $ra, 0($sp)
    
    # Setup LEDs as outputs
    jal setupLEDs
    
    # Setup Buttons as inputs    
    jal setupButtons
    
    # pop ra off the stack
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    
    jr $ra
.end setupBoard
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    