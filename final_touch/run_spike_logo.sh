#!/usr/bin/env bash
# ==============================================================================
# Compile and run Shakti Flame Logo directly on Spike (HTIF, Zero PK needed!)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "=========================================================="
echo " Compiling Shakti HTIF Boot Logo for Spike..."
echo "=========================================================="

# Compile with 32-bit RISC-V GCC
riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 \
    -nostdlib -nostartfiles -T spike.ld \
    shakti_boot_logo.c -o shakti_boot_logo32.elf

echo "--> Compilation successful: shakti_boot_logo32.elf"

echo ""
echo "=========================================================="
echo " Running Shakti Flame Logo on Spike Simulator (Instant!):"
echo "=========================================================="

spike --isa=rv32imac shakti_boot_logo32.elf
