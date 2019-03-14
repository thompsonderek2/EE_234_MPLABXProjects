.global main
    
    .data
y: .word 0
x: .word 2

.text

.ent main
main:
    
LW $a0, y
LW $a1, x


BNEZ $a0, not_zero  	# if y is 0, return 1
LI $t0, 1
MADD $t0, $t0
j skip
not_zero:
    
power_function:
BEQZ $a0, skip

LI $t0, 2
DIV $a0, $t0 		# divide y by 2
MFHI $t0
BEQZ $t0, even		# if remainder is 0, branch to even part of function

MFLO $t0		# if not even, load y/2 into t0
MUL $t1, $a1, $a1	# multiply x*x
MADD $t1, $a1		# multiply (x*x)*x and add to acculmulator
MADD $a1, $a1
MOVE $a0, $t0		# make y/2 new y
JAL power_function	# recursive function call
j skip			# skip even routine

even:			# if y is even;
MFLO $t0		# load y/2 into t0
MADD $a1, $a1		# multiply x*x and add to accumulator
MADD $a1, $a1
MOVE $a0, $t0		# make y/2 new y 
JAL power_function	# recursive function call
			
skip:
MFHI $v1		# load high and low values of accumulator into
MFLO $v0		# function return registers

.end main
