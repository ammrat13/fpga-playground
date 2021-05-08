# The code to run on the SoC
# Be careful about linking. Right now, linking and objcopying works fine, but it
#  may not in the future. Write a linker script when that happens.


.globl _start
_start:
    li t0, 0xfffffffc
    li t1, 0x00000000

loop:
    addi t1, t1, 0x1
    sw t1, 0x0(t0)

    jal zero, loop
