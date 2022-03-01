.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 33
# =======================================================
dot:
    # Prologue
    ebreak
    addi t0, x0, 1
    blt a3, t0, error33 # check whether either stride less than 1
    blt a4, t0, error33
    bge a1, t0, loop_start # check whether length of array less than 1
    error32:
    addi a0, x0, 17
    addi a1, x0, 32
    ecall
    error33:
    addi a0, x0, 17
    addi a1, x0, 33
    ecall
	
loop_start:
	add t0, x0, x0 # index of element t0
    add t1, x0, x0 # product t1
	slli a3, a3, 2 # stride * 4 bytes
    slli a4, a4, 2 # stride * 4 bytes
    
loop_continue:
	bge t0, a2, loop_end # loop until process all element
    lw t2, 0(a0) # load array1 element
    lw t3, 0(a1) # load array2 element
    mul t2, t2, t3
    add t1, t1, t2 # sum product
    addi t0, t0, 1 # increment index by 1
    add a0, a0, a3 # increment a0 address
    add a1, a1, a4 # increment a1 address
	j loop_continue
    
loop_end:
	add a0, x0, t1
    # Epilogue

    
    ret
