#!/usr/bin/env bash
# ==============================================================================
# run_sp2020.sh — Pure Shakti E-Class (Pinaka / SP2020 SoC) Simulation
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo " Starting Pure Shakti E-Class SP2020 Simulation"
echo " Board Target : Pinaka SoC (Artix7-35T Core)"
echo " UART Baud    : 19,200 Baud @ 50 MHz (2,608 Clocks/Bit)"
echo " Simulator    : Icarus Verilog (iverilog + vvp)"
echo "=========================================================="

# 1. Locate sp2020 design directory
if [ -d "${WORKSPACE_ROOT}/sp2020/e32-a35" ]; then
    DESIGN_DIR="${WORKSPACE_ROOT}/sp2020/e32-a35"
elif [ -d "${WORKSPACE_ROOT}/e32-a35" ]; then
    DESIGN_DIR="${WORKSPACE_ROOT}/e32-a35"
else
    echo "Error: Could not locate sp2020/e32-a35 directory in ${WORKSPACE_ROOT}."
    exit 1
fi

cd "${DESIGN_DIR}"

# 2. Apply non-invasive compatibility fixes to Makefiles
if [ -f "Makefile" ]; then
    sed -i 's/-K40000M/-K4000M/g' Makefile
    sed -i 's|-verilog-filter [^ ]*||g' Makefile
fi

if [ -f "boot-code/Makefile" ]; then
    sed -i 's/--specs=picolibc.specs//g' boot-code/Makefile
    sed -i 's/-march=rv$(XLEN)imac/-march=rv$(XLEN)imac -mabi=ilp32/g' boot-code/Makefile
fi

# 3. Ensure pipelined multiplier model is present
if [ -d "common_verilog" ]; then
    cp -f "${SCRIPT_DIR}/multiplier.v" common_verilog/multiplier.v
fi

# 4. Generate Verilog from Bluespec BSV if not yet present
CFG="core_config.inc"
if [ ! -d "verilog" ] || [ -z "$(ls -A verilog/*.v 2>/dev/null)" ]; then
    echo "==> Generating pure Shakti Verilog from Bluespec (CONFIG=${CFG})..."
    make generate_verilog CONFIG="${CFG}" || make generate_verilog
fi

# 5. Build authentic Boot ROM image (boot.mem)
echo "==> Building authentic SP2020 Boot ROM code..."
make generate_boot_files CONFIG="${CFG}" || make generate_boot_files

# 6. Locate Bluespec Verilog library primitives
BSV_VERILOG_DIR="/usr/local/lib/Verilog"
if [ ! -d "${BSV_VERILOG_DIR}" ]; then
    BSV_VERILOG_DIR="/usr/local/lib/Libraries/Verilog"
fi

# 7. Compile pure SP2020 SoC with Icarus Verilog
echo "==> Compiling complete SP2020 SoC with iverilog..."
mkdir -p sim_sp2020

V_FLAGS="-I ${BSV_VERILOG_DIR} -y ${BSV_VERILOG_DIR} -I verilog -y verilog"
for vdir in common_verilog common_verilog/* devices devices/* fabrics fabrics/*; do
    if [ -d "$vdir" ]; then
        V_FLAGS="${V_FLAGS} -I ${vdir} -y ${vdir}"
    fi
done

iverilog -g2012 \
    -o sim_sp2020/shakti_soc.vvp \
    ${V_FLAGS} \
    "${SCRIPT_DIR}/multiplier.v" \
    "${SCRIPT_DIR}/uart_rx_monitor.v" \
    "${SCRIPT_DIR}/tb_soc_sp2020.v" \
    verilog/*.v

echo "==> Compilation successful: sim_sp2020/shakti_soc.vvp created."

# 8. Copy boot.mem and initialize memory files
BOOT_MEM=$(find boot-code -name "boot.mem" 2>/dev/null | head -n 1)
if [ -z "${BOOT_MEM}" ]; then
    BOOT_MEM=$(find . -name "boot.mem" 2>/dev/null | head -n 1)
fi

if [ -n "${BOOT_MEM}" ]; then
    echo "--> Loaded Boot ROM image: ${BOOT_MEM}"
    cp -f "${BOOT_MEM}" boot.mem 2>/dev/null || true
    cp -f "${BOOT_MEM}" sim_sp2020/boot.mem 2>/dev/null || true
fi

# Create zero-fill RAM memory files so $readmemh succeeds cleanly
touch code.mem code1.mem
touch sim_sp2020/code.mem sim_sp2020/code1.mem

echo ""
echo "=========================================================="
echo " Executing Pure Shakti SP2020 Cycle-Accurate Simulation:"
echo "=========================================================="

# 9. Run VVP simulation
vvp sim_sp2020/shakti_soc.vvp "$@"
