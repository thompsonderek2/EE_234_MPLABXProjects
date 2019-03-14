.include "RoboMAL.s"
.include "LED.s"


    
    
.global main
    
.data
 
counter: .word 0


    
.text
    
.ent main
main:
      
    loop:
	 jal runProgram

	
    j loop

.end main


    