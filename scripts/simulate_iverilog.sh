#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Check paths for sp2020 or base-sim
if [ -d "${WORKSPACE_ROOT}/sp2020/e32-a35" ]; then
    TARGET_DIR="${WORKSPACE_ROOT}/sp2020/e32-a35"
elif [ -d "${WORKSPACE_ROOT}/shakti-e-class/base-sim" ]; then
    TARGET_DIR="${WORKSPACE_ROOT}/shakti-e-class/base-sim"
else
    echo "Error: Target directory for E-Class not found."
    exit 1
fi

echo "=========================================================="
echo " Running Simulation Flow for Shakti E-Class"
echo " Target: ${TARGET_DIR}"
echo "=========================================================="

cd "${TARGET_DIR}"

# 1. Generate Verilog from BSV
echo "==> 1. Generating Verilog from Bluespec (make generate_verilog)..."
make generate_verilog || make CONFIG=soc_config.inc generate_verilog

# 2. Generate Boot Files (includes boot code with ASCII Shakti logo)
echo "==> 2. Generating Boot files (make generate_boot_files)..."
make generate_boot_files || make CONFIG=soc_config.inc generate_boot_files

# 3. Simulate with Verilator or Icarus Verilog
echo "==> 3. Linking simulation..."
if make -n link_verilator &>/dev/null; then
    echo "--> Compiling with Verilator simulation testbench..."
    make link_verilator || make CONFIG=soc_config.inc link_verilator
    echo "==> 4. Running Simulation binary to print Shakti Logo:"
    if [ -f "bin/out" ]; then
        cd bin && ./out
    fi
else
    echo "--> Running Icarus Verilog compilation on generated Verilog files..."
    mkdir -p sim_build
    iverilog -g2012 -o sim_build/e32_sim \
        -I /usr/local/lib/Verilog \
        -I verilog \
        "${SCRIPT_DIR}/tb/uart_rx_monitor.v" \
        verilog/*.v
    echo "==> 4. Executing simulation with vvp (watching UART output):"
    vvp sim_build/e32_sim
fi
