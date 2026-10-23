#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TB_DIR="${SCRIPT_DIR}/tb"

echo "=========================================================="
echo " 1. Setting Up Design Directory"
echo "=========================================================="

if [ -d "${WORKSPACE_ROOT}/sp2020/e32-a35" ]; then
    DESIGN_DIR="${WORKSPACE_ROOT}/sp2020/e32-a35"
elif [ -d "${WORKSPACE_ROOT}/shakti-e-class/base-sim" ]; then
    DESIGN_DIR="${WORKSPACE_ROOT}/shakti-e-class/base-sim"
else
    echo "Error: Neither sp2020/e32-a35 nor shakti-e-class/base-sim found."
    exit 1
fi

echo "--> Target design directory: ${DESIGN_DIR}"
cd "${DESIGN_DIR}"

echo ""
echo "=========================================================="
echo " 2. Applying Makefile Fixes (Stack limit & filter)"
echo "=========================================================="
if [ -f "Makefile" ]; then
    sed -i 's/-K40000M/-K4000M/g' Makefile
    sed -i 's|-verilog-filter [^ ]*||g' Makefile
    echo "--> Makefile patched successfully."
fi

echo ""
echo "=========================================================="
echo " 3. Compiling Bluespec to Verilog (make generate_verilog)"
echo "=========================================================="
make generate_verilog || make CONFIG=soc_config.inc generate_verilog
echo "--> Verilog generation completed successfully!"

echo ""
echo "=========================================================="
echo " 4. Compiling Boot Code & Shakti Logo (make generate_boot_files)"
echo "=========================================================="
make generate_boot_files || make CONFIG=soc_config.inc generate_boot_files
echo "--> Boot files generated successfully!"

echo ""
echo "=========================================================="
echo " 5. Compiling Simulation with Icarus Verilog (iverilog)"
echo "=========================================================="

BSV_VERILOG_DIR="/usr/local/lib/Verilog"
if [ ! -d "${BSV_VERILOG_DIR}" ]; then
    BSV_VERILOG_DIR="/usr/local/lib/Libraries/Verilog"
fi

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

echo "--> iverilog build complete: sim_vvp/shakti_soc.vvp created."

echo ""
echo "=========================================================="
echo " 6. Running Simulation with VVP (Booting Shakti & Logo)"
echo "=========================================================="
vvp sim_vvp/shakti_soc.vvp
