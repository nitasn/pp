.section .data

EOS_mask:
  .byte 0x1,0xFF
  .byte 0,0,0,0,0,0,0,0,0,0,0,0

.section .text

.globl hamming_dist

hamming_dist:
  call tirgul_str_len
  add $1, %rax
  ret

tirgul_str_len:
  push %rbp
  mov %rsp, %rbp

  xor %rax, %rax
  xor %rcx, %rcx

  lea EOS_mask, %rsi
  movdqu (%rsi), %xmm1

.loop:
  add %rcx, %rax
  pcmpistri $0b00010100, (%rdi,%rax), %xmm1
  jnz .loop

  add %rcx, %rax

  pop %rbp
  ret
