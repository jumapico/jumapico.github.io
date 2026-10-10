#!/bin/sh
set -ex

# clean previos files
rm -f blink.o blink.elf blink.hex blink.bin

# build
riscv64-unknown-elf-as -march=rv32im -o blink.o blink.s
riscv64-unknown-elf-ld -T blink.ld -o blink.elf blink.o
riscv64-unknown-elf-objcopy -O ihex blink.elf blink.hex
# why use ihex instead of binary?
riscv64-unknown-elf-objcopy -O binary blink.elf blink.bin

# show info of compiled code
riscv64-unknown-elf-objdump --source --all-headers --demangle --line-numbers \
    --wide --disassembler-options=numeric blink.elf
riscv64-unknown-elf-size blink.elf
