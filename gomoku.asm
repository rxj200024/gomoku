#Gomoku Project
		.data

input:		.word 1	#holds user string. Ex: L14
inputCol:	.word 0 #holds column number
inputRow:	.word 0 #holds row number
loading:	.asciiz " \n\n ##::::::::'#######:::::'###::::'########::'####:'##::: ##::'######:::\n ##:::::::'##.... ##:::'## ##::: ##.... ##:. ##:: ###:: ##:'##... ##::\n ##::::::: ##:::: ##::'##:. ##:: ##:::: ##:: ##:: ####: ##: ##:::..:::\n ##::::::: ##:::: ##::'##:. ##:: ##:::: ##:: ##:: ####: ##: ##:::..:::\n ##::::::: ##:::: ##:'##:::. ##: ##:::: ##:: ##:: ## ## ##: ##::'####:\n ##::::::: ##:::: ##: #########: ##:::: ##:: ##:: ##. ####: ##::: ##::\n ##::::::: ##:::: ##: ##.... ##: ##:::: ##:: ##:: ##:. ###: ##::: ##::\n ########:. #######:: ##:::: ##: ########::'####: ##::. ##:. ######:::\n\n"
topRow:		.asciiz "   A B C D E F G H I J K L M N O P Q R S\n"
versus:		.asciiz "     X/You         vs.       O/Computer   \n\n"
nl:		.asciiz "\n" #newline
np:		.asciiz "\n" #newpage
space:		.asciiz " "
empty:		.asciiz " ."
X:		.asciiz " X"
O:		.asciiz " O"
asterisks:	.asciiz "* * * * *\n* GOMOKU *\n* * * * *\n"
gomoku:		.asciiz "\nWelcome to Gomoku"
instructions:	.asciiz "Gomoku: Connect 5 in a row to win!\nInput must be capitalized with no spaces in between\nA-S and 1-19 represent columns and rows respectively.\nEx: K7, F14\n"
cont:		.asciiz "\nPress any key to continue:"
cont1:		.asciiz " "
prompt:		.asciiz "\nMove? "
playAgain:	.asciiz "\n\nPlay Again (y = yes, n = any key)? "
outOfBounds:	.asciiz "Illegal move. Make sure input is uppercase and within A-S and 1-19 values. Ex:K7, F14\n"
takenSpot:	.asciiz "Illegal move. Spot is already taken"
userWinnerStr:	.asciiz "\t          You won!"
computerWinnerStr: .asciiz "	Computer won :("
moves:		.asciiz "\n\t       Total Moves: "
userWins:	.asciiz "\n\t	    User Wins: "
		.align 2 
boardArray:	.space	1444 #19x19=361 spaces, 361x4=1444 bytes of memory
		.text

main:	
		li $v0, 4
	la $a0, loading # instructions
	syscall


	li $v0, 4
	la $a0, instructions # instructions
	syscall

	
	li $v0, 4
	la $a0, cont	# "press any key to continue"
	syscall
	
	li $v0, 12
	la $a0, cont1	# read enter
	syscall
	
	li $v0, 4
	la $a0, nl	
	syscall
	
	jal initializeBoard #fill the array with zeros (zeros represent dots)
	jal printBoard	#print the initial state of the board
	
	jal startingTune
	
	li $s0, 1	#player 1 marker
	li $s1, 2	#computer marker
	li $s3, 0	#amount of moves throughout the game


	jal playGame	#start the game


	
	#li $v0, 10	#end program
	#syscall		
#---------------------------------------------------------------------------------------------
initializeBoard:
	li $t2, 0	#choose to fill the array with . * or o, using 0, 1, or 2
	li $t0, 0	#start the counter at 0
	li $t1, 0	#increment by 4 to get each int in array
	iwhile:	
		sw $t2, boardArray($t1)	#place int in array
		addi $t0, $t0, 1	#increment counter by 1
		addi $t1, $t1, 4	#increment to next element in array
		bne $t0, 361, iwhile
	jr $ra
#---------------------------------------------------------------------------------------------
printBoard:	
	li $t0, 0  #holds effective address in memory of array index (increment by 4)
	li $t1, 0  #rowLoop counter
	li $t2, 0  #columLoop counter
	li $t3, 19 #t3 will keep track of the rows, starting at 19
	li $t4, 0  #hold actual value in array element
	
	li $v0, 4	#
	la $a0, topRow	#print "A B C D ...."
	syscall		#
	
	rowLoop:
		beq $t1, 19, endRowLoop #condition to end rowLoop
		bge $t3, 10, noSpace
			li $v0, 4	#
			la $a0, space	#print an extra space for values less than 10 so the board is aligned correctly
			syscall		#
		noSpace:
		li $v0, 1		#
		add $a0, $t3, $zero	#print row # on the left
		syscall			#
		columnLoop:
			beq $t2, 19, endColumnLoop #condition to end columnLoop
			#following section will print . * or o depending on values in array
			#-----------------------------------------------------------------------
			lw $t4, boardArray($t0)	#get value at current index and place it into t4
			
			bne $t4, 0, no0	# if t4 is 0 run code below, if not equal to 0, jump to no0
			li $v0, 4	#
			la $a0, empty	#print .
			syscall		#
			j done
			no0:
				bne $t4, 1, no1	# if t4 is 1, run code below, if not equal to 1, jump to no1
				li $v0, 4	#
				la $a0, X	#print X
				syscall		#
				j done
			no1:			# t4 wasn't 0 or 1 so print o
				li $v0, 4	#
				la $a0, O	#print O
				syscall		#
				j done
			done:
				addi $t2, $t2, 1	#increment colum counter by 1
				addi $t0, $t0, 4	#increment effective address counter by 4
			#---------------------------------------------------------------------------
			j columnLoop
		endColumnLoop:
		li $t2, 0 #reset column counter back to 0
		
		li $v0, 4	
		la $a0, space	#print an extra space before the row # on the right
		syscall	
		
		li $v0, 1		
		add $a0, $t3, $zero	#print row # on the right
		syscall			
		
		li $v0, 4	
		la $a0, nl	# new line
		syscall		
		
		sub $t3, $t3, 1	#subtract row tracker by 1, so 19, 18, 17, 16,...
		add $t1, $t1, 1 #increment rowLoop counter by 1
		j rowLoop
	endRowLoop:
	li $v0, 4	
	la $a0, topRow	#print "A B C D ...." as the last row of our board
	syscall
	li $v0, 4
	la $a0, versus # versus display
	syscall		
	jr $ra
#---------------------------------------------------------------------------------------------------------
userMove:	
	li $t9, 1 	#since 1 = *, we place a 1 wherever the user chooses to play, t9 should not change
	li $t8, 19	#multiply t1 by this to get the correct row
	li $t7, 4	#multiply index by this to get effective address of index in memory

	li $v0, 4
	la $a0, prompt
	syscall

	li $v0, 8	
	la $a0, input     #read string from user, and put into memory starting at input address 
	la $a1, 5	
	syscall
	#-----------Get the column number--------------

		

	li $t0, 0
	lb  $t1, input($t0)     #Say input is L14, then t1 holds L=64
	blt $t1, 65, outOfBoundsInput	# branch to beginning if $t1 is less than 65
	bgt $t1, 90, outOfBoundsInput	# branch to beginning if $t1 is greater than 90
	
	sub $t2, $t1, 65	#subtract decimal value by 65 to get row #, Ex: 76-65=12th col
	
	sw $t2, inputCol

	bge $t2, 19, outOfBoundsInput 
	#-----------Get the row number--------------
	lw $t6, input
	li $t0, 1
	lb $t1, input($t0)     #Say input is L14, then t1 holds 1
	li $t0, 2
	lb $t2, input($t0) #Say input is L14, then t2 holds 4
	

	
	# ex B1, $t3 = 1, $t4 = 1
	#sgtu $t6, $t2, 47 # if $t2, is nl, $t6 will be 0, else 1
	#seq $t7, $t1, 49
	slti $t3, $t2, 48 # we are checking if $t2 is endline or not, ex: nl = 10 and 0 = 48, if $t2 is 0 (48), $t3 = 0
	seq $t4, $t1, 49 # if $t1 is equal to 49, then $t4 will be 1
	seq $t5, $t1, 48 # if $t1 is equal to 0, then $t5 will be 1
	
	beq $t5, 1, outOfBoundsInput

	# test
	#li $v0, 1
	#move $a0, $t2
	#syscall

	#li $v0, 1
	#move $a0, $t1
	#syscall

	# input move into movesArray
	#sw $t6, movesArray($s7)
	addi $s7, $s7, 4

	#bne $t6, $t7 continue
	beq $t3, $t4 outOfBoundsInput   	

	# test
	#li $v0, 1
	#move $a0, $t1
	#syscall

	#li $v0, 1
	#move $a0, $t2
	#syscall
	
	#beq $t1, 0, outOfBoundsInput
	#continue:
	beq $t2, 10, single
	#----------------Double Digit----------------------
	li $t3, 57
	li $t4, 0
	doubleDigit:
		beq $t2, $t3, endDoubleDigit
		sub $t3, $t3, 1
		add $t4, $t4, 1
		j doubleDigit
	endDoubleDigit:
	
	sw $t4, inputRow
	
	j calculateIndex
	#----------------Single Digit----------------------
	single:
	li $t3, 67     #if you want to get to row at 4, (4=52), go from 67 to 52 to have counter be 15 for 15th row
	li $t4, 0     #counter to know the actual row #
	singleDigit:
		beq $t1, $t3, endSingleDigit
		sub $t3, $t3, 1
		add $t4, $t4, 1
		j singleDigit
	endSingleDigit:
	
	sw $t4, inputRow

	bge $t4, 19, outOfBoundsInput	
	
	calculateIndex:
	lw $t1, inputRow
	lw $t3, inputCol
	
	mul $t5, $t1, $t8  #multiply first # by 19 to get the row you're in
	add $t5, $t5, $t3 #add col # to get exact position in board
	
	mul $t5, $t5, $t7   # multiply t5 by 4 to get effective address in the array
	
	lw $t6, boardArray($t5)		#get value at current index
	bne $zero, $t6, spotTaken	#if there is already something in this spot promt user for coords again

	addi $s3, $s3, 1	# increment amount of moves 
	sw $t9, boardArray($t5)	# put a 1 into exact element in array
	jr $ra
 


#---------------------------------------------------------------------------------------------------------
computerMove:
	li $t0, 0 # t0 will hold the random number
	li $t1, 2 # computer is represented by 2 in the array (O)
	
	li $v0, 42
	li $a1, 361	# generate a random number from 0 to 361, which will be the index in the array
	syscall
	move $t0, $a0	# move random # into t0
	
	sll $t0, $t0, 2 # multiply t0 by 4 to get effective address in memory
	
	lw $t2, boardArray($t0)	 # if there is already something in this spot promt user for coords. again
	bne $zero, $t2, computerMove
	
	addi $s3, $s3, 1	
	sw $t1, boardArray($t0)	# store 2 (computer move) into array
	jr $ra
#---------------------------------------------------------------------------------------------------------
playGame:
	li $t0, 0	#start the counter at 0
	li $t2, 0
	newWhile:	
		beq $t0, 361, endNewWhile 
		jal userMove
		jal checkUser
		jal printBoard
		jal computerMove
		jal printBoard
		addi $t0, $t0, 1	#increment counter by 1
		j  newWhile
	endNewWhile:
	jr $ra
#---------------------------------------------------------------------------------------------------------
outOfBoundsInput:
	li $v0, 4
	la $a0, outOfBounds
	syscall
	j userMove
#---------------------------------------------------------------------------------------------------------
spotTaken:
	li $v0, 4
	la $a0, takenSpot
	syscall
	j userMove
#---------------------------------------------------------------------------------------------------------
#loop till end of board 
checkUser:
	addi $sp, $sp, -4	# decrement stack pointer to begin 
	sw $ra, 0($sp)
	li $t7, 0	# loop till last element of board
	li $t8, 0	# current index

	beginUserLoop:
		lw $t3, boardArray($t8)		
		beq $t7, 360, loopComplete
		beq $s0, $t3, checkUserConditions
		bne $s0, $t3, continueUserLoop
		checkUserConditions:
					move $a1, $t8	
					jal checkStraightAcross
					jal checkStraightDown
					jal checkDiagonalRight	# need to add checkDiagonalLeft
					jal checkDiagonalLeft
		continueUserLoop: 
		addi $t8, $t8, 4
		addi $t7, $t7, 1

		j beginUserLoop

	loopComplete:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#---------------------------------------------------------------------------------------------------------
# check straight across (user)
checkStraightAcross:
	
	li $t6, 19	# load 19 to divide by $t5 to check if check win state is necessary
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t4, $a1, 0
	# check if comparison can be made
	div $t5, $t4, 4		# i.e $a1 = 1440, 1440/4 = 360 = $t0
	div $t5, $t6
	mfhi $t5
	bge $t5, 16, isNotEqualAcross
	
	li $t6, 0	#once $t0 reaches 5, return winner

	loopAcross:
		lw $t2, boardArray($t4)		# load value of boardArray($t4) into $t3
		beq $t6, 5, userWinner	# if $t0 = 5, user is win
		bne $s0, $t2, isNotEqualAcross	# branch out if not equal
		addi $t4, $t4, 4		# add to compare next element
		addi $t6, $t6, 1		# increment $t0
		j loopAcross			# loop over
	isNotEqualAcross:
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra	
#---------------------------------------------------------------------------------------------------------
# check straight down (user)
checkStraightDown:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0	#once $t0 reaches 5, return winner
	li $t2, 5	#max required to win
	add $t4, $a1, $zero
	
	loopDown:
		lw $t3, boardArray($t4)		# load value of boardArray($t4) into $t3
		beq $t0, $t2, userWinner	# if $t0 = 5, user is win
		bne $s0, $t3, isNotEqualDown	# branch out if not equal
		addi $t4, $t4, 76		# add to compare next element
		addi $t0, $t0, 1		# increment $t0
		j loopDown			# loop over
	isNotEqualDown:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra	
#---------------------------------------------------------------------------------------------------------
# check diagonal right (user)
checkDiagonalRight:
	addi $sp, $sp, -4	#decrement stack pointer to return eventually
	sw $ra, 0($sp)
	li $t0, 0	#once $t0 reaches 5, return winner
	li $t2, 5	#max required to win
	add $t4, $a1, $zero
	
	loopDiagonalRight:
		lw $t3, boardArray($t4)			# load value of boardArray($t4) into $t3
		beq $t0, $t2, userWinner		# if $t0 = 5, user is win
		bne $s0, $t3, isNotEqualDiagonalRight	# branch out if not equal
		addi $t4, $t4, 80			# add to compare next element
		addi $t0, $t0, 1			# increment $t0
		j loopDiagonalRight				# loop over
	isNotEqualDiagonalRight:
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra	
#----------------------------------------------------------------------------------------------------------
# check diagonal left (user)
checkDiagonalLeft:
	addi $sp, $sp, -4	#decrement stack pointer to return eventually
	sw $ra, 0($sp)
	li $t0, 0	#once $t0 reaches 5, return winner
	li $t2, 5	#max required to win
	add $t4, $a1, $zero
	
	loopDiagonalLeft:
		lw $t3, boardArray($t4)			# load value of boardArray($t4) into $t3
		beq $t0, $t2, userWinner		# if $t0 = 5, user is win
		bne $s0, $t3, isNotEqualDiagonalLeft	# branch out if not equal
		addi $t4, $t4, 72			# add to compare next element
		addi $t0, $t0, 1			# increment $t0
		j loopDiagonalLeft			# loop over
	isNotEqualDiagonalLeft:
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra 
#----------------------------------------------------------------------------------------------------------
userWinner:
	jal printBoard				# if user is winner, print board again and jump to exit
	li $v0, 4
	la $a0, userWinnerStr
	syscall
	
	li $v0, 4
	la $a0, moves
	syscall

	li $v0, 1
	move $a0, $s3		# display total moves 
	syscall 		



# play Again option
	li $v0, 4
	la $a0, playAgain # instructions
	syscall

	li   $v0, 12       
  	syscall            # Read Character
	move $t1, $v0 

	li $v0, 4
	la $a0, nl # instructions
	syscall

  	beq $t1,121  main



	j exit
#----------------------------------------------------------------------------------------------------------

#loop till end of board 
checkComputer:
	addi $sp, $sp, -4	# decrement stack pointer to begin 
	sw $ra, 0($sp)
	li $t7, 0	# loop till last element of board
	li $t8, 0	# current index

	beginComputerLoop:
		lw $t3, boardArray($t8)		
		beq $t7, 360, loopComplete
		beq $s0, $t3, checkComputerConditions
		bne $s0, $t3, continueComputerLoop
		checkComputerConditions:
					move $a1, $t8	
					jal checkStraightAcrossComputer
					jal checkStraightDownComputer
					jal checkDiagonalRightComputer	# need to add checkDiagonalLeft
					jal checkDiagonalLeftComputer
		continueComputerLoop: 
		addi $t8, $t8, 4
		addi $t7, $t7, 1

		j beginComputerLoop

	loopCompleteComputer:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#---------------------------------------------------------------------------------------------------------
# check straight across (computer)
checkStraightAcrossComputer:
	
	li $t6, 19	# load 19 to divide by $t5 to check if check win state is necessary
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t4, $a1, 0
	# check if comparison can be made
	div $t5, $t4, 4		# i.e $a1 = 1440, 1440/4 = 360 = $t0
	div $t5, $t6
	mfhi $t5
	bge $t5, 16, isNotEqualAcrossComputer
	
	li $t6, 0	#once $t0 reaches 5, return winner

	loopAcrossComputer:
		lw $t2, boardArray($t4)		# load value of boardArray($t4) into $t3
		beq $t6, 5, computerWinner	# if $t0 = 5, user is win
		bne $s0, $t2, isNotEqualAcross	# branch out if not equal
		addi $t4, $t4, 4		# add to compare next element
		addi $t6, $t6, 1		# increment $t0
		j loopAcrossComputer			# loop over
	isNotEqualAcrossComputer:
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra	
#---------------------------------------------------------------------------------------------------------
# check straight down (computer)
checkStraightDownComputer:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0	#once $t0 reaches 5, return winner
	li $t2, 5	#max required to win
	add $t4, $a1, $zero
	
	loopDownComputer:
		lw $t3, boardArray($t4)		# load value of boardArray($t4) into $t3
		beq $t0, $t2, computerWinner	# if $t0 = 5, user is win
		bne $s0, $t3, isNotEqualDown	# branch out if not equal
		addi $t4, $t4, 76		# add to compare next element
		addi $t0, $t0, 1		# increment $t0
		j loopDownComputer			# loop over
	isNotEqualDownComputer:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra	
#---------------------------------------------------------------------------------------------------------
# check diagonal right (computer)
checkDiagonalRightComputer:
	addi $sp, $sp, -4	#decrement stack pointer to return eventually
	sw $ra, 0($sp)
	li $t0, 0	#once $t0 reaches 5, return winner
	li $t2, 5	#max required to win
	add $t4, $a1, $zero
	
	loopDiagonalRightComputer:
		lw $t3, boardArray($t4)			# load value of boardArray($t4) into $t3
		beq $t0, $t2, computerWinner		# if $t0 = 5, user is win
		bne $s0, $t3, isNotEqualDiagonalRight	# branch out if not equal
		addi $t4, $t4, 80			# add to compare next element
		addi $t0, $t0, 1			# increment $t0
		j loopDiagonalRight				# loop over
	isNotEqualDiagonalRightComputer:
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra	
#----------------------------------------------------------------------------------------------------------
# check diagonal left (computer)
checkDiagonalLeftComputer:
	addi $sp, $sp, -4	#decrement stack pointer to return eventually
	sw $ra, 0($sp)
	li $t0, 0	#once $t0 reaches 5, return winner
	li $t2, 5	#max required to win
	add $t4, $a1, $zero
	
	loopDiagonalLeftComputer:
		lw $t3, boardArray($t4)			# load value of boardArray($t4) into $t3
		beq $t0, $t2, userWinner		# if $t0 = 5, user is win
		bne $s0, $t3, isNotEqualDiagonalLeft	# branch out if not equal
		addi $t4, $t4, 72			# add to compare next element
		addi $t0, $t0, 1			# increment $t0
		j loopDiagonalLeftComputer			# loop over
	isNotEqualDiagonalLeftComputer:
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra 
#----------------------------------------------------------------------------------------------------------
# check winner (computer)
computerWinner:
	jal printBoard				# if user is winner, print board again and jump to exit
	li $v0, 4
	la $a0, computerWinnerStr
	syscall
	
	li $v0, 4
	la $a0, moves
	syscall

	li $v0, 1
	move $a0, $s3		# display total moves 
	syscall 		


	j exit

#----------------------------------------------------------------------------------------------------------
startingTune:
	li $a2, 0	#a2 holds instrument (0 = Piano)
	li $a3, 50	#a3 holds volume
	
	li $a0, 56	#G#4
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 200 		
	la $v0, 32 		
	syscall
	
	li $a0, 60	#C5
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 62	#D5
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 65	#F5
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 68	#G#5
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 72	#C6
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 74	#D6
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 77	#F6
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 80	#G#6
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 84	#C7
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	
	li $a0, 86	#D7
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 
	li $a0, 82	#A#6
	li $a1, 2000 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 
	li $a0, 100 		
	la $v0, 32 		
	syscall			
	jr $ra

#----------------------------------------------------------------------------------------------------------
exit:
	li $a2, 0	#a2 holds instrument (0 = Piano)
	li $a3, 50	#a3 holds volume
	#-------------First Pair------------------G4 A4 B4 C#5
	li $a0, 55	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 57	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 59	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 61	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 55	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 57	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 59	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 61	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------Second Pair------------------G#4 A#4 C5 D5
	li $a0, 56	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 58	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 60	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 62	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 56	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 58	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 60	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 62	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------Third Pair------------------A4 B4 C#5 D#5
	li $a0, 57	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 59	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 61	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 63	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 57	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 59	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 61	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 63	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------Fourth Pair------------------A#4 C5 D5 E5
	li $a0, 58	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 60	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 62	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 64	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 58	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 60	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 62	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 64	#a0 holds pitch
	li $a1, 5000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------First Step------------------B4 C#5 D#5 F5
	li $a0, 59	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 61	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 63	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 65	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------Second Step------------------C5 D5 E5 F#5
	li $a0, 60	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 62	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 64	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 66	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------Third Step------------------C#5 D#5 F5 G5
	li $a0, 61	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 63	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 65	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 67	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	#-------------Fourth Step------------------D5 E5 F#5 G#5
	li $a0, 62	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 64	#a0 holds pitch
	li $a1, 900 	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 66	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 100 		
	la $v0, 32 		
	syscall
	li $a0, 68	#a0 holds pitch
	li $a1, 1000	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall 		
	li $a0, 400 	#wait like 2 extra seconds	
	la $v0, 32 		
	syscall
	#-------------A5------------------
	li $a0, 69	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall 
	li $a0, 75	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall	
	li $a0, 81	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall	
	li $a0, 200 		
	la $v0, 32 		
	syscall
	#-------------A#5------------------
	li $a0, 70	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall
	li $a0, 76	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall	
	li $a0, 82	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall 		
	li $a0, 200 		
	la $v0, 32 		
	syscall
	#-------------B5------------------
	li $a0, 71	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall
	li $a0, 77	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall	
	li $a0, 83	#a0 holds pitch
	li $a1, 400	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall 		
	li $a0, 200 		
	la $v0, 32 		
	syscall
	#-------------C6------------------
	li $a0, 72	#a0 holds pitch
	li $a1, 1300	#a1 holds duration in milliseconds 
	la $v0, 31 		
	syscall
	li $a0, 78	#a0 holds pitch
	li $a1, 1300	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall	
	li $a0, 84	#a0 holds pitch
	li $a1, 1300	#a1 holds duration in milliseconds
	la $v0, 31 		
	syscall  
			
	li $v0, 10
	syscall
