PROGRAM = hello
TARGET ?= pinaka

# Toolchain settings
CC ?= riscv64-unknown-elf-gcc
MARCH = rv32imac
MABI = ilp32

CFLAGS = -march=$(MARCH) -mabi=$(MABI) -O2 -nostdlib -nostartfiles

all: $(PROGRAM).elf

$(PROGRAM).elf: hello.c
	$(CC) $(CFLAGS) -T ../../../final_touch/spike.ld hello.c -o $(PROGRAM).elf
	@echo "--> Successfully built $(PROGRAM).elf for $(TARGET) ($(MARCH))"

clean:
	rm -f $(PROGRAM).elf
