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
	ebreak
    # Error checks
    addi t0, x0, 1
	blt a1, t0, exit34 # check whether rows and columns of m0 m1 is 0 or less
    blt a2, t0, exit34
    blt a4, t0, exit34
    blt a5, t0, exit34
    bne a2, a4, exit34 # check whether m0 columns == m1 rows
    
    # Prologue
    addi sp, sp, -16 # save return address and saved register
    sw ra, 0(sp)
	sw s0, 4(sp) # rows
    sw s1, 8(sp) # cols 
    sw s2, 12(sp) # pointer to d array
    
outer_loop_start: # loop rows
	add s0, x0, x0 # index of rows
    add s2, a6, x0 # pointer to d array
    
	outer_loop:
    beq s0, a1, outer_loop_end # loop until process all the rows
    
inner_loop_start: # loop columns
	add s1, x0, x0 # index of columns
    
	inner_loop:
	beq s1, a5, inner_loop_end # loop until process all the columns
    mul t0, s0, a2 # index of dot row
    slli t0, t0, 2 # t0 * 4 bytes
    
    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    add a0, a0, t0 # address of dot row
    slli t0, s1, 2 # index of dot column * 4
    add a1, a3, t0 # address of dot column
    # a2 = a2 length of vector equal to columns of array1
    addi a3, x0, 1 # stride of array1
    add a4, x0, a5 # stride of array2
    jal dot # calculate dot product
    
    lw a5, 20(sp)
    mul t0, s0, a5 
    add t0, t0, s1 # index of result position
    slli t0, t0, 2 # t0 * 4 bytes
    add t0, s2, t0 # address of result position
    sw a0, 0(t0) # save result
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
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
    lw s2, 12(sp)
    addi sp, sp, 16
    
    ret
    
exit34:
	addi a1, x0, 34
    jal exit2