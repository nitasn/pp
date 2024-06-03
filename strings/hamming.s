.section .data

EOS_mask:
  .byte 0x1, 0xFF
  .byte 0,0,0,0,0,0,0,0,0,0


.section .text

.globl hamming_dist

# hamming_dist:
#   call tirgul_strlen
# 	ret


# tirgul_strlen:

hamming_dist:
  push %rbp
  mov %rsp, %rbp

  # Zero our counting registers
  xor %rax, %rax
  xor %rcx, %rcx

  # Load mask into xmm1
  lea EOS_mask(%rip), %rsi
  movq %rsi, %xmm1

.loop:
  movdqu (%rdi, %rax), %xmm0  # Load data from string into xmm0
  pcmpistri $0x18, %xmm1, %xmm0  # Control byte in immediate, compare xmm1 with xmm0
  jnz .loop
  add %rcx, %rax


  pop %rbp
  ret
