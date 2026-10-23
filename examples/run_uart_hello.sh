#!/usr/bin/env bash
# ==============================================================================
# Build & Run Shakti UART Application (examples/uart_applns/hello)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo " Running Shakti UART Application (examples/uart_applns)"
echo "=========================================================="

# Check if shakti-sdk is cloned in Codespace
if [ -d "${WORKSPACE_ROOT}/shakti-sdk" ]; then
    echo "--> Found shakti-sdk directory at: ${WORKSPACE_ROOT}/shakti-sdk"
    cd "${WORKSPACE_ROOT}/shakti-sdk"
    
    echo "--> Available applications in shakti-sdk:"
    make list_applns 2>/dev/null | grep -i "uart" || echo "Listing complete."
    
    echo ""
    echo "--> Building hello application in shakti-sdk:"
    make software PROGRAM=hello TARGET=pinaka || true
fi

# Also build the standalone examples/uart_applns/hello
echo ""
echo "--> Building standalone examples/uart_applns/hello..."
cd "${SCRIPT_DIR}/uart_applns/hello"
make clean
make

echo ""
echo "=========================================================="
echo " Build Complete: examples/uart_applns/hello/hello.elf"
echo "=========================================================="
