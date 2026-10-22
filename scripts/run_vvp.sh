#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TB_DIR="${SCRIPT_DIR}/tb"

echo "=========================================================="
echo " Shakti E-Class Simulation on Icarus Verilog (vvp only)"
echo "=========================================================="

# Find which directory has the design (sp2020 or base-sim)
if [ -d "${WORKSPACE_ROOT}/sp2020/e32-a35" ]; then
    DESIGN_DIR="${WORKSPACE_ROOT}/sp2020/e32-a35"
elif [ -d "${WORKSPACE_ROOT}/shakti-e-class/base-sim" ]; then
    DESIGN_DIR="${WORKSPACE_ROOT}/shakti-e-class/base-sim"
else
    echo "Error: Neither sp2020/e32-a35 nor shakti-e-class/base-sim found."
    exit 1
fi

cd "${DESIGN_DIR}"

# 1. Ensure Verilog files are generated
if [ ! -d "verilog" ] || [ -z "$(ls -A verilog/*.v 2>/dev/null)" ]; then
    echo "==> Generating Verilog files from Bluespec..."
    make generate_verilog || make CONFIG=soc_config.inc generate_verilog
fi

# 2. Ensure Boot ROM files are generated
echo "==> Ensuring boot code (with Shakti logo) is compiled..."
make generate_boot_files || make CONFIG=soc_config.inc generate_boot_files

# 3. Locate Bluespec Verilog library primitives
BSV_VERILOG_DIR="/usr/local/lib/Verilog"
if [ ! -d "${BSV_VERILOG_DIR}" ]; then
    BSV_VERILOG_DIR="/usr/local/lib/Libraries/Verilog"
fi

# 4. Compile strictly with iverilog
echo "==> Compiling SoC Verilog with iverilog..."
mkdir -p sim_vvp
iverilog -g2012 \
    -o sim_vvp/shakti_soc.vvp \
    -I "${BSV_VERILOG_DIR}" \
    -I verilog \
    -y "${BSV_VERILOG_DIR}" \
    -y verilog \
    "${TB_DIR}/uart_rx_monitor.v" \
    "${TB_DIR}/tb_soc_vvp.v" \
    verilog/*.v

echo "==> Compilation successful: sim_vvp/shakti_soc.vvp created."
echo ""
echo "=========================================================="
echo " Executing Simulation with VVP (Watching UART for Logo):"
echo "=========================================================="

# 5. Run simulation strictly on vvp
vvp sim_vvp/shakti_soc.vvp
