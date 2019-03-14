#     TRISBSET = 0b1000000000; //JF-07, RE09
#     TRISASET = 0b110010; //JF-08, RA01 AND JF-09, RA04 AND JF-10, RA05

.ent setup_switches
    setup_switches:
    #     TRISBSET = 0b1000000000; //JF-07, RE09
    LI $t0, 0b1000000000
    SW $t0, TRISESET
    
    #     TRISASET = 0b110010; //JF-08, RA01 AND JF-09, RA04 AND JF-10, RA05
    LI $t0, 0b110010
    SW $t0, TRISASET
    
    JR $ra
    
.end setup_switches

# C CODE VERSION OF GET_SWITCHES
#  unsigned int get_switches(void)
# {
#     // switch_state[0] == SW1, ...
#     unsigned int switch_state = 0;
#     
# 	// This will neatly arrange the contents of switch state while removing all other data read
# 	// from the PORTs (we only want the switch information and nothing else)
# 	
# 	// Map physical switch pins to new variable to hold organized button data
# 	// switch_state[0] = PORTB[7] 
# 	// switch_state[1] = PORTB[8]
# 	// switch_state[2] = PORTB[9]
# 	// switch_state[3] = PORTB[10]
#     //switch_state = (PORTB & 0x780) >> 7;
#    switch_state = ((PORTE & 0x200) >> 9)|((PORTA & 0x30) >> 2)|(PORTA & 0x2);
#     
#     return switch_state;
# }   
    
.ent get_switches
    get_switches:
    
# The actual configuration of the switches matches the returned number stored
# in binary in $v0. For example, 0b0011 means switches 1 and 2 are on and 0b1001 
# means switches 1 and 4 are on
    
#     ADDI $sp, $sp, -12 # pushed s0 onto the stack to preserve it
#     SW $s0, 0($sp)
#     SW $s1, 4($sp)
#     SW $s2, 8($sp)

    # get switches
    LW $s0, PORTE # 
    ANDI $s0, $s0, 0x200 
    SRL $s0, $s0, 9
    
    LW $s1, PORTA # 
    ANDI $s1, $s1, 0x2
    
    LW $s2, PORTA
    ANDI $s2, $s2, 0x30
    SRL $s2, $s2, 2
    
    OR $s0, $s0, $s1
    OR $v0, $s0, $s2
    
#     LW $s2, 8($sp)
#     LW $s1, 4($sp)
#     LW $s0, 0($sp)
#     ADDI $sp, $sp, 12
    
    JR $ra
.end get_switches
# .endif 
    

