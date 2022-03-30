addi a1, x0, -10

addi sp, sp, -12
sw a1, 0(sp)
sh a1, 4(sp)
sb a1, 8(sp)

lw a2, 0(sp)
lh a3, 4(sp)
lb a4, 8(sp)

addi sp, sp, 12

addi a5, a1, 10
slli a5, a1, 10
slti a5, a1, 10
xori a5, a1, 10
srli a5, a1, 10
srai a5, a1, 10
ori a5, a1, 10
andi a5, a1, 10

