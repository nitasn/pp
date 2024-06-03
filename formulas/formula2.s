.section .data

    .align 16
    ones: .float 1.0, 1.0, 1.0, 1.0


.section .text

    .globl formula2

    # signature:
    # float formula2(float x[], float y[], long n)
    
    # returns:
    # - %xmm0: sum(x*y) / product(x^2 + y^2 - 2*x*y + 1)

    # parameters:
    # - %rdi: x
    # - %rsi: y
    # - %rdx: n

    # local variables:
    # - %xmm7: four ones (1.0, 1.0, 1.0, 1.0)
    #
    # - %xmm2: for values from enumerator (building up)
    # - %xmm4: four values from denominator (building up)
    #
    # - %rax:  loop counter (like `i` in: size_t i = 0; i < n; i += 4)
    #
    # - %xmm0: four values from x
    # - %xmm1: four values from y
    #
    # - %xmm3: four values from (x * y)
    # - %xmm8: four values from (x - y)^2 + 1

    formula2:
        vmovaps (ones), %xmm7          # load 1.0f values into %xmm7

        vxorps %xmm2, %xmm2, %xmm2     # init sum (enumerator) to zeros

        vxorps %xmm4, %xmm4, %xmm4
        vaddps %xmm7, %xmm4, %xmm4   # inti prod (denomenator) to ones

        xor %rax, %rax      # loop counter initialized to zero

    .loop_start:
        cmp %rdx, %rax    # compare counter with n
        jge .loop_end     # if counter >= n, end loop

        vmovups (%rdi, %rax, 4), %xmm0  # four values from x
        vmovups (%rsi, %rax, 4), %xmm1  # four values from y

        vmulps %xmm0, %xmm1, %xmm3  # (x * y)
        vaddps %xmm2, %xmm3, %xmm2  # add to sum (enumerator)

        vsubps %xmm1, %xmm0, %xmm8  # (x - y)
        vmulps %xmm8, %xmm8, %xmm8  # (x - y)^2
        vaddps %xmm7, %xmm8, %xmm8  # (x - y)^2 + 1
        vmulps %xmm4, %xmm8, %xmm4  # add to prod (denomenator)

        add $4, %rax   # increase loop counter by 4
        jmp .loop_start

    .loop_end:
        # horizontal add to aggregate the four elements of %xmm2 (enumerator)
        vhaddps %xmm2, %xmm2, %xmm2
        vhaddps %xmm2, %xmm2, %xmm2
        
        # horizontal mul %xmm4 step 1
        vshufps $0b10110001, %xmm4, %xmm4, %xmm11   # shuffle to {b, a, d, c} in %xmm11
        vmulps %xmm4, %xmm11, %xmm11                # %xmm11 = {a*b, b*a, c*d, d*c}

        # horizontal mul %xmm4 step 2
        vshufps $0b00001000, %xmm11, %xmm11, %xmm12  # shuffle to {c*d, a*b, ..., ...} in %xmm12

        # horizontal mul %xmm4 step 3
        vmulps %xmm12, %xmm11, %xmm4                # %xmm4 = {a*b*c*d, ..., ..., ...}

        # our result!
        vdivss %xmm4, %xmm2, %xmm0

        ret
