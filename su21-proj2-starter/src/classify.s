.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 35
    # - If malloc fails, this function terminates the program with exit code 48
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
	
    ebreak
    # prolague
    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)
    
    # check argument number
    addi t0, x0, 5
    bne a0, t0, exit35 # exit code 35 if have incorrect number of command line args

	# =====================================
    # LOAD MATRICES
    # =====================================
	add s0, a0, x0 # save a0: argc
    add s1, a1, x0 # save a1: argv
    add s2, a2, x0 # save a2: print_classification

    # Load pretrained m0
	addi a0, x0, 4 # malloc 4 bytes
    jal malloc
    beq a0, x0, exit48 # exit code 48 if malloc fail
    add s0, a0, x0 # parameter: pointer to rows
    add s6, a0, x0 # save pointer to m0 rows : s6
    addi a0, x0, 4 # malloc 4 bytes
    jal malloc
    beq a0, x0, exit48
    add a1, s0, x0 # parameter: pointer to rows
    add a2, a0, x0 # parameter: pointer to cols
    add s7, a0, x0 # save pointer to m0 cols : s7
    lw a0, 4(s1) # parameter: pointer to m0_path
	jal read_matrix # read m0
    add s3, a0, x0 # save pointer to m0: s3
    
    # Load pretrained m1
	addi a0, x0, 4 # malloc 4 bytes
    jal malloc
    beq a0, x0, exit48 # exit code 48 if malloc fail
    add s0, a0, x0 # parameter: pointer to rows : s0
    add s8, a0, x0 # save pointer to m1 rows : s8
    addi a0, x0, 4 # malloc 4 bytes
    jal malloc
    beq a0, x0, exit48
    add a1, s0, x0 # parameter: pointer to rows
    add a2, a0, x0 # parameter: pointer to cols
    add s9, a2, x0 # save pointer to m1 cols : s9
    lw a0, 8(s1) # parameter: pointer to m1_path
    jal read_matrix # read m1
    add s4, a0, x0 # save pointer to m1: s4
    
    # Load input matrix
	addi a0, x0, 4 # malloc 4 bytes
    jal malloc
    beq a0, x0, exit48 # exit code 48 if malloc fail
    add s0, a0, x0 # parameter: pointer to rows
    add s10, s0, x0 # save pointer to input matrix rows : s10
    addi a0, x0, 4 # malloc 4 bytes
    jal malloc
    beq a0, x0, exit48
    add a1, s0, x0 # parameter: pointer to rows
    add a2, a0, x0 # paremeter: pointer to cols
    add s11, a2, x0 # save pointer to input matrix cols : s11
    lw a0, 12(s1) # parameter: pointer to input_path
    jal read_matrix # read input matrix
    add s5, a0, x0 # save pointer to input matrix: s5

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    lw a1, 0(s6) # parameter: m0 rows
    lw a2, 0(s7) # parameter: m0 cols
    add a3, s5, x0 # parameter: pointer to input
    lw a4, 0(s10) # parameter: input rows
    lw a5, 0(s11) # parameter: input cols
    mul s0, a1, a5 # hidden matrix elements: s0
    slli a0, s0, 2 # bytes for hidden matrix
    addi sp, sp, -20
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)
    sw a4, 12(sp)
    sw a5, 16(sp)
    jal malloc
    beq a0, x0, exit48 # exit code if malloc fail
    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    lw a4, 12(sp)
    lw a5, 16(sp)
    addi sp, sp, 20
    
    addi sp, sp, -40 # save pointer to stack for later free
    sw s3, 0(sp) # m0
    sw s4, 4(sp) # m1
    sw s5, 8(sp) # input
    sw s6, 12(sp) # m0 rows
    sw s7, 16(sp) # m0 cols
    sw s8, 20(sp) # m1 rows
    sw s9, 24(sp) # m1 cols
    sw s10, 28(sp) # input rows
    sw s11, 32(sp) # input cols
    sw a0, 36(sp) # hidden
    
    add a6, a0, x0 # parameter: pointer to hidden matrix
    add a0, s3, x0 # parameter: pointer to m0
    jal matmul # m0 * input
    
    lw a0, 36(sp) # parameter: pointer to hidden
    add a1, s0, x0 # elements of output
    jal relu # relu(hidden matrix)
    
    lw a3, 36(sp) # parameter: pointer to hidden
    lw a1, 0(s8) # parameter: m1 rows
    lw a2, 0(s9) # parameter: m1 cols
    lw a4, 0(s6) # parameter: hidden rows
    lw a5, 0(s11) # parameter: hidden cols
    mul s0, a1, a5 # output matrix elements
    slli a0, s0, 2
    addi sp, sp, -20
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)
    sw a4, 12(sp)
    sw a5, 16(sp)
    jal malloc
    beq a0, x0, exit48
    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    lw a4, 12(sp)
    lw a5, 16(sp)
    addi sp, sp, 20
    
    addi sp, sp, -4 # save pointer to stack for later free
    sw a0, 0(sp)
    
    add a6, a0, x0 # parameter: pointer to output
    add a0, s4, x0 # parameter: pointer to m1
    jal matmul # m1 * hidden
    
    
    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
	lw a0, 16(s1) # output path
    lw a1, 0(sp) # pointer to output matrix
    lw t0, 24(sp) 
    lw a2, 0(t0) # output rows
    lw t0, 36(sp)
    lw a3, 0(t0) # output cols
	jal write_matrix



    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
	lw a0, 0(sp) # pointer to outout matrix 
    lw t0, 24(sp)
    lw t1, 0(t0) # output rows
	lw t0, 36(sp)
    lw t2, 0(t0) # output cols
	mul a1, t1, t2 # output elements
    jal argmax
	
    # Print classification
    bne s2, x0, done # do not print if a2 = 0
	add a1, a0, x0 # parameter: print a0
	jal print_int # print a1
    

    # Print newline afterwards for clarity
	li a1, '\n'
    jal print_char


done:
	lw a0, 0(sp)
    jal free
    lw a0, 4(sp)
    jal free
    lw a0, 8(sp)
    jal free
    lw a0, 12(sp)
    jal free
    lw a0, 16(sp)
    jal free
    lw a0, 20(sp)
    jal free
    lw a0, 24(sp)
    jal free
    lw a0, 28(sp)
    jal free
    lw a0, 32(sp)
    jal free
    lw a0, 36(sp)
    jal free
    lw a0, 40(sp)
    jal free
    addi sp, sp, 44 # restore sp after free all malloc space
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52
    
    ret
exit35:
	addi a1, x0, 35
    jal exit2
exit48:
	addi a1, x0, 48
    jal exit2