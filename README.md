# Shakti E-Class & RISC-V Development Codespace

This repository provides an automated, high-performance **GitHub Codespaces** development environment for Shakti RISC-V E-Class processor design, simulation, and software development.

---

## ⚡ Simulation Options: Fast-Track vs Full SoC

### Option 1: Fast Minimized Shakti SoC (Recommended — 1-2 Seconds!)
Boots an authentic **IIT Madras Shakti E-Class (RV32IAC)** core in Icarus Verilog (`iverilog` + `vvp`) and prints the full **ASCII Shakti Flame Logo** directly to your terminal in under 2 seconds:

```bash
./scripts/run_fast_shakti.sh
```

**Why it's so fast:**
- **Trimmed Core (RV32IAC):** 3-stage pipelined Shakti E-Class without bloated peripheral overhead or missing multiplier primitives.
- **Direct-Bus UART Sniffer:** Testbench sniffs CPU writes to the UART data register directly, outputting characters in 1 clock cycle instead of waiting thousands of cycles for serial bit-shifting (eliminates baud drift and garbage characters).
- **Embedded Flame Logo Bootloader:** Located under `minimized_soc/firmware/main.c`, targeting BRAM memory directly.

---

### Option 2: Accelerated Pure SP2020 Simulation (`baud_fix` — 81.5x Faster!)
Runs the pure **IIT Madras Pinaka SoC (`sp2020/e32-a35`)** with full Bluespec core and AXI bus, but uses the simulation baud trick (`divisor = 2`, $32\text{ cycles/bit}$ instead of $2,608$):

```bash
chmod +x ./baud_fix/run_baud_fix.sh
./baud_fix/run_baud_fix.sh
```
- **Execution Speed:** Text streams out in 3 to 5 seconds (**81.5x faster** than physical 19,200 baud).
- **Core RTL Integrity:** The Shakti processor core, caches, and interconnect are 100% pure and untouched.

---

### Option 3: Real-Time Physical Baud SP2020 Simulation (`script_2020_fix`)
Runs the pure Pinaka SoC at physical real-time 19,200 Baud ($2,608\text{ clocks/bit}$):

```bash
chmod +x ./script_2020_fix/run_sp2020.sh
./script_2020_fix/run_sp2020.sh
```

---

### Option 4: Spike RISC-V ISA Simulator
Run your RISC-V ELF directly in the Spike simulator:

```bash
./scripts/run_spike.sh
```

---

## 🛠 Included Tools & Environment

The container comes pre-configured with:
- **RISC-V Toolchain:** Prebuilt SiFive multilib `riscv64-unknown-elf-gcc` / `riscv32-unknown-elf-gcc` with full Newlib C library support.
- **Simulators:** 
  - `spike` (RISC-V ISA simulator)
  - `pk` (RISC-V 32-bit proxy kernel)
  - `iverilog` & `vvp` (Icarus Verilog)
  - `verilator`
- **Bluespec Compiler:** BSC 2024.07 (`BLUESPECDIR=/usr/local/lib`).
- **Hardware Debug & Utility:** `openocd`, `gdb-multiarch`, `gtkwave`.
- **Python EDA tools:** `pyserial`, `miniterm`.
- **Shakti Repositories (Editable in Workspace):**
  - `minimized_soc/`: Fast-booting trimmed Shakti E-Class SoC with authentic Flame Logo.
  - `shakti-e-class`: [https://github.com/anmolsahoo25/shakti-e-class](https://github.com/anmolsahoo25/shakti-e-class)
  - `shakti-sdk`: [https://gitlab.com/shaktiproject/software/shakti-sdk.git](https://gitlab.com/shaktiproject/software/shakti-sdk.git)
  - `sp2020/e32-a35`: [https://gitlab.com/shaktiproject/sp2020/-/tree/master/e32-a35](https://gitlab.com/shaktiproject/sp2020/-/tree/master/e32-a35)

---

## 🚀 How to Launch in GitHub Codespaces

1. Push this repository to GitHub.
2. Open your repository on GitHub.
3. Click **Code** -> **Codespaces** -> **Create codespace on main**.
4. Once loaded, open a terminal in VS Code and run:
   ```bash
   ./scripts/run_fast_shakti.sh
   ```
