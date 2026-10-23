#!/usr/bin/env bash
# ==============================================================================
# Compile and run Hello World on Shakti RISC-V in GitHub Codespace (Spike)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "=========================================================="
echo " 1. Compiling Shakti Hello World C program..."
echo "=========================================================="

# Check if riscv compiler is available
if command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    CC="riscv64-unknown-elf-gcc"
elif command -v riscv32-unknown-elf-gcc >/dev/null 2>&1; then
    CC="riscv32-unknown-elf-gcc"
else
    echo "Error: RISC-V GCC cross compiler not found in PATH."
    echo "Please ensure the RISC-V toolchain is installed."
    exit 1
fi

${CC} -march=rv32imac -mabi=ilp32 \
    -nostdlib -nostartfiles -T spike.ld \
    hello_shakti.c -o hello_shakti32.elf

echo "--> Built: hello_shakti32.elf (RV32IMAC baremetal binary)"
echo ""
echo "=========================================================="
echo " 2. Executing on Spike RISC-V ISA Simulator:"
echo "=========================================================="

if command -v spike >/dev/null 2>&1; then
    spike --isa=rv32imac hello_shakti32.elf
else
    echo "Error: 'spike' simulator not found in PATH."
    echo "You can run with: sudo apt-get install device-tree-compiler && ..."
    exit 1
fi
