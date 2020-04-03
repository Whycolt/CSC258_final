#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Colt Ma, 1004180520
# - Student 2 (if any): Alexandru Marcu, 1004442999
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

# - pipe 1 memory -> $s0
# - bird memory -> $s1
.data
	birdColor: .word 0xD1C429	# Color of bird
	pipeColor: .word 0x74C029	# Color of pipes
	skyColor: .word 0x72C7D0	# Color of sky
	s0: .space 8			# Space allocated for Pipe 1
	s1: .space 8			# Space allocated for Bird

.globl main
.text

main:			# Load memory addresses
	la $s0, s0			# Store pipe 1 memory address at $s0
	la $s1, s1
	
full_fill_prep:		# Prep for filling background
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t1, skyColor		# Load sky color to #t1
	li $t2, 0			# Store a counter at $t2
	li $t3, 1024			# Store the counter limit at $t3

full_fill:		# Loop for filling background
	sw $t1, 0($t0)			# paint a unit on bitmap
	addi $t0, $t0, 4		# increment bitmap address
	addi $t2, $t2, 1		# increment counter
	bne $t2, $t3, full_fill 	# loop drawing background
	
bird_start_prep: 		# Loop for drawing bird at its starting position
	add $t0, $zero, $zero
	addi $t0, $t0, 1948		# The bird will always first load in here
	sw $t0, 0($s1)			# Save into memory		

draw_pipe1_prep:	# Initiating a pipe	
	li $a1, 16 			# Load random number max to $a1
    	li $v0, 42			# Load random generator syscall to $v0
    	syscall
	addi $a0, $a0, 2		# Add 2 to randomly generator number, now between 2-18
    	sw $a0, 0($s0)			# Store random number to pipe 1 memory
	li $t0, 32   			# Set location of pipe 1
	sw $t0	4($s0)			# Store location of pipe 1 to pipe 1 memory

game_loop:		# --GAME LOOP--
	li $v0, 32			# Load pause syscall to $v0
	li $a0, 160			# Load pause duration to $a0
	syscall
	#-- CHECK INPUT FIRST, SET 8($s1) (save old pos in 12($s1), and check >< to know if to color top or bottom)
	jal input_check
	jal draw_bird
	jal pipe1_branch		# Draw Pipe 1 method
	j game_loop			# loop game

pipe1_branch:		# Drawing pipe 1 method head
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t1, pipeColor		# Load pipe color into $t1
	lw $t2, skyColor		# Load sky color to $t2
	lw $t3, 0($s0)			# Load pipe gap top to $t3
	lw $t4, 4($s0)			# Load pipe location to $t4
	li $t6, 0			# Store a counter at $t6
	subi $t4, $t4, 1		# Decrement pipe location
	li $t7, 4			# Set $t7 to 4
	mult $t7, $t4			# Get address offset of pipe for bitmap
	mflo $t7
	add $t0, $t0, $t7		# Add offest to bitmap address
	bge $t4, 32, pipe1_branch	# Loop, Nothing drawn
	bge $t4, -4, Pipe1Loop		# Draw pipe when in locations on screen
	j draw_pipe1_prep		# Generate new pipe

Pipe1Loop:			# Draw pipe 1 loop
	addi $t6, $t6, 1		# Increment counter
	bge $t4, 28, Pipe1R		# Draw pipe comming in from right
	bge $t4, 0, Pipe1M		# Draw pipe when moving through middle

Pipe1L:				# Draw pipe 1 disappearing into left
	sw $t2, 16($t0)			# paint back of pipe over with sky
	j Pipe1End			# Go to rest of loop

Pipe1R:				# Draw pipe 1 appearing from right
	sw $t1, 0($t0)			# Paint pipe
	j Pipe1End			# Go to rest of loop

Pipe1M:				# Draw pipe 1 moving through middle
	sw $t1, 0($t0)			# paint pipe 
	sw $t2, 16($t0)			# paint back of pipe over with sky

Pipe1End:			# Rest of pipe 1 loop
	addi $t0, $t0, 128		# Increment bitmap address
	li $t5, 0			# Store a counter at $t5 for gap
	beq $t6, $t3, Pipe1Skip		# If at gap position, do gap method
	bne $t6, 32, Pipe1Loop		# Loops until pipe is fully drawn
	j pipe1_store			# Save variables into memory

Pipe1Skip:			# Draw pipe 1 gap 
	addi $t6, $t6, 1		# Increment pipe counter
	addi $t5, $t5, 1		# Increment gap counter
	addi $t0, $t0, 128		# Increment bitmap address
	bne $t5, 12, Pipe1Skip		# Loop skip until gap is 12 units long
	j Pipe1Loop			# Return to drawing pipe loop

pipe1_store:			# Store pipe 1 variables into memory
	sw $t3 0($s0)			# Save pipe gap top into memory
	sw $t4 4($s0)			# Save pipe location into memory
	jr $ra				# Return to game loop
	
	
input_check:
	lw $t0, 0xffff0000
	beq $t0, $zero, bird_fall
	
	# Check if they pressed "f"
	lw $t0, 0xffff0004
	add $t1, $zero, $zero
	addi $t1, $t1, 102
	bne $t0, $t1, bird_fall

	# If here, than there was input to the keyboard, and we must "raise" the bird
	add $t0, $zero, $zero

	lw $t0, 0($s1)
	addi $t0, $t0, 128
	sw $t0, 4($s1)
	subi $t0, $t0, 128
	subi $t0, $t0, 128
	sw $t0, 0($s1)
	
	j DONE
	
bird_fall:
	add $t0, $zero, $zero

	lw $t0, 0($s1)
	sw $t0, 4($s1)
	addi $t0, $t0, 128
	sw $t0, 0($s1)
DONE:
	sw $zero, 0xffff0000 		# Resetting keyboard input
	jr $ra
	
draw_bird:
	add $t0, $zero, $gp
	
	add $t1, $zero, $zero 		# Current position of bird
	lw $t1, 0($s1) 
	
	add $t2, $zero, $zero		# Old position (to re-color back the sky)
	lw $t2, 4($s1)
	
	# Color the previous (old first row back to sky)
	lw $t3, skyColor
	add $t4, $t0, $t2
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	
	lw $t3, birdColor
	add $t4, $t0, $t1
	
	# First row
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	
	# Second row
	sw $t3, 128($t4)
	sw $t3, 132($t4)
	sw $t3, 136($t4)
	sw $t3, 140($t4)
	
	jr $ra

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
