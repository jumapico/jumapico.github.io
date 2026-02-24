; Hello World Program
; Compile with: nasm -f elf64 helloworld64.asm
; Link with: ld -m elf_x86_64 helloworld64.o -o helloworld64
; Run with: ./helloworld64

SECTION .data
msg     db      'Hello World!', 0Ah     ; assign msg variable with your message string

SECTION .text
global  _start

_start:

    mov     rax, 1      ; invoke SYS_WRITE
    mov     rdi, 1      ; write to the STDOUT file (file descriptor)
    mov     rsi, msg    ; move the memory address of our message string into ecx
    mov     rdx, 13     ; number of bytes to write - one for each letter plus 0Ah (line feed character)
    syscall

    mov     rax, 60     ; invoke SYS_EXIT
    mov     rdi, 0      ; return 0 status on exit - 'No Errors'
    syscall
