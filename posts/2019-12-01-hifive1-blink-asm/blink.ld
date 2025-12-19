OUTPUT_FORMAT(elf32-littleriscv)
OUTPUT_ARCH(riscv)
ENTRY(_start)
MEMORY
{
    /* start the program after the bootloader; the bootloader is located at
     * 0x20000000 and jumps to 0x20010000 */
    flash (rxai!w) : ORIGIN = 0x20010000, LENGTH = 0x6a120
    ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 0x4000
}
SECTIONS
{
    .text : { *(.text) } >flash AT>flash
    .data : { *(.data) } >ram AT>ram
}
