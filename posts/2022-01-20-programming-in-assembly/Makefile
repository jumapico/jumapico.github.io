all: helloworld helloworld64 helloworldrv64
helloworld: helloworld.asm
	nasm -f elf helloworld.asm
	ld -m elf_i386 helloworld.o -o helloworld
helloworld64: helloworld64.asm
	nasm -f elf64 helloworld64.asm
	ld -m elf_x86_64 helloworld64.o -o helloworld64
helloworldrv64: helloworldrv64.s
	riscv64-linux-gnu-as helloworldrv64.s -o helloworldrv64.o
	riscv64-linux-gnu-ld helloworldrv64.o -o helloworldrv64
clean:
	rm -f *.o helloworld helloworld64 helloworldrv64
.PHONY: clean
