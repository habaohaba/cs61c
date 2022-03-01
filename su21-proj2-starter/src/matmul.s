.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 34
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 34
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 34
# =======================================================
matmul:

    # Error checks
    addi t0, x0, 1
	blt a1, t0, error # check whether rows and columns of m0 m1 is 0 or less
    blt a2, t0, error
    blt a3, t0, error
    blt a4, t0, error
    beq a2, a4, start # check whether m0 columns == m1 rows
	error:
    addi a0, x0, 17
    addi a1, x0, 34
    ecall
	start:
    # Prologue
    addi sp, sp, -12 # save return address and saved register
    sw ra, 0(sp)
	sw s0, 4(sp)
    sw s1, 8(sp)
    
outer_loop_start: # loop rows
	add s0, x0, x0 # index of rows
    
	outer_loop:
    beq s0, a1, outer_loop_end # loop until process all the rows
    
inner_loop_start: # loop columns
	add s1, x0, x0 # index of columns
    
	inner_loop:
    ebreak 
	beq s1, a5, inner_loop_end # loop until process all the columns
    addi sp, sp, -28 # save register
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    mul t0, s0, a2 # index of dot row
    slli t0, t0, 2 # t0 * 4
    add a0, a0, t0 # address of dot row
    slli t0, s1, 2 # index of dot column * 4
    add a1, a3, t0 # address of dot column
    # a2 = a2 length of vector equal to columns of array1
    addi a3, x0, 1 # stride of array1
    add a4, x0, a5 # stride of array2
    jal dot # calculate dot product
    lw a2, 8(sp)
    mul t0, s0, a2 
    add t0, t0, s1 # index of result position
    slli t0, t0, 2 # t0 * 4 bytes
    lw a6, 24(sp)
    add t1, a6, t0 # address of result position
    sw a0, 0(t1) # save result
    lw a0, 0(sp) # restore register
    lw a1, 4(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 28
    addi s1, s1, 1 # increment columns
    j inner_loop # inner_loop
    
inner_loop_end:
	addi s0, s0 1 # increment rows
	j outer_loop # back to outer loop

outer_loop_end:
	
    # Epilogue
    lw ra, 0(sp) # restore return address and saved register
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    
    ret