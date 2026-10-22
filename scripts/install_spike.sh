#!/usr/bin/env bash
set -e

echo "==> Installing Spike and PK..."

# 1. Compile Spike with recursive submodules (softfloat, etc.)
if ! command -v spike &>/dev/null; then
    echo "--> Cloning and compiling Spike (riscv-isa-sim)..."
    sudo rm -rf /tmp/spike
    git clone --recurse-submodules --depth 1 https://github.com/riscv-software-src/riscv-isa-sim.git /tmp/spike
    mkdir -p /tmp/spike/build && cd /tmp/spike/build
    ../configure --prefix=/usr/local
    make -j$(nproc)
    sudo make install
    sudo rm -rf /tmp/spike
    echo "--> Spike successfully installed!"
else
    echo "--> Spike is already installed at $(which spike)"
fi

# 2. Compile RISC-V Proxy Kernel (pk for rv32)
if ! command -v pk &>/dev/null; then
    echo "--> Cloning and compiling PK (riscv-pk)..."
    sudo rm -rf /tmp/pk
    git clone --depth 1 https://github.com/riscv-software-src/riscv-pk.git /tmp/pk
    mkdir -p /tmp/pk/build && cd /tmp/pk/build
    ../configure --prefix=/usr/local --host=riscv64-unknown-elf --with-arch=rv32i_zicsr_zifencei --with-abi=ilp32
    make -j$(nproc)
    sudo make install
    sudo rm -rf /tmp/pk
    echo "--> PK successfully installed!"
else
    echo "--> PK is already installed at $(which pk)"
fi
