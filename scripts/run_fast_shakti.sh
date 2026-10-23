#!/usr/bin/env bash
# ==============================================================================
# Run Fast Minimized Shakti E-Class Simulation (Instant Boot & Flame Logo)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MINI_DIR="${WORKSPACE_ROOT}/minimized_soc"

echo "=========================================================="
echo " Starting Fast Minimized Shakti E-Class SoC Simulation"
echo " Target : RV32IAC Core with Direct Bus UART Sniffer"
echo " Tool   : Icarus Verilog (iverilog + vvp)"
echo "=========================================================="

cd "${MINI_DIR}"

# Ensure firmware is compiled
if [ ! -f "rtl/firmware.hex" ] || [ ! -f "firmware.hex" ]; then
    echo "==> Building firmware with Shakti Flame Logo..."
    make -C firmware
fi

# Ensure executable permissions
chmod +x run_test.sh

# Run the simulation
./run_test.sh
