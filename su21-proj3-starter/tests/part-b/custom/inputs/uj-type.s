main:
    addi a0, x0, 8
    jal ra, factorial

factorial:
    addi t0, a0, -1 # save N-1 value to t0
    add t1, a0, x0 # t1 save factorial result, default is N
loop:
    beq t0, x0, exit # end loop if n = 0
    mul t1, t1, t0 # calculate factorial
    addi t0, t0, -1 # n-1
    j loop
exit:
    
