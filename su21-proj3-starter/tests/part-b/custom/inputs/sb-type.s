addi a1, x0, 1
addi a2, x0, 2

beq a1, a2, one

two:
    add a2, a1, a2
    blt a1, a2, three

one:
    add a1, a1, a2
    bne a1, a2, two

four:
    addi a1, x0, -1
    addi a2, x0, -2
    bltu a2, a1, five

three:
    add a1, a2, a1
    bge a1, a2, four

six:
    j exit

five:
    bgeu a1, a2, six
    
exit:   
