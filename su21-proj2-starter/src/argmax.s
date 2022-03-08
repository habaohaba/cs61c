.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# =================================================================
argmax:

    # Prologue
    addi sp, sp -4
    sw s0, 0(sp)
    
    ebreak
    addi t0, x0, 1
    blt a1, t0, exit32 # exit program with error code 32 if length of vector less than 1

loop_start:
	add t0, x0, x0 # element index t0
    lw t1, 0(a0) # largest element t1

loop_continue:
	bge t0, a1, loop_end # loop until process all the element
    lw t2, 0(a0) # load current element
    blt  t2, t1, done # jump if less than current largest
    add t1, t2, x0 # update largest number
    add s0, x0, t0 # save current index
    done:
    addi a0, a0, 4
    addi t0, t0, 1
	j loop_continue


loop_end:
    add a0, x0, s0 # save largest number INDEX in a0 to return

    # Epilogue
	lw s0, 0(sp)
	addi sp, sp, 4

    ret
exit32:
	addi a1, x0, 32
    jal exit2