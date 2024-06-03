.section .data

EOS_mask:
  .byte 0x1,0xFF
  .byte 0,0,0,0,0,0,0,0,0,0,0,0

.section .text

.globl hamming_dist

hamming_dist:
  push %rbp
  mov %rsp, %rbp

  push %rsi

  lea EOS_mask, %rsi
  movdqu (%rsi), %xmm3

  pop %rsi

  xor %rax, %rax
  xor %rcx, %rcx

.hamming_dist_loop:
  movdqu (%rdi, %rax), %xmm1  # 16 chars from str1
  movdqu (%rsi, %rax), %xmm2  # 16 chars from str2

  # 00 10 10 00 Unsigned Chars, Equal Each, Masked (+), Bit Mask
  pcmpistrm $0b00101000, %xmm1, %xmm2

  movd %xmm0, %edx
  # now %edx holds comparison mask, plus trailing junk after str's length

  pcmpistri $0b00010100, %xmm1, %xmm3
  mov %ecx, %r8d
  # now %r8d holds first chunk's length (between 0 and 16)

  pcmpistri $0b00010100, %xmm2, %xmm3
  mov %ecx, %r9d
  # now %r9d holds second chunk's length (between 0 and 16)

  mov %r8d, %r10d
  cmpl %r9d, %r8d
  cmovg %r9d, %r10d
  # now %r10d holds the minimum of the two chunks' lengths

  push %rax
  push %rcx

  mov $1, %eax
  mov %r10b, %cl
  shl %cl, %eax
  dec %eax
  mov %eax, %r11d

  pop %rcx
  pop %rax

  andl %r11d, %edx

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
