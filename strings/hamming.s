.section .data

EOS_mask:
  .byte 0x1,0xFF
  .byte 0,0,0,0,0,0,0,0,0,0,0,0

.section .text

.globl hamming_dist

hamming_dist:
  push %rbp
  mov %rsp, %rbp

  xor %rax, %rax
  xor %rcx, %rcx

  lea EOS_mask, %rsi
  movdqu (%rsi), %xmm1

.loop:
  add %rax, %rcx
  pcmpistri $0b00101000, (%rdi,%rax), %xmm1
  jnz .loop

  add %rax, %rcx

  pop %rbp
  ret
