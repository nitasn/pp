.section .data

EOS_mask:
  .byte 0x1, 0xFF
  .byte 0,0,0,0,0,0,0,0,0,0


.section .text

.globl hamming_dist

; hamming_dist:
;   call tirgul_strlen
; 	ret


; tirgul_strlen:

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
  add %rcx, %rax
  pcmpistri $0x0100, (%rdi,%rax), %xmm1
  jnz .loop

  add %rcx, %rax

  pop %rbp
  ret
