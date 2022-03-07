.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 48
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 64
# - If you receive an fread error or eof,
#   this function terminates the program with error code 66
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 65
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)
    
    add s0, a1, x0 # save a1 pointer to rows
    add s1, a2, x0 # save a2 pointer to cols
    add a1, a0, x0 # filename
    addi a2, x0, 0 # only read
    jal fopen
    addi t0, x0, -1 
    beq a0, t0, exit64 # exit code 64 if fopen fail
    add s2, a0, x0 # save file descriptor
	add a1, s2, x0 # file descriptor
    add a2, s0, x0 # pointer of rows
    addi a3, x0, 4 # read 4 bytes as integer
    jal fread
    addi t0, x0, 4
    bne a0, t0, exit66 # exit code 66 if fread fail
	add a2, s1, x0 # pointer of cols
    jal fread
    addi t0, x0, 4
    bne a0, t0, exit66 # exit code 66 if fread fail
    lw t0, 0(s0) # get rows and cols
    lw t1, 0(s1)
    mul t0, t0, t1 # elements number
    add s3, t0, x0 # save elements number
    slli t0, t0, 2 # bytes to read
    add s4, t0, x0 # save bytes
    add a0, s4, x0 # set parameter
    jal malloc
    beq a0, x0, exit48 # exit code 48 if malloc fail
    add s5, a0, x0 # save output array
    add a1, s2, x0 # set parameter
    add a2, a0, x0
    add a3, s4, x0
    jal fread
    bne a0, s4, exit66 # exit code 66 if fread fail
    add a1, s2, x0 # set parameter
    jal fclose
    bne a0, x0, exit65 # exit code 65 if fclose fail
    add a0, s5, x0
    
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28

    ret
	
exit48:
	addi a1, x0, 48
    jal exit2
exit64:
	addi a1, x0, 64
    jal exit2
exit66:
	addi a1, x0, 66
    jal exit2
exit65:
	addi a1, x0, 65
    jal exit2