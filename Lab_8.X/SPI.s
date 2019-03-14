.ifndef SPI_S
SPI_S:  
    
.text
# Setting up LCD Pmod in PORT JE
.ent setupSPI3    
setupSPI3:
    SW $zero, SPI3CON
    SW $zero, SPI3STAT
    SW $zero, SPI3BRG
    LW $t0, SPI3BUF
    
    # setup slave select pin
    LI $t0, 1 << 14
    SW $t0, TRISDCLR
    SW $t0, LATDSET
    
    # set baud rate
    LI $t0, 15
    SW $t0, SPI3BRG
        
    # set configuration
    LI $t0, 0x8220
    SW $t0, SPI3CON
        
    jr $ra
.end setupSPI3
    
# void sendSPIString(char *array)
# a0 = pointer to character array
.ent sendSPIString
sendSPIString:
    ADDI $sp, $sp, -4
    SW $s0, 0($sp)
    
    # strobe slave select pin to signify start of data
    LI $t0, 1 << 14
    SW $t0, LATDCLR
 
    startSendSPIString:
	# Get current pointer character into reg s0
	LB $s0, 0($a0)
	BEQZ $s0, endSendSPIString
    waitToSendSPIString:
	LW $t0, SPI3STAT
	ANDI $t0, $t0, 1 << 3
	BEQZ $t0, waitToSendSPIString # SPI TX buffer is full, wait for more space
	
	# Space available in TX buffer, write 1 char to TX buffer
	SB $s0, SPI3BUF
	
    waitToReceiveSPIString:
	LW $t0, SPI3STAT
	ANDI $t0, $t0, 1
	BEQZ $t0, waitToReceiveSPIString # SPI RX buffer is empty, wait for data
	
	# Data available in RX buffer, Read 1 char from RX buffer
	LB $s0, SPI3BUF
	
	
	# Move address pointer of string to next char
	ADDI $a0, $a0, 1
	
	J startSendSPIString

    endSendSPIString:
    
    LI $t0, 1 << 14
    SW $t0, LATDSET
    
    LW $s0, 0($sp)
    ADDI $sp, $sp, 4
        
    jr $ra
.end sendSPIString
    
# void sendSPIChar(char character)
# a0 = character to send
.ent sendSPIChar
sendSPIChar:
    
    LI $t0, 1 << 14
    SW $t0, LATDCLR

    waitToSendSPIChar:
	LW $t0, SPI3STAT
	ANDI $t0, $t0, 1 << 3
	BEQZ $t0, waitToSendSPIChar # UART TX buffer is full, wait for more space
	
	# Space available in TX buffer, write 1 char to TX buffer
	SB $a0, SPI3BUF
    
    waitToReceiveSPIChar:
	LW $t0, SPI3STAT
	ANDI $t0, $t0, 1
	BEQZ $t0, waitToReceiveSPIChar # UART TX buffer is full, wait for more space
	
	# Space available in TX buffer, write 1 char to TX buffer
	LB $v0, SPI3BUF
	
    LI $t0, 1 << 14
    SW $t0, LATDSET
    
    jr $ra
.end sendSPIChar
    
.endif








