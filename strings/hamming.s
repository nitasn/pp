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
  movdqu (%rsi), %xmm2

.hamming_dist_loop:
  movdqu (%rdi, %rax), %xmm1  # 16 chars from str1
  movdqu (%rsi, %rax), %xmm2  # 16 chars from str2

  # 00 10 10 00 Unsigned Chars, Equal Each, Masked (+), Bit Mask
  pcmpistrm $0b00101000, %xmm1, %xmm2

  movd %xmm0, %ecx  
  # now %ecx holds comparison mask, plus trailing junk

  pcmpistri $0b00010100, %xmm2, %xmm1
  # now %ecx holds first chunk's length (between 0 and 16)
  
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
