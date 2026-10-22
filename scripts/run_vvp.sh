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

# 0. Automatically apply Makefile and Boot-Code fixes
if [ -f "Makefile" ]; then
    sed -i 's/-K40000M/-K4000M/g' Makefile
    sed -i 's|-verilog-filter [^ ]*||g' Makefile
fi

if [ -f "boot-code/Makefile" ]; then
    sed -i 's/--specs=picolibc.specs//g' boot-code/Makefile
    sed -i 's/-march=rv$(XLEN)imac/-march=rv$(XLEN)imac -mabi=ilp32/g' boot-code/Makefile
fi

# Determine config file (core_config.inc for sp2020 or soc_config.inc for base-sim)
CFG="core_config.inc"
if [ ! -f "${CFG}" ] && [ -f "soc_config.inc" ]; then
    CFG="soc_config.inc"
fi

# 1. Ensure Verilog files are generated
if [ ! -d "verilog" ] || [ -z "$(ls -A verilog/*.v 2>/dev/null)" ]; then
    echo "==> Generating Verilog files from Bluespec (CONFIG=${CFG})..."
    make generate_verilog CONFIG="${CFG}" || make generate_verilog
fi

# 2. Ensure Boot ROM files are generated
echo "==> Ensuring boot code (with Shakti logo) is compiled..."
make generate_boot_files CONFIG="${CFG}" || make generate_boot_files

# 3. Locate Bluespec Verilog library primitives
BSV_VERILOG_DIR="/usr/local/lib/Verilog"
if [ ! -d "${BSV_VERILOG_DIR}" ]; then
    BSV_VERILOG_DIR="/usr/local/lib/Libraries/Verilog"
fi

# 4. Compile strictly with iverilog
echo "==> Compiling SoC Verilog with iverilog..."
mkdir -p sim_vvp

# Find all project directories containing .v files (common_verilog, devices, etc.)
V_FLAGS="-I ${BSV_VERILOG_DIR} -y ${BSV_VERILOG_DIR} -I verilog -y verilog"
for vdir in common_verilog common_verilog/* devices devices/* fabrics fabrics/*; do
    if [ -d "$vdir" ]; then
        V_FLAGS="${V_FLAGS} -I ${vdir} -y ${vdir}"
    fi
done

iverilog -g2012 \
    -o sim_vvp/shakti_soc.vvp \
    ${V_FLAGS} \
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
