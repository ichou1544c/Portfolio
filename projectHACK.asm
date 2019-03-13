#Hackathon for CS 3340 Computer Architecture – Spring 2019 – Mazidi
#Hackathon Challenge:
#Objective:  Write code to display the number of days, given the month 
#814CK0Y573R-Isaac Chou
#https://github.com/ichou1544c
#Start: 17:00 CDT(UTC-5) 13.3.2019
#End: 17:51 CDT(UTC-5) 13.3.2019
.data
	#------LISTS-------
	#First 4 is 30, next 7 is 31, last one is 28
	CaseTB:	.word 4,6,9,11,1,3,5,7,8,10,12,2
	
	#This is lucky, since these characters null are all 4 letters long, no need to align to word.
	CaseAT:	.asciiz "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	
	#$t0 is the case condition/number of days (30,31,28)
	#$s0 is the month number
	#$s1 is the month switch (0 for number, 1 for abbreviation)
	
	ErrMsg: .asciiz "Month must be between 1 and 12\n"
	OpMsg:	.asciiz "Welcome to the months and days program.\n"
	OpAllc:	.asciiz "Press 1 for month number, 2 for month abbreviation: "
	InMsg:	.asciiz	"Please enter the month 1-12, enter 0 to quit: "
	OtMsg1:	.asciiz "Number of days in the month "
	OtMsg2:	.asciiz " is: "
	NLine:	.asciiz "\n"
.text

#Start of the program, welcomes the user, and asks for the type of message to give, (# or abv.)
main:
	la $a0, OpMsg
	li $v0, 4
	syscall			#Prints welcoming message
	
	la $a0, OpAllc
	li $v0, 4
	syscall			#Asks for input (month switch)
	li $v0, 5
	syscall			#Reads the integer input
	
	add $s1, $v0, -1	#Sets the month switch ($s1) (ibid line 18)
				#(0 for number, 1 for abbreviation)

#Takes the user input for the month number	
input:
	la $a0, InMsg
	li $v0, 4
	syscall			#Asks for input (month number)
	li $v0, 5
	syscall			#Reads the integer input

	move $s0, $v0 		#$s0 is the month number
	
#Checks for errors or exit
condition:	
	#eExit if zero is entered
	beqz $s0, exit
	
	#Not 1-12, then error
	blt $s0, $zero, err	
	bgt $s0, 12, err	#Throws error when <0 or >12

#Runs the case switch algorithm
switch:
	la $t1, CaseTB		#Load the address of the list of cases

	#Loop to set $t1 to the address of the month number word
	loop:
		lw $t3, ($t1)
		beq $t3, $s0, set	#Exit when the case is found
		add $t1, $t1, 4		#Iterate to next item/word
		j loop			#Reloop until case is found
	
	#Coordinates the case instructions: does according to the order of the case
	set:
		la $t2, CaseTB+12	#Points to the 4th item in the case table
		la $t3, CaseTB+44	#Points to the 11th item in the case table
		sgt $t4, $t1, $t2	
		beqz $t4, st30		#Branches to set $t0 to 30 if it is one of the first 4
		slt $t4, $t1, $t3
		beqz $t4, st28		#Branches to set $t0 to 31 if it is the last (Feb)
		
	#Set # days to 31
	st31:
		li $t0, 31
		j output
		
	#Set # days to 30
	st30:
		li $t0, 30
		j output
		
	#Set # days to 28
	st28:
		li $t0, 28

#Sends the output to console
output:
	la $a0, OtMsg1
	li $v0, 4
	syscall			#Prints output message 1
	
	beqz $s1, outNum
	
	#Prints the month abbreviation
	outAbr:
		la $t1, CaseAT 		#Loads address for name list
		mul $t2, $s0, 4		#Align the month number to words
		add $t1, $t1, $t2	#Move down the list for the number of month times
		add $a0, $t1, -4	#Move back since iterator starts at 0, and month number 1
		li $v0, 4
		syscall			#Prints month abbreviation
		
		j outP2			#Finishes output
		
	#Prints the month number
	outNum:
		move $a0, $s0
		li $v0, 1
		syscall			#Prints month number
		
		j outP2			#Finishes output

	#Rest of the output
	outP2:
		la $a0, OtMsg2
		li $v0, 4
		syscall			#Prints output message 2	
	
		move $a0, $t0
		li $v0, 1
		syscall			#Prints number of days
		
		la $a0, NLine
		li $v0, 4
		syscall			#Prints new line
	
		j input 		#Jumps to input

#Prints error message and repeat from input
err:
	la $a0, ErrMsg
	li $v0, 4
	syscall			#Prints error message
	
	j input			#Returns to input

#Exits the program
exit:
	li $v0, 10
	syscall			#Exit syscall