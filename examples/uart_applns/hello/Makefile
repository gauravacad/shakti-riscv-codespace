PROGRAM = hello
TARGET ?= pinaka

# Toolchain settings
CC := riscv64-unknown-elf-gcc
MARCH = rv32imac
MABI = ilp32

CFLAGS = -march=$(MARCH) -mabi=$(MABI) -O2 -nostdlib -nostartfiles

all: $(PROGRAM).shakti $(PROGRAM).elf

$(PROGRAM).shakti: hello.c
	$(CC) $(CFLAGS) -T ../../../final_touch/spike.ld hello.c -o $(PROGRAM).shakti
	@cp -f $(PROGRAM).shakti $(PROGRAM).elf
	@echo "--> Successfully generated $(PROGRAM).shakti (Shakti ELF Executable)"

$(PROGRAM).elf: $(PROGRAM).shakti

clean:
	rm -f $(PROGRAM).shakti $(PROGRAM).elf $(PROGRAM).dump
