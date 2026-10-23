#!/usr/bin/env bash
# ==============================================================================
# Compile and run Hello World on Spike with Proxy Kernel (PK)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${WORKSPACE_ROOT}"

echo "=========================================================="
echo " Compiling Hello World with SiFive RISC-V GCC..."
echo "=========================================================="

riscv64-unknown-elf-gcc -O2 examples/hello.c -o hello.riscv
echo "--> Compilation successful: hello.riscv"

echo ""
echo "=========================================================="
echo " Executing on Spike Simulator with PK:"
echo "=========================================================="

spike pk hello.riscv
