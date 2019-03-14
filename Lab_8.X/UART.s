.ifndef UART_S
UART_S:  
    
.text
# Setting up Bluetooth Pmod in PORT JE
.ent setupUART1    
setupUART1:
    SW $zero, U1MODE
    SW $zero, U1STA
    SW $zero, U1BRG
    SW $zero, U1TXREG
    SW $zero, U1RXREG
      
    # set baud rate
    # U2BRG = 21;
    LI $t0, 259
    SW $t0, U1BRG
        
    # set frame (8 data bits, no parity, 1 stop)
    # U2MODE<2:0> = 0b000
        
    # enable UART for RX/TX
    # for now, only receiving data from the BT module
    LI $t0, 1 << 12
    SW $t0, U1STASET
    
    LI $t0, 1 << 15
    SW $t0, U1MODESET 
    
    jr $ra
.end setupUART1
    
# Setting up LCD Pmod in PORT JF
.ent setupUART2    
setupUART2:
    SW $zero, U2MODE
    SW $zero, U2STA
    SW $zero, U2BRG
    SW $zero, U2TXREG
    SW $zero, U2RXREG
        
    # set baud rate
    # U2BRG = 2;
    LI $t0, 259
    SW $t0, U2BRG
        
    # set frame (8 data bits, no parity, 1 stop)
    # U2MODE<2:0> = 0b000
        
    # enable UART for RX/TX
    # for now, only transmitting data to the LCD screen module
    LI $t0, 1 << 10
    SW $t0, U2STASET
    
    LI $t0, 1 << 15
    SW $t0, U2MODESET  
    
    jr $ra
.end setupUART2
    
# void sendString(char *array)
# a0 = pointer to character array
.ent sendString
sendString:
    ADDI $sp, $sp, -4
    SW $s0, 0($sp)
 
    startSendString:
	# Get current pointer character into reg s0
	LB $s0, 0($a0)
	BEQZ $s0, endSendString
    waitToSendString:
	LW $t0, U2STA
	ANDI $t0, $t0, 1 << 9
	BNEZ $t0, waitToSendString # UART TX buffer is full, wait for more space
	
	# Space available in TX buffer, write 1 char to TX buffer
	SB $s0, U2TXREG
	
	# Move address pointer of string to next char
	ADDI $a0, $a0, 1
	
	J startSendString

    endSendString:
    
    LW $s0, 0($sp)
    ADDI $sp, $sp, 4
        
    jr $ra
.end sendString
    
# void sendChar(char character)
# a0 = character to send
.ent sendChar
sendChar:
    waitToSendChar:
	LW $t0, U2STA
	ANDI $t0, $t0, 1 << 9
	BNEZ $t0, waitToSendChar # UART TX buffer is full, wait for more space
	
	# Space available in TX buffer, write 1 char to TX buffer
	SB $a0, U2TXREG
        
    jr $ra
.end sendChar
    

    
.endif