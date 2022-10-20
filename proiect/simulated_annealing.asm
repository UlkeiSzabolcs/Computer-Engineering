#	s0	file descriptor
#	s1	best solution
#	s2	best result
#	s3	current solution
#	s4	current result
#	f31	current temperature

		.include	"macros.asm"
		.include 	"pow_e.asm"
		
		.data
#---------------random reading data
randFile:	.asciiz		"RandomNumbers.txt"
buffer:		.space		8
fileDescriptor:	.word		0


#---------------cooling function data
coolingRate:	.float		0.98

#---------------Acceptance function data
threshold:	.float		0.05

#---------------Initial conditions
initialTemp:	.float		1500
initialSol:	.byte		40

#---------------Border Values
minTemp:	.float		50.0


#---------------General usage
spaceChr:	.byte		' '
zeroChr:	.byte		'0'
point_1:	.float		0.1
point_2:	.float		0.2
point_3:	.float		0.3
point_4:	.float		0.4
point_5:	.float		0.5
point_6:	.float		0.6
point_7:	.float		0.7
point_8:	.float		0.8
point_9:	.float		0.9
float_zero:	.float		0.0
float_one:	.float		1.0
float_hundred:	.float		100.0


		.text
#Functions:

#readRand:
	#reads a random number from the specified txt file
	#result in v0
#updateTemp:
	#updates temperature
	#current temp has to be in f31
	#result in f0
	
#probabilityFunction
	#calculates e^-(deltaF / T)
	#deltaF has to be in f0
	#result in f11
	
#coolingFunction
	#the main function to be solved
	#x in a0
	#result in v0
	#Range is (-5, inf)
	_start:
		saInit
		randInit
		jal simulatedAnnealing
		
		print_newline
		print_newline
		print_newline
		print_newline
		
		print_int($s1)
		print_space
		print_int($s2)
		done

#----------------------------Simulated Annealing-------------------------------------------
	simulatedAnnealing:
#	s0	file descriptor
#	s1	best solution
#	s2	best result
#	s3	current solution
#	s4	current result
#	f31	current temperature
	
		#push ra onto stack
		sub 	$sp, $sp, 4
		sw	$ra, 4($sp)
	
		move 	$a0, $s1
		jal 	coolingFunction	#get initial result
		move 	$s2, $v0	#initial result is best result yet
		move 	$s3, $s1	#initial solution is current solution
		move	$s4, $s2	#initial result is current result
		
	Inhomogeneous_loop:
		jal readRand
		move	$t1, $v0	#get
		cvt.w.s	$f28, $f31
		mfc1	$t2, $f28	#the remainder
		add	$t2, $t2, $s3
		div	$t1, $t2	#of division with T
		mfhi	$s5
		print_int($t2)
		print_spaces
		move 	$a0, $s5
		
		jal 	coolingFunction
		move 	$s6, $v0
		print_int($s5)
		print_space
		print_int($s6)
		sub 	$t0, $s6, $s2
		blez	$t0, Inhomogeneous_best_swap
		mtc1	$t0, $f0
		cvt.s.w	$f0, $f0
		jal	probabilityFunction
		print_spaces
		mov.s 	$f12, $f11
		print_float
		print_space
		jal 	readRand	#read another random number
		move	$t1, $v0	#get
		li	$t2, 100	#the remainder
		div	$t1, $t2	#of division with 100
		mfhi	$t1		#into t1
		mtc1	$t1, $f13	#convert into
		cvt.s.w	$f13, $f13	#float
		la	$a1, float_hundred
		l.s	$f14, ($a1)
		div.s	$f13, $f13, $f14#divide by 100 to get probability
		mov.s	$f12, $f13
		print_float
		c.le.s	$f11, $f13	#if the prob. gotten is greater than the probability of the
		bc1f	Inhomogeneous_current_swap	#functions result than it remains the current solution
		j	Inhomogeneous_tempUpdate	#Else upadte the temperature
		
	Inhomogeneous_best_swap:
		print_space
		print_best_swap
		move	$s2, $s6
		move	$s1, $s5
	
	Inhomogeneous_current_swap:
		print_space
		print_current_swap
		move	$s4, $s6
		move	$s3, $s5
		j	Inhomogeneous_tempUpdate
	
	Inhomogeneous_tempUpdate:
		jal	updateTemp
		c.le.s	$f0, $f29
		bc1t	Inhomogeneous_end	#if the temp has fallen below minimum end
		mov.s	$f31, $f0
		print_newline
		j	Inhomogeneous_loop
	Inhomogeneous_end:
		
		move	$v0, $s1
		move	$v1, $s2
		
		#pop ra from stack
		lw	$ra, 4($sp)
		add	$sp, $sp, 4
		jr	$ra
		

#----------------------------Cooling function-----------------------------------------------
	coolingFunction:
		#x in a0
		#result in v0
		#Range is (-5, inf)
		
		#push ra onto stack
		sub 	$sp, $sp, 4
		sw	$ra, 4($sp)
		
		move	$t1, $a0
		li	$t2, 2
		ble	$t1, $t2, firstCase
		li	$t2, 3
		ble	$t1, $t2, secondCase
		li	$t2, 7
		ble	$t1, $t2, thirdCase
		li	$t2, 13
		ble	$t1, $t2, fourthCase
		li	$t2, 19
		ble	$t1, $t2, fifthCase
		li	$t2, 22
		ble	$t1, $t2, sixthCase
		li	$t2, 33
		ble	$t1, $t2, seventhCase
		li	$t2, 36
		ble	$t1, $t2, eightCase
		li	$t2, 40
		ble	$t1, $t2, ninthCase
		li	$t2, 42
		ble	$t1, $t2, tenthCase
	eleventhCase:
		move	$t2, $t1
		subi	$t2, $t2, 41
		li	$t3, -1
		mul	$t2, $t2, $t3
		li	$t3, 1
		div	$t2, $t3, $t2
		addi	$t2, $t2, 1000
		j	endCoolingFunction
	tenthCase:
		move	$t2, $t1
		li	$t3, 7
		mul	$t2, $t2, $t3
		subi	$t2, $t2, 295
		j	endCoolingFunction
	ninthCase:
		move	$t2, $t1
		subi	$t3, $t2, 38
		mul	$t2, $t3, $t3
		mul	$t2, $t2, $t3
		abs	$t2, $t2
		subi	$t2, $t2, 23
		j	endCoolingFunction
	eightCase:
		move	$t2, $t1
		li	$t3, -5
		mul	$t2, $t2, $t3
		addi	$t2, $t2, 165
		j	endCoolingFunction
	seventhCase:
		move	$t2, $t1
		li	$t3, -1
		mul	$t2, $t2, $t3
		addi	$t2, $t2, 33
		j	endCoolingFunction
	sixthCase:
		move	$t2, $t1
		subi	$t3, $t2, 19
		mul	$t2, $t3, $t3
		mul	$t2, $t2, $t3
		subi	$t2, $t2, 16
		j	endCoolingFunction
	fifthCase:
		move	$t2, $t1
		subi	$t2, $t2, 13
		mul	$t2, $t2, $t2
		li	$t3, -1
		mul	$t2, $t2, $t3
		addi	$t2, $t2, 20
		j	endCoolingFunction
	fourthCase:
		move	$t2, $t1
		subi	$t2, $t2, 8
		mul	$t2, $t2, $t2
		subi	$t2, $t2, 5
		j	endCoolingFunction
	thirdCase:
		move	$t2, $t1
		subi	$t2, $t2, 4
		mul	$t2, $t2, $t2
		li	$t3, -1
		mul	$t2, $t2, $t3
		addi	$t2, $t2, 11
		j	endCoolingFunction
	secondCase:
		move	$t2, $t1
		li	$t3, 3
		mul	$t2, $t2, $t3
		subi	$t2, $t2, 1
		j	endCoolingFunction
	firstCase:
		move	$t2, $t1
		mul	$t2, $t2, $t2
		mul	$t2, $t2, $t1
		sub	$t2, $t2, $t1
		sub	$t2, $t2, $t1
		addi	$t2, $t2, 1
		j	endCoolingFunction
		
	endCoolingFunction:
		
		move $v0, $t2
		
		#pop ra from stack
		lw	$ra, 4($sp)
		add	$sp, $sp, 4
		jr	$ra

#----------------------------acceptance function--------------------------------------------
	probabilityFunction:
		#deltaF in f0
		#result in f11
		#push ra onto stack
		sub 	$sp, $sp, 4
		sw	$ra, 4($sp)
		
		mov.s	$f1, $f0	#f1 <- deltaF
		div.s	$f1, $f1, $f31	#f1 <- deltaF / T
		cvt.w.s	$f4, $f1	#f4 <- converted deltaF / T
		cvt.s.w $f2, $f4	#f2 <- [deltaF / T]
		sub.s	$f3, $f1, $f2	#f3 <- (deltaF / T)
		cvt.w.s $f4, $f2	#f4 <- converted [deltaF / T]
		mfc1	$t1, $f4	#t1 <- INT([deltaF / T])
		la	$a1, e
		l.s	$f4, ($a1)	#f4 <- e
		la	$a1, float_one
		l.s	$f5, ($a1)
		
		#Currently:
		#f0 - deltaF
		#f1 - deltaF / T
		#f2 - [deltaF / T]
		#f3 - (deltaF / T)
		#f4 - e
		#f5 - 1
	powIntPart:
		#this part calculates the power of e to the integer part of deltaF / T
		beqz 	$t1, powFloatPart
		subi	$t1, $t1, 1
		mul.s	$f5, $f5, $f4
		j	powIntPart
		
	powFloatPart:
		#this part approximates the power of e to the fractional part of deltaF / T
		
		la	$a1, float_zero
		l.s	$f7, ($a1)	#f7 <- 0.0
		la	$a1, threshold
		l.s	$f8, ($a1)	#f8 <- threshold
		
	#0.0 - 0.1
	point_1_test:
		la 	$a1, point_1
		l.s	$f6, ($a1)	#f6 <- 0.1
		sub.s	$f9, $f6, $f3	#f9 <- 0.1 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_2_test	#if 0.1 - (deltaF / T) < 0 go to 0.2
		c.lt.s	$f9, $f8
		bc1t	point_1_more_than_th
		#0.0 < (deltaF / T) < 0.05
		la	$a1, float_one
		l.s	$f10, ($a1)
		j	endMultPart
	point_1_more_than_th:
		#0.05 < (deltaF / T) < 0.1
		la	$a1, exp01
		l.s	$f10, ($a1)
		j	endMultPart
	
	#0.1 - 0.2
	point_2_test:
		la 	$a1, point_2
		l.s	$f6, ($a1)	#f6 <- 0.2
		sub.s	$f9, $f6, $f3	#f9 <- 0.2 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_3_test	#if 0.2 - (deltaF / T) < 0 go to 0.3
		c.lt.s	$f9, $f8
		bc1t	point_2_more_than_th
		#0.1 < (deltaF / T) < 0.15
		la	$a1, exp01
		l.s	$f10, ($a1)
		j	endMultPart
	point_2_more_than_th:
		#0.15 < (deltaF / T) < 0.2
		la	$a1, exp02
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.2 - 0.3
	point_3_test:
		la 	$a1, point_3
		l.s	$f6, ($a1)	#f6 <- 0.3
		sub.s	$f9, $f6, $f3	#f9 <- 0.3 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_4_test	#if 0.3 - (deltaF / T) < 0 go to 0.4
		c.lt.s	$f9, $f8
		bc1t	point_3_more_than_th
		#0.2 < (deltaF / T) < 0.25
		la	$a1, exp02
		l.s	$f10, ($a1)
		j	endMultPart
	point_3_more_than_th:
		#0.25 < (deltaF / T) < 0.3
		la	$a1, exp03
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.3 - 0.4
	point_4_test:
		la 	$a1, point_4
		l.s	$f6, ($a1)	#f6 <- 0.4
		sub.s	$f9, $f6, $f3	#f9 <- 0.4 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_5_test	#if 0.4 - (deltaF / T) < 0 go to 0.5
		c.lt.s	$f9, $f8
		bc1t	point_4_more_than_th
		#0.3 < (deltaF / T) < 0.35
		la	$a1, exp01
		l.s	$f10, ($a1)
		j	endMultPart
	point_4_more_than_th:
		#0.35 < (deltaF / T) < 0.4
		la	$a1, exp04
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.4 - 0.5
	point_5_test:
		la 	$a1, point_5
		l.s	$f6, ($a1)	#f6 <- 0.5
		sub.s	$f9, $f6, $f3	#f9 <- 0.5 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_6_test	#if 0.5 - (deltaF / T) < 0 go to 0.6
		c.lt.s	$f9, $f8
		bc1t	point_5_more_than_th
		#0.4 < (deltaF / T) < 0.45
		la	$a1, exp01
		l.s	$f10, ($a1)
		j	endMultPart
	point_5_more_than_th:
		#0.45 < (deltaF / T) < 0.5
		la	$a1, exp05
		l.s	$f10, ($a1)
		j	endMultPart
	
	#0.5 - 0.6
	point_6_test:
		la 	$a1, point_6
		l.s	$f6, ($a1)	#f6 <- 0.6
		sub.s	$f9, $f6, $f3	#f9 <- 0.6 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_7_test	#if 0.6 - (deltaF / T) < 0 go to 0.7
		c.lt.s	$f9, $f8
		bc1t	point_6_more_than_th
		#0.5 < (deltaF / T) < 0.55
		la	$a1, exp05
		l.s	$f10, ($a1)
		j	endMultPart
	point_6_more_than_th:
		#0.55 < (deltaF / T) < 0.6
		la	$a1, exp06
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.6 - 0.7
	point_7_test:
		la 	$a1, point_7
		l.s	$f6, ($a1)	#f6 <- 0.7
		sub.s	$f9, $f6, $f3	#f9 <- 0.7 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_8_test	#if 0.7 - (deltaF / T) < 0 go to 0.8
		c.lt.s	$f9, $f8
		bc1t	point_7_more_than_th
		#0.6 < (deltaF / T) < 0.65
		la	$a1, exp06
		l.s	$f10, ($a1)
		j	endMultPart
	point_7_more_than_th:
		#0.65 < (deltaF / T) < 0.7
		la	$a1, exp07
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.7 - 0.8
	point_8_test:
		la 	$a1, point_8
		l.s	$f6, ($a1)	#f6 <- 0.8
		sub.s	$f9, $f6, $f3	#f9 <- 0.8 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_9_test	#if 0.8 - (deltaF / T) < 0 go to 0.9
		c.lt.s	$f9, $f8
		bc1t	point_8_more_than_th
		#0.7 < (deltaF / T) < 0.75
		la	$a1, exp07
		l.s	$f10, ($a1)
		j	endMultPart
	point_8_more_than_th:
		#0.75 < (deltaF / T) < 0.8
		la	$a1, exp08
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.8 - 0.9
	point_9_test:
		la 	$a1, point_9
		l.s	$f6, ($a1)	#f6 <- 0.9
		sub.s	$f9, $f6, $f3	#f9 <- 0.9 - (deltaF / T)
		c.le.s	$f9, $f7
		bc1t	point_10_test	#if 0.9 - (deltaF / T) < 0 go to 1.0
		c.lt.s	$f9, $f8
		bc1t	point_9_more_than_th
		#0.8 < (deltaF / T) < 0.85
		la	$a1, exp08
		l.s	$f10, ($a1)
		j	endMultPart
	point_9_more_than_th:
		#0.85 < (deltaF / T) < 0.9
		la	$a1, exp09
		l.s	$f10, ($a1)
		j	endMultPart
		
	#0.9 - 1.0
	point_10_test:
		la 	$a1, float_one
		l.s	$f6, ($a1)	#f6 <- 1.0
		sub.s	$f9, $f6, $f3	#f9 <- 1.0 - (deltaF / T)
		c.lt.s	$f9, $f8
		bc1t	point_10_more_than_th
		#0.9 < (deltaF / T) < 0.95
		la	$a1, exp09
		l.s	$f10, ($a1)
		j	endMultPart
	point_10_more_than_th:
		#0.95 < (deltaF / T) < 1.0
		la	$a1, e
		l.s	$f10, ($a1)
		j	endMultPart
	
	endMultPart:
		#the integer part times the aproximated fractional part equals the aproximation of e^(deltaF / T)
		#f5 contains e ^ [deltaF / T]
		#f10 contains an aproximation of e ^ (deltaF / T)
		#e ^ deltaF / T = f5 * f10
		mul.s	$f10, $f10, $f5 	#f10 <- e ^ deltaF / T
		#the exponent is negative
		la	$a1, float_one
		l.s	$f11, ($a1)
		div.s	$f11, $f11, $f10 	#f11 <- 1 / (e ^ deltaF / T)
		
		#pop ra from stack
		lw	$ra, 4($sp)
		add	$sp, $sp, 4
		jr	$ra
		

#-----------------------------cooling schedule----------------------------------------------
	updateTemp:
		#result in f0
		#current temp in f31
		#push ra onto stack
		sub 	$sp, $sp, 4
		sw	$ra, 4($sp)
		
		la	$a1, coolingRate
		l.s	$f30, ($a1)
		mul.s	$f0, $f30, $f31
		
		#pop ra from stack
		lw	$ra, 4($sp)
		add	$sp, $sp, 4
		jr	$ra
	
#-----------------------------read random number--------------------------------------------
	readRand:	
		#result in v0
		#push ra onto stack
		sub 	$sp, $sp, 4
		sw	$ra, 4($sp)
		
		li	$s7, 0
	cat:
		#build number until space is met:
		jal	read
		lb	$t1, spaceChr
		lb	$t2, buffer
		beq	$t1, $t2, endReadRand
		lb	$t1, zeroChr
		sub	$t2, $t2, $t1
		li	$t3, 10
		mul	$s7, $s7, $t3
		mflo	$s7
		add	$s7, $s7, $t2
		j	cat
	endReadRand:
		add	$v0, $zero, $s7
		#pop ra from stack
		lw	$ra, 4($sp)
		add	$sp, $sp, 4
		jr	$ra

#--------------------------------read digit-----------------------------------------------------
	read:
		#push ra onto stack
		sub 	$sp, $sp, 4
		sw	$ra, 4($sp)
		
		#read from file opened
		li   	$v0, 14        	# system call for reading from file
		move 	$a0, $s0       	# file descriptor 
		la   	$a1, buffer    	# address of buffer from which to read
		li   	$a2,  1  	# hardcoded buffer length
		syscall             	# read from file
		
		#pop ra from stack
		lw	$ra, 4($sp)
		add	$sp, $sp, 4
		jr	$ra
#----------------------------------------------------------------------------------------------
