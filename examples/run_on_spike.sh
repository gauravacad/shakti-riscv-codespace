#!/usr/bin/env bash
# ==============================================================================
# Run hello.shakti directly on Spike RISC-V Simulator in Codespace
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_PATH="${SCRIPT_DIR}/uart_applns/hello/hello.shakti"

echo "=========================================================="
echo " Running hello.shakti on Spike RISC-V ISA Simulator"
echo "=========================================================="

if [ ! -f "${BIN_PATH}" ]; then
    echo "--> Compiling hello.shakti..."
    cd "${SCRIPT_DIR}/uart_applns/hello"
    make
fi

echo "--> Executable: ${BIN_PATH}"
echo "--> Target ISA: RV32IMAC"
echo ""

if command -v spike >/dev/null 2>&1; then
    spike --isa=rv32imac "${BIN_PATH}"
else
    echo "Error: 'spike' simulator binary not found in PATH."
    echo "Please ensure Spike is installed in your environment."
    exit 1
fi
