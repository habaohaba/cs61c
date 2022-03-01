.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# ==============================================================================
relu:
    # Prologue
    ebreak
	addi t0, x0, 1
	bge a1, t0, loop_start # exit program with error code 32 if length of vector less than 1
    addi a0, x0, 17
    addi a1, x0, 32
    ecall
    
loop_start:
    add t0, x0, x0 # save element index

loop_continue:
	bge t0, a1, loop_end # loop until process all the element
    lw t1, 0(a0) # load current element to t1
    bge t1, x0, done
    add t1, x0, x0
    sw t1, 0(a0)
    done:
    addi t0, t0, 1
    addi a0, a0, 4
	j loop_continue

loop_end:


    # Epilogue

    
	ret
