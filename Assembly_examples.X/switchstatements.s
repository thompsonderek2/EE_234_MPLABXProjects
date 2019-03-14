.global main
    
.data
    
# examples of data that will be stored in RAM
my_var_1:     .word    0
my_int_array: .word    1, 2, 3, 4
text_prompt:  .asciiz  "Hello and Welcome"
my_switch_i:  .word    default_case, case1, case2, default_case, case4, default_case # this is an array of pointers
  
  
  
.text
    
.ent main   
main:
    
    # switch (i) {
    # case 1: //do something
    # 	break;
    # case 2: //do something
    # 	break;
    # case 3: //do something 
    # 	break;
    # default:  //catch all
    # 	break;
    
    # all labels (like case1: ) are poiters that point to the next line of code
    LA #s0, my_switch_i # gets the base address of the array my_switch_i
    # assume i is in $s7
    SLL $s7, $s7, 2
    ADD $s1, $s0, $s7  # pointer to my_switch_i + offset
    JR $s1
    
    case1:
	# do something
	j endcase
    case2:
	# do something
	j endcase
    case4:
	# do something
	j endcase
    default_case:
	# catch all other cases

    endcase:
	
    loop:
    
    j loop

.end main


