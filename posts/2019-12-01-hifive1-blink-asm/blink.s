#
# Blink led
#
.set GPIO_INSTANCE_0, 0x10012000
.set OUTPUT_EN, 0x08
.set OUTPUT_XOR, 0x40
.set OUTPUT_VAL, 0x0c
.set ALL_LEDS, (1 << 19) | (1 << 21) | (1 << 22)  # Green/Blue/Red
.set ONE_SECOND, 6900000  # At 13.8MHz

.section .text

.global _start

_start:
    # Setup GPIO controller
    li x2, GPIO_INSTANCE_0
    li x3, ALL_LEDS
    sw x3, OUTPUT_EN(x2)
    sw x3, OUTPUT_XOR(x2)

main:
    # turn on all leds
    sw x3, OUTPUT_VAL(x2)
    jal x1, delay
    # turn off all leds
    sw x0, OUTPUT_VAL(x2)
    jal x1, delay
    # repeat forever
    jal x0, main

delay:
    li x4, ONE_SECOND
delay_loop:
    addi x4, x4, -1
    bne x4, x0, delay_loop
    jalr x0, x1, 0
