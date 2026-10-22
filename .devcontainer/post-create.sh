#!/usr/bin/env bash
set -e

echo "=========================================================="
echo " Starting Post-Create Setup for Shakti & RISC-V Codespace"
echo "=========================================================="

WORKSPACE_DIR="$(pwd)"

# 1. Verify installed toolchain components
echo "--> Checking installed tools:"
echo "    BSC:           $(bsc -v 2>&1 | head -n 1 || echo 'Not found')"
echo "    RISC-V GCC:    $(riscv32-unknown-elf-gcc --version 2>&1 | head -n 1 || echo 'Not found')"
echo "    Spike:         $(which spike || echo 'Not found')"
echo "    PK:            $(which pk || echo 'Not found')"
echo "    IcarusVerilog: $(iverilog -V 2>&1 | head -n 1 || echo 'Not found')"
echo "    Verilator:     $(verilator --version 2>&1 | head -n 1 || echo 'Not found')"
echo "    Python Serial: $(python3 -c 'import serial; print(serial.__file__)' 2>&1 || echo 'Not found')"

# 2. Clone Shakti SDK if not already present
if [ ! -d "${WORKSPACE_DIR}/shakti-sdk" ]; then
    echo "--> Cloning shakti-sdk..."
    git clone https://gitlab.com/shaktiproject/software/shakti-sdk.git "${WORKSPACE_DIR}/shakti-sdk"
else
    echo "--> shakti-sdk already present, skipping clone."
fi

# 3. Clone Shakti E-Class if not already present
if [ ! -d "${WORKSPACE_DIR}/shakti-e-class" ]; then
    echo "--> Cloning shakti-e-class from https://github.com/anmolsahoo25/shakti-e-class..."
    git clone https://github.com/anmolsahoo25/shakti-e-class "${WORKSPACE_DIR}/shakti-e-class"
else
    echo "--> shakti-e-class already present, skipping clone."
fi

# 4. Clone Shakti SP2020 (Swadeshi Microprocessor Challenge - includes e32-a35 SoC Pinaka)
if [ ! -d "${WORKSPACE_DIR}/sp2020" ]; then
    echo "--> Cloning sp2020 (containing e32-a35 SoC) from https://gitlab.com/shaktiproject/sp2020.git..."
    git clone https://gitlab.com/shaktiproject/sp2020.git "${WORKSPACE_DIR}/sp2020"
    if [ -d "${WORKSPACE_DIR}/sp2020/e32-a35" ] && [ ! -e "${WORKSPACE_DIR}/e32-a35" ]; then
        ln -s "${WORKSPACE_DIR}/sp2020/e32-a35" "${WORKSPACE_DIR}/e32-a35"
        echo "--> Linked e32-a35 directly to workspace root for convenient access."
    fi
else
    echo "--> sp2020 already present, skipping clone."
fi

# 5. Apply Base-Sim Makefile Fixes
if [ -d "${WORKSPACE_DIR}/shakti-e-class/base-sim" ]; then
    echo "--> Applying Makefile bugfixes in shakti-e-class/base-sim/Makefile..."
    cd "${WORKSPACE_DIR}/shakti-e-class/base-sim"

    # Fix GHC stack allocation limit integer overflow (-K40000M -> -K4000M)
    sed -i 's/-K40000M/-K4000M/g' Makefile

    # Remove legacy verilog-filter looking for non-existent basicinout
    sed -i 's|-verilog-filter [^ ]*||g' Makefile

    # Fix manager.sh permissions and pull submodules
    if [ -f "manager.sh" ]; then
        chmod +x manager.sh
        echo "--> Pulling SoC bus, UART, and CLINT dependencies (./manager.sh update_deps)..."
        ./manager.sh update_deps || echo "Warning: manager.sh update_deps had warnings, continuing..."
    fi

    cd "${WORKSPACE_DIR}"
fi

# 6. Make helper scripts executable
if [ -d "${WORKSPACE_DIR}/scripts" ]; then
    chmod +x ${WORKSPACE_DIR}/scripts/*.sh 2>/dev/null || true
fi

# 7. Install Spike & PK in background/gracefully
if [ -f "${WORKSPACE_DIR}/scripts/install_spike.sh" ]; then
    echo "--> Installing Spike and PK..."
    bash "${WORKSPACE_DIR}/scripts/install_spike.sh" || echo "Warning: Spike build had an issue, you can run ./scripts/install_spike.sh manually."
fi

echo "=========================================================="
echo " Codespace Setup Complete!"
echo " You can now edit any source files under:"
echo "   - shakti-e-class/    (Core BSV source and SoC simulations)"
echo "   - shakti-sdk/        (Baremetal SDK and software drivers)"
echo "   - sp2020/e32-a35/    (Pinaka SoC FPGA board files, OpenOCD & bitstreams)"
echo ""
echo " To generate Verilog: run './scripts/generate_verilog.sh'"
echo " or cd shakti-e-class/base-sim && make CONFIG=soc_config.inc generate_verilog"
echo "=========================================================="
