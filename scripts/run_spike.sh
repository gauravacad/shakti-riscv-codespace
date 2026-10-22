#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo " Running Shakti Boot Code on Spike (ISA Simulator)"
echo "=========================================================="

# Check if spike is installed
if ! command -v spike &>/dev/null; then
    echo "Error: spike command not found."
    echo "Please run './scripts/install_spike.sh' first to compile and install Spike."
    exit 1
fi

BOOT_ELF="${WORKSPACE_ROOT}/sp2020/e32-a35/boot-code/boot.shakti"

# If boot.shakti is not yet compiled, build it
if [ ! -f "${BOOT_ELF}" ]; then
    echo "--> Compiling boot code first..."
    cd "${WORKSPACE_ROOT}/sp2020/e32-a35/boot-code"
    sed -i 's/-march=rv$(XLEN)imac/-march=rv$(XLEN)imac -mabi=ilp32/g' Makefile 2>/dev/null || true
    make
fi

if [ -f "${BOOT_ELF}" ]; then
    echo "--> Running ${BOOT_ELF} on Spike (rv32imac)..."
    spike --isa=rv32imac -m0x1000:0x100000 "${BOOT_ELF}"
else
    echo "Error: ${BOOT_ELF} could not be found."
    exit 1
fi
