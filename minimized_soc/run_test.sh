#!/usr/bin/env bash
# ==============================================================================
# Simulation Runner for Shakti E-Class with Flame Boot Logo
# ==============================================================================
set -e

cd "$(dirname "$0")"

touch rtl/boot.mem rtl/code.mem rtl/code1.mem boot.mem code.mem code1.mem

echo "============================================================"
echo " 1. Compiling Shakti E-Class SoC with Icarus Verilog"
echo "============================================================"
iverilog -g2012 -o sim_soc -I rtl rtl/*.v tb/tb_soc.v

echo "============================================================"
echo " 2. Running Cycle-Accurate Simulation"
echo "============================================================"
vvp sim_soc
