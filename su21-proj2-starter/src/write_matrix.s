.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 64
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 67
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 65
# ==============================================================================
write_matrix:
	
    ebreak
    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)

	add s0, a1, x0 # save pointer to matrix
    add s1, a2, x0 # save rows
    add s2, a3, x0 # save cols
	add a1, a0, x0 # set parameter
    addi sp, sp, -8 # save rows cols to stack 
    sw s1, 0(sp)
    sw s2, 4(sp)
    addi a2, x0, 1
    jal fopen
    addi t0, x0, -1
    beq a0, t0, exit64 # exit code if fopen fail
    add s3, a0, x0 # save file descriptor
    add a1, s3, x0 # parameter: file descriptor
    addi a2, sp, 0 # parameter: pointer to rows
    addi a3, x0, 1 # parameter: one element
    addi a4, x0, 4 # parameter: 4 bytes
    jal fwrite # write rows
    addi sp, sp, 4 # restore sp by 4 bytes
    addi a3, x0, 1 # restore a3
    bne a0, a3, exit67 # exit code if fwrite fail
    addi a2, sp, 0 # parameter: pointer to cols
    jal fwrite # write cols
    addi sp, sp, 4 # restore sp by 4 bytes
    addi a3, x0, 1 # restore a3
    bne a0, a3, exit67 # exit code if fwrite fail
    add a2, s0, x0 # parameter: pointer to matirx
    mul s4, s1, s2 # rows * cols elements
    add a3, s4, x0 # parameter: elements
    jal fwrite # write matrix
    bne a0, s4, exit67
	jal fclose
    bne a0, x0, exit65

    # Epilogue
	lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    ret
    
exit64:
	addi a1, x0, 64
    jal exit2
exit67:
	addi a1, x0, 67
    jal exit2
exit65:
	addi a1, x0, 65
    jal exit2
