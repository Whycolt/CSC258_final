#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Colt Ma, 1004180520
# - Student 2 (if any): Name, Student Number
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

# - Bird 7 units ahead
# - Pipe 4 units wide, 8 units apart, 12 units between pipes
# - bid 4 units long, 3 units high
.data
	displayAddress:	.word	0x10008000
	birdColor: .word 0xD1C429
	pipeColor: .word 0x74C029
	skyColor: .word 0x72C7D0
.globl main
.text

main:
	lw $t1, skyColor 		# $t1 stores the sky color
	lw $t0, displayAddress		# $t0 stores the base address for display
	li $t2, 0			# $t2 stores a counter
	li $t3, 1024			# $t3 stores the counte limit

full_fill:
	sw $t1, 0($t0)			# paint unit
	addi $t0, $t0, 4		# increment address
	addi $t2, $t2, 1		# increment counter
	bne $t2, $t3, full_fill 	# loop		

draw_pipe_prep:
	lw $t1, pipeColor		# $t1 stores the pipe color
	lw $t2, skyColor		# $t2 stores the skycolor
	li $t3, 12			# distance of pipe from top, between 2-22
	li $t4, 32			# location of pipe


pipe_branch:
	li $v0, 32
	li $a0, 160
	syscall
	li $t6, 0			# $t6 stores counter
	lw $t0, displayAddress		# $t0 stores display
	subi $t4, $t4, 1		# move pipe closer
	li $t7, 31
	sgt $t5, $t4, $t7 
	bne $t5, $zero, pipe_branch
	li $t7, 27
	sgt $t5, $t4, $t7 
	bne $t5, $zero, draw_pipeR
	li $t7, -1
	sgt $t5, $t4, $t7 
	bne $t5, $zero, draw_pipeM
	li $t7, -5
	sgt $t5, $t4, $t7 
	bne $t5, $zero, draw_pipeL
	li $t4, 32
	j pipe_branch
	
draw_pipeR:
	li $t7, 4
	mult $t7, $t4
	mflo $t7
	add $t0, $t0, $t7		# set location
Rloop:
	addi $t6, $t6, 1		# increment $t6
	sw $t1, 0($t0)			# paint pipe 
	addi $t0, $t0, 128
	bne $t6, 32, Rloop
	j pipe_branch

draw_pipeM:
	li $t7, 4
	mult $t7, $t4
	mflo $t7
	add $t0, $t0, $t7	
Mloop:
	addi $t6, $t6, 1		# increment $t6
	sw $t1, 0($t0)			# paint pipe 
	sw $t2, 16($t0)
	addi $t0, $t0, 128
	bne $t6, 32, Mloop
	j pipe_branch

draw_pipeL:
	li $t7, 4
	mult $t7, $t4
	mflo $t7
	add $t0, $t0, $t7	
Lloop:
	addi $t6, $t6, 1		# increment $t6 
	sw $t2, 16($t0)
	addi $t0, $t0, 128
	bne $t6, 32, Lloop
	j pipe_branch

pipe_skip:

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
