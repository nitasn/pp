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

  xor %rax, %rax  # result (number of mismatches)

.hamming_dist_loop:
  movdqu %rdi, %xmm1  # 16 chars from str1
  movdqu %rsi, %xmm2  # 16 chars from str2

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

  mov %r10d, %ecx
  mov $1, %r11
  shl %cl, %r11
  dec %r11
  # now %r11 is a mask of %r10d lsb bits (e.g. if %r10d == 5, then 0b11111)

  not %edx
  andl %r11d, %edx
  # now %edx holds comparison mask, without trailing junk!!

  popcnt %edx, %edx
  # now %edx holds the number of mismatches in this iteration
  
  mov %edx, %edx  # zero-extend %edx to %rdx

  add %rdx, %rax  # add the result (number of mismatches) to the count

  cmp $16, %r10d  # compare smaller chunk length's with 16
  jb .hamming_dist_one_string_ended

  add $16, %rdi  # next 16 chars from str2
  add $16, %rsi  # next 16 chars from str1

  jmp .hamming_dist_loop


.hamming_dist_one_string_ended:
  cmp %r9d, %r10d
  je .hamming_dist_ending_second_is_smaller

.hamming_dist_ending_first_is_smaller:
  mov %rsi, %rdi
  sub %r8d, %r9d
  add %r9d, %rdi
  jmp .hamming_dist_ending

.hamming_dist_ending_second_is_smaller:
  sub %r9d, %r8d
  add %r8d, %rdi

.hamming_dist_ending:
  push %rax
  call my_str_len
  pop %rcx
  add %rcx, %rax

  pop %rbp
  ret


my_str_len:
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
