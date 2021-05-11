# The code to run on the SoC
# Be careful about linking. Right now, linking and objcopying works fine, but it
#  may not in the future. Write a linker script when that happens.


.globl _start
.p2align 2
_start:

strcpy:
    li t0, 0x00010000
    la t1, string
strcpy_loop:
    lb t2, 0x0(t1)
    sb t2, 0x0(t0)
    beqz t2, counter
    addi t0, t0, 1
    addi t1, t1, 1
    j strcpy_loop

counter:
    li t0, 0xfffffffc
    li t1, 0x0
counter_loop:
    sw t1, 0x0(t0)
    addi t1, t1, 1
    j counter_loop

string:
    .string "Hello world!"
    .zero 3
