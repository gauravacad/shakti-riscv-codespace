#!/usr/bin/env bash

echo "============================================"
echo " Environment and Toolchain Diagnostics"
echo "============================================"

echo -n "1. Bluespec Compiler (bsc):      "
if command -v bsc &>/dev/null; then
    bsc -v 2>&1 | head -n 1
else
    echo "MISSING"
fi

echo -n "2. RISC-V 32-bit GCC:             "
if command -v riscv32-unknown-elf-gcc &>/dev/null; then
    riscv32-unknown-elf-gcc --version | head -n 1
else
    echo "MISSING"
fi

echo -n "3. RISC-V 64-bit GCC:             "
if command -v riscv64-unknown-elf-gcc &>/dev/null; then
    riscv64-unknown-elf-gcc --version | head -n 1
else
    echo "MISSING"
fi

echo -n "4. Spike Simulator:               "
if command -v spike &>/dev/null; then
    which spike
else
    echo "MISSING"
fi

echo -n "5. RISC-V Proxy Kernel (pk):      "
if command -v pk &>/dev/null; then
    which pk
else
    echo "MISSING"
fi

echo -n "6. Icarus Verilog (iverilog):     "
if command -v iverilog &>/dev/null; then
    iverilog -V | head -n 1
else
    echo "MISSING"
fi

echo -n "7. Verilator:                     "
if command -v verilator &>/dev/null; then
    verilator --version
else
    echo "MISSING"
fi

echo -n "8. Python PySerial:               "
python3 -c "import serial; print(serial.__version__)" 2>/dev/null || echo "MISSING"

echo -n "9. Miniterm:                      "
if command -v miniterm &>/dev/null; then
    which miniterm
else
    echo "MISSING"
fi

echo -n "10. BLUESPECDIR variable:         "
echo "${BLUESPECDIR:-NOT SET}"

echo "============================================"
