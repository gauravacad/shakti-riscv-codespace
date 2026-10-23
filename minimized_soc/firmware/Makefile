# =============================================================================
#  Makefile for Shakti E-Class (RV32IAC) Firmware
# =============================================================================

CROSS   ?= $(shell if [ -f /opt/riscv/bin/riscv64-unknown-elf-gcc ]; then echo /opt/riscv/bin/riscv64-unknown-elf; elif which riscv64-unknown-elf-gcc >/dev/null 2>&1; then echo riscv64-unknown-elf; else echo riscv32-unknown-elf; fi)
CC      = $(CROSS)-gcc
OBJCOPY = $(CROSS)-objcopy
OBJDUMP = $(CROSS)-objdump

ARCH    = -march=rv32iac -mabi=ilp32
CFLAGS  = $(ARCH) -O2 -Wall -nostdlib -ffreestanding
LDFLAGS = $(ARCH) -T link.ld -nostdlib -nostartfiles

SRCS = start.S main.c
OBJS = start.o main.o

.PHONY: all clean

all: firmware.bin firmware.hex
	cp firmware.hex ../rtl/
	cp firmware.hex ../
	@echo "=========================================================="
	@echo "SUCCESS: Built firmware.hex and updated rtl/firmware.hex"
	@echo "=========================================================="

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

firmware.elf: $(OBJS) link.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	$(OBJDUMP) -d $@ > firmware.lst
	$(CROSS)-size $@

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

firmware.hex: firmware.bin
	python3 -c "import struct; data = open('firmware.bin','rb').read(); data = data.ljust(4096, b'\x00'); print('\n'.join('%08x' % struct.unpack_from('<I', data, i)[0] for i in range(0, len(data), 4)))" > $@

clean:
	rm -f *.o *.elf *.bin *.hex *.lst
