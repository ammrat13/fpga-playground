# This Makefile assembles the only file in this directory and outputs a `.mem`
#  file to be loaded with `$readmemh`.
# By default, it uses the LLVM toolchain for compiling and linking.

# The compilation flow is:
#     Assembly (`.s`)
#  -> Object File (`.o`)
#  -> Linked ELF File (`.elf`)
#  -> Hexdump of ELF File in raw binary (`.hex`)
#  -> Hexdump of ELF File in text readable by `$readmemh` (`.mem`)


CC := clang
LD := ld.lld
OBJCOPY := llvm-objcopy

CFLAGS := --target=riscv32 -march=rv32i
OBJCOPYFLAGS := -O binary


.PHONY : all
all : program.mem

.PHONY : clean
clean :
	rm -rfv *.o *.elf *.hex *.mem


%.mem : %.hex
	xxd -e -c 4 $< | awk '{print $$2}' > $@

%.hex : %.elf
	$(OBJCOPY) $(OBJCOPYFLAGS) $< $@

%.elf : %.o
	$(LD) -o $@ $^

%.o : %.s
	$(CC) $(CFLAGS) -c -o $@ $^
