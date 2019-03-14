# //pins 1-4 are COL4-1 and pins 7-10 are ROW4-1
# //this code only works if KYPD Pmod is plugged int Digilent PRO MX7 Port
# void setupKYPAD(void)
# {
#     AD1PCFGSET = 0xFFFF;
#     TRISBCLR = 0b1011100; # //CLEARS BITS INDICATED WITH 1 TO 0 (AS OUTPUTS)
#     TRISBSET = 0b11110000000; # //SETS BITS INDICATED WITH ONES TO INPUTS
#     
#     
# }
    
# .data
 

.ent setupKYPD
setupKYPD:
    
# AD1PCFGSET = 0xFFFF;
LI $t0, 0xFFFF
SW $t0, AD1PCFGSET

# TRISBCLR = 0b1011100;
LI $t0, 0b1011100
SW $t0, TRISBCLR
    
# TRISBSET - 0b11110000000;
LI $t0, 0b11110000000
SW $t0, TRISBSET

JR $ra
.end setupKYPD

    
.ent readKYPD
    readKYPD:
    # C CODE VERSION 
# #        //READING COL1
#      LATBSET = 0b11100;    //make sure other columns are high 
# #                           //COL2 LATBSET = 0b1001100;
#      LATBCLR = 0b1000000;  //make COL1 low (0)             
# #                           //COL2 LATBCLR = 0b0010000;
# # 
# #     //Read rows of COL1
# #     //shift bit 7 over to 0 to correspond with button on calc 
# #     //(0) invert to store as a 1. 
# #     //(active low) then & with 0b1 to mask off others     
# #     //keypad_state[1] = COL1,ROW1 = ~PORTB[10] (BUTTON 1)
#      keypad_state |= (~((PORTB & 0b10000000000)>>9) & 0b10);
# #     //keypad_state[4] = COL1,ROW2 = ~PORTB[9] (BUTTON 4)
#      keypad_state |= (~((PORTB & 0b1000000000)>>5) & 0b10000);
# #     //keypad_state[7] = COL1,ROW3 = ~PORTB[8] (BUTTON 7)
#      keypad_state |= (~((PORTB & 0b100000000)>>1) & 0b10000000);
# #       //keypad_state[0] = COL1,ROW4 = ~PORTB[7] (BUTTON 0)
#      keypad_state |= (~((PORTB & 0b10000000)>>7) & 0b1);
     
    
    MOVE $v1, $zero
    MOVE $t4, $zero
    MOVE $t5, $zero
    MOVE $t6, $zero
    MOVE $t7, $zero
    
    # ASSEMBLY VERSION
    # COLUMN 1
    LI $t0, 0b11100
    SW $t0, LATBSET

    LI $t0, 0b1000000
    SW $t0, LATBCLR
    
    # BUTTON 1
    LW $t0, PORTB
    ANDI $t0, $t0, 0b10000000000
    SRL $t0, $t0, 9
    NOT $t0, $t0
    ANDI $t0, $t0, 0b10
    
    # BUTTON 4
    LW $t1, PORTB
    ANDI $t1, $t1, 0b1000000000
    SRL $t1, $t1, 5
    NOT $t1, $t1
    ANDI $t1, $t1, 0b10000
    
    # BUTTON 7
    LW $t2, PORTB
    ANDI $t2, $t2, 0b100000000
    SRL $t2, $t2, 1
    NOT $t2, $t2
    ANDI $t2, $t2, 0b10000000
    
    # BUTTON 0
    LW $t3, PORTB
    ANDI $t3, $t3, 0b10000000
    SRL $t3, $t3, 7
    NOT $t3, $t3
    ANDI $t3, $t3, 0b1
    
    OR $t1, $t0, $t1
    OR $t2, $t1, $t2
    OR $t4, $t2, $t3
    
    # COLUMN 2

    LI $t0, 0b1001100
    SW $t0, LATBSET

    LI $t0, 0b0010000
    SW $t0, LATBCLR
    
    # BUTTON 2
    LW $t0, PORTB
    ANDI $t0, $t0, 0b10000000000
    SRL $t0, $t0, 8
    NOT $t0, $t0
    ANDI $t0, $t0, 0b100
     # BUTTON 5
    LW $t1, PORTB
    ANDI $t1, $t1, 0b1000000000
    SRL $t1, $t1, 4
    NOT $t1, $t1
    ANDI $t1, $t1, 0b100000
    
    # BUTTON 8
    LW $t2, PORTB
    ANDI $t2, $t2, 0b100000000
    
    NOT $t2, $t2
    ANDI $t2, $t2, 0b100000000
    
    # BUTTON F
    LW $t3, PORTB
    ANDI $t3, $t3, 0b10000000
    SLL $t3, $t3, 8
    NOT $t3, $t3
    ANDI $t3, $t3, 0x8000
    
    OR $t1, $t0, $t1
    OR $t2, $t1, $t2
    OR $t5, $t2, $t3
    
    # COLUMN 3
    
    LI $t0, 0b1010100
    SW $t0, LATBSET

    LI $t0, 0b0001000
    SW $t0, LATBCLR
    
    # BUTTON 3
    LW $t0, PORTB
    ANDI $t0, $t0, 0b10000000000
    SRL $t0, $t0, 7
    NOT $t0, $t0
    ANDI $t0, $t0, 0b1000
    
    # BUTTON 6
    LW $t1, PORTB
    ANDI $t1, $t1, 0b1000000000
    SRL $t1, $t1, 3
    NOT $t1, $t1
    ANDI $t1, $t1, 0b1000000
    
    # BUTTON 9
    LW $t2, PORTB
    ANDI $t2, $t2, 0b100000000
    SLL $t2, $t2, 1
    NOT $t2, $t2
    ANDI $t2, $t2, 0b1000000000
    
    # BUTTON E
    LW $t3, PORTB
    ANDI $t3, $t3, 0b10000000
    SLL $t3, $t3, 7
    NOT $t3, $t3
    ANDI $t3, $t3, 0b100000000000000
    
    OR $t1, $t0, $t1
    OR $t2, $t1, $t2
    OR $t6, $t2, $t3
    
    # COLUMN 4
    LI $t0, 0b1011000
    SW $t0, LATBSET

    LI $t0, 0b0000100
    SW $t0, LATBCLR
    
    # BUTTON A
    LW $t0, PORTB
    ANDI $t0, $t0, 0b10000000000
     
    NOT $t0, $t0
    ANDI $t0, $t0, 0b10000000000
    
    # BUTTON B
    LW $t1, PORTB
    ANDI $t1, $t1, 0b1000000000
    SLL $t1, $t1, 2
    NOT $t1, $t1
    ANDI $t1, $t1, 0b100000000000
    
    # BUTTON C
    LW $t2, PORTB
    ANDI $t2, $t2, 0b100000000
    SLL $t2, $t2, 4
    NOT $t2, $t2
    ANDI $t2, $t2, 0b1000000000000
    
    # BUTTON D
    LW $t3, PORTB
    ANDI $t3, $t3, 0b10000000
    SLL $t3, $t3, 6
    NOT $t3, $t3
    ANDI $t3, $t3, 0b10000000000000
    
    OR $t1, $t0, $t1
    OR $t2, $t1, $t2
    OR $t7, $t2, $t3
    # 'RETURNED' VALUE STORED IN $v1
    OR $t5, $t4, $t5
    OR $t6, $t5, $t6
    OR $v1, $t6, $t7
    
    JR $ra
       
.end readKYPD
    
     
     
     
