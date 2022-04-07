# Sam Schaeffler

.data 					#change read/write data but not executable

inputPrompt:        .asciiz "Please enter an expression to evaluated: \n"
input:              .space 265
postfix:            .space 265
jujutsu:            .space 265
originalExpr:       .asciiz "Original Expression: \n"
postfixPrompt:      .asciiz "Infix to postfix expression: \n"
evaluatedPrompt:    .asciiz "Evaluated expression: \n"
newLine:	        .asciiz	"\n"
equal:              .asciiz ""
equalz:             .asciiz ""
plus:               .asciiz "+"
minus:              .asciiz "-"

.text 					# contains readable and executable data -> instructions

.globl main 			# this is where the code starts
main:
# s0 = original expression (infix)
# s1 = postfix expression (infix to postfix)
# s2 = evaluated expression
# s3 = length of input(infix) & postfix

## 		  M A I N 		 ##
##############################################################################

# display prompt "Please enter an expression to evaluated:"
	li	$v0, 4			    # code for print_string
	la	$a0, inputPrompt    # point $a0 to prompt string
	syscall				    # print the prompt

# function to get user input for equation
    jal userInput

# func. that counts the number of characters from input
    jal count

# display "Infix to Postfix:"
	li	$v0, 4			    # code for print_string
	la	$a0, postfixPrompt  # point $a0 to prompt string
	syscall				    # print the prompt

# convert infix($s0) to postfix($s1)
	jal infixToPostfix

# print new line
	li	$v0, 4			        # code for print_string
	la	$a0, newLine    # point $a0 to prompt string
	syscall				        # print the prompt

# display "Evaluated Expression:"
	li	$v0, 4			        # code for print_string
	la	$a0, evaluatedPrompt    # point $a0 to prompt string
	syscall				        # print the prompt

# evaluate postfix expression into an answer
    jal evaluate

############ END PROGRAM ################################
li    $v0,10	#$v0-what action to take, call exit: 10  #
syscall			#alert kernal and execute code           #
#########################################################


## 		F U N C T I O N S 		##
##############################################################################
###### GET EXPRESSION FROM THE USER ##########################################
userInput:
    #gather user input str.
    li $v0, 8       # 8 = str_input
    la $a0, input   # $a0 = buffer -> load byte space into address
    li $a1, 265      # allot the byte space for string

    move $s0, $a0       # save string to s0
    syscall             # call kernal's attention

    # print "original expr:"
    la $a0, originalExpr    # load msg
    li $v0, 4               # 4 = print_str
    syscall                 # call kernal

    #print user input (original expression)
    la $a0, input       # $a0 = buffer -> reload byte space to primary address
    move $a0, $s0       # primary address = s0 address (load pointer)
    li $v0, 4           # print string
    syscall             # kernal call

    jr $ra          # return statement
##############################################################################
###### COUNT INPUT ###########################################################
count:
    #initializations
    li $s3, 0               # counter for input length
    add $t0, $s0, $zero     # $t0 temp hold's input addr.

#loop str. until it ends
loop:
    lb   $a0, 0($t0)    # load current character location
    beqz $a0, done      # (t[i] == 0) {go-to done}
    addi $t0, $t0, 1    # i++ (increment placement of char of str)
    addi $s3, $s3, 1    # increment counter
    j     loop
done:

    addi $s3, $s3, -1 # counter off by 1 so it fixes it :)

    # # print counter
    # li   $v0, 1         # 1 = print_int
    # add  $a0, $0, $s3   # print counter
    # syscall             # call kernal

    # # print /n for newline after array is printed!
	# li	$v0, 4			# code for print_string
	# la	$a0, newLine	# point $a0 to prompt string
	# syscall				# print the prompt

    jr $ra 			#go back to where function was called (main)

##############################################################################
###### INFIX TO POSTFIX CONVERSION ###########################################

infixToPostfix:
# all init.
    add $t0, $s0, $zero     # $t0 temp hold's input addr.
    # t1 = current element in infix (OG)

    la $s1, postfix         # postfix init
    add $t2, $s1, $zero     # hold addr. for new postfix
    addi $t3, $zero, 1      # counter for OG to stop looping
    #s3 length of input(infix) & postfix
    add $s5, $s3, $zero

    # #all possible operators to compare to
    # li $t4, '+'     # PUSH TO STACK
    # li $t5, '-'     # PUSH TO STACK
    # li $t6, '('     # PUSH TO STACK
    # li $t7, ')'     # POP AND KEEP 1st ELEMENT, THEN DISCARD NEXT
    # #ex: stack [ + ) - ) ] -> [ - ) ] & +

loopInput:

    lb $t1, 0($t0)           # get first char of input

    # if current input = '+'
    beq $t1, '+', push       # + gets pushed to stack

    # if current input = '-'
    beq $t1, '-', push       # - gets pushed to stack

    # if current input = '('
    beq $t1, '(', openBracket       # ( gets pushed to stack

    # if current input = ')'
    beq $t1, ')', closedBracket       # () so remove and pop operator

    # not any operator -> make current ele = next
    # $t1 current element in original expr.
    sb $t1, postfix($t9)          # save current int into postfix (>_<)
		addi $t9, $t9, 1

    addi $t2, $t2, 4        # iterate to next ele in new list after adding

returnHere:
    #s3=length, t3=og placement counter, $t0 is og mem location
    beq $t3, $s3, exit      # if this is end of list, you're done
    addi $t0, $t0, 1        # iterate to next addr. of OG infix
    addi $t3, $t3, 1        # iterate counter for OG's placement
    j loopInput

exit:
    # function finished, go back to main
		la $t4, postfix #t0 holds address to the infix expression
		lb $a0, ($t4)

		j resulty

exome:
jr $ra
resulty:
  lb $t6, ($t4)
	beq	$t6, 0, exome  # if reached end of expression, end loop

	lb $a0, ($t4) #points to byte previously in stack
  li $v0, 11
  syscall

	addi $t4, $t4, 1
	j resulty

push:

    sub $sp, $sp, 1         # make space in stack for operator (-1)
    sb $t1 , 0($sp)         # push operator to stack (from og) to postfix expr.

    j returnHere

pop:

    lb $t2, 0($sp)          # pop operator from stack to new list
    sb $t2, postfix($t9)          # save current int into postfix (>_<)
	addi $t9, $t9, 1
    addi $sp, $sp, 2        # return space used (+1)

    addi $t2, $t2, 1        # iterate to next ele in new list after adding
    j returnHere

openBracket:
    sub $s5, $s5, 1
    j push

closedBracket:
    sub $s5, $s5, 1
    j pop 

##############################################################################
###### EVALUATE POSTFIX EXPRESSION ###########################################
evaluate:

    # t0 = postfix expression
    add $t0, $s1, $zero #s1 is postfix expression
    # $s4 = length of postfix expr.
    addi $t4, $zero, 1   # use as counter going through postfix

loopPostfix:

    lb $t1, 0($t0)              # get first(current) char of input

    # if current input = '+'
    beq $t1, '+', addEval       # pop next two num and eval (+)

    # if current input = '-'
    beq $t1, '-', subEval       # pop next two num and eval (-)

    # not any operator -> push to stack
    # $t1 current element in original expr.
    sub $sp, $sp, 1         # make space in stack for operator (-1)
    sb $t1 , 0($sp)         # push operator to stack (from og) to postfix expr.

backToLoop:
    #s5=length postfix, t3=og placement counter, $t0 is og mem location
    beq $t4, $s5, donee     # if this is end of list, you're done. leave. get out.
    addi $t0, $t0, 1        # iterate to next addr. of OG infix
    addi $t4, $t4, 1        # iterate counter for OG's placement
    j loopPostfix

donee:
    # function finished, go back to main after printing
    lb $t2, 0($sp)          # pop operator from stack to new list
    sub $t2, $t2, 48        # convert to number
    li	$v0, 1			    # code for print_int
	add $a0, $t2, $zero	    # point $a0 to prompt string
	syscall				    # print the prompt

    addi $sp, $sp, 1        # return space used (+1)
    jr $ra

addEval:
    #get two numbers from stack
    lb $t2, 0($sp)          # pop 1st num from stack
    lb $t3, 1($sp)          # pop 2nd num from stack
    # convert two ascii into actual numbers
    addi $t2, $t2, -48
    addi $t3, $t3, -48

    addi $sp, $sp, 1        # return space used (+1)
    add $t7, $t3, $t2       # iterate to next ele in new list after adding
    addi $t7, $t7, 48       # put back into ascii when pushing
    sb $t7, 0($sp)          # push evaluated expr. back to stack when done

    # go back to evaluating postfix expr.
    j backToLoop

subEval:
    #get two numbers from stack
    lb $t2, 0($sp)          # pop first num from stack to new list
    lb $t3, 1($sp)          # pop second num from stack
    # convert two ascii into actual numbers
    addi $t2, $t2, -48
    addi $t3, $t3, -48

    addi $sp, $sp, 1        # return space used (+1)
    sub $t7, $t3, $t2       # iterate to next ele in new list after adding
    addi $t7, $t7, 48       # put back into ascii when pushing
    sb $t7, 0($sp)          # push evaluated expr. back to stack when done

    j backToLoop

##############################################################################
