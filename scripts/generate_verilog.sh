#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BASE_SIM="${WORKSPACE_ROOT}/shakti-e-class/base-sim"

if [ ! -d "${BASE_SIM}" ]; then
    echo "Error: Directory ${BASE_SIM} does not exist."
    exit 1
fi

export BLUESPECDIR=/usr/local/lib
export PATH=/usr/local/bin:/opt/riscv/bin:$PATH

echo "==> Changing directory to ${BASE_SIM}"
cd "${BASE_SIM}"

echo "==> Ensuring manager.sh update_deps is run..."
chmod +x manager.sh
./manager.sh update_deps

echo "==> Compiling Bluespec to Verilog (CONFIG=soc_config.inc)..."
make CONFIG=soc_config.inc generate_verilog

echo "==> Verilog generation complete! Check '${BASE_SIM}/verilog' for output files."
