.globl factorial

.data
n: .word 8

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    addi t0, a0, -1 # save N-1 value to t0
    add t1, a0, x0 # t1 save factorial result, default is N
loop:
    beq t0, x0, exit # end loop if n = 0
    mul t1, t1, t0 # calculate factorial
    addi t0, t0, -1 # n-1
    j loop
exit:
    add a0, t1, x0
	jr ra