# Hello World Program
# Compile with: riscv64-linux-gnu-as helloworldrv64.s -o helloworldrv64.o
# Link with:    riscv64-linux-gnu-ld helloworldrv64.o -o helloworldrv64
# Run with:     qemu-riscv64-static ./helloworldrv64

        .data
msg:    .asciz  "Hello World!\n"        # assign msg variable with your message string

        .text
        .global _start

_start:
        li        a7, 64        # invoke SYS_WRITE
        li        a0, 1         # write to the STDOUT file (file descriptor)
        la        a1, msg       # move the memory address of our message string
        li        a2, 13        # number of bytes to write - one for each character
        ecall

        li        a7, 93        # invoke SYS_EXIT
        li        a0, 0         # return 0 status on exit - 'No Errors'
        ecall

end:
        j end
