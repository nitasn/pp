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

.hamming_dist_loop:
  movdqu (%rdi, %rax), %xmm1  # 16 chars from str1

  # 00 10 01 00 Unsigned Chars, Equal Each, Negative Polarity
  pcmpistrm $0b00100100, (%rsi, %rax), %xmm1

  pushf

  movmskps %xmm0, %ecx  # move the mask bits to a general-purpose register
  popcnt %rcx, %rcx # count 1's
  add %rcx, %rax

  popf
  jnz .hamming_dist_loop

  pop %rbp
  ret

tirgul_str_len:
  push %rbp
  mov %rsp, %rbp

  xor %rax, %rax
  xor %rcx, %rcx

  lea EOS_mask, %rsi
  movdqu (%rsi), %xmm1

.loop:
  pcmpistri $0b00010100, (%rdi,%rax), %xmm1
  pushf

  add %rcx, %rax

  popf
  jnz .loop

  pop %rbp
  ret
