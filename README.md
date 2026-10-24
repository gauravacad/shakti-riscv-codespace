# Shakti E-Class & RISC-V Development Codespace

This repository provides an automated, high-performance **GitHub Codespaces** development environment for Shakti RISC-V E-Class processor design, simulation, and software development.

---

## ⚡ Simulation Options
---

### Option 1: Accelerated Pure SP2020 Simulation (`baud_fix` — 81.5x Faster!)
Runs the pure **IIT Madras Pinaka SoC (`sp2020/e32-a35`)** with full Bluespec core and AXI bus, but uses the simulation baud trick (`divisor = 2`, $32\text{ cycles/bit}$ instead of $2,608$):

```bash
chmod +x ./baud_fix/run_baud_fix.sh
./baud_fix/run_baud_fix.sh
```
- **Execution Speed:** Text streams out in 3 to 5 seconds (**81.5x faster** than physical 19,200 baud).
- **Core RTL Integrity:** The Shakti processor core, caches, and interconnect are 100% pure and untouched.

---

### Option 2: Real-Time Physical Baud SP2020 Simulation (`script_2020_fix`)
Runs the pure Pinaka SoC at physical real-time 19,200 Baud ($2,608\text{ clocks/bit}$):

```bash
chmod +x ./script_2020_fix/run_sp2020.sh
./script_2020_fix/run_sp2020.sh
```

---

### Option 3: Spike RISC-V ISA Simulator
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
go to a new terminal after launch with current workspace path as shown before $sign and run the vvp file. 
'''
.../shakti-riscv-codespace/sp2020/e32-a35/sim_baud_fix (master) $ ./shakti_soc.vvp 
'''
you will see boot logo in next 3-4 minutes.
Thanks for using the codespace.
## Acknowledge
1. Prof. Kamakoti sir. Rise labs TEAM IITM
2. Mr. Kunal Gosh and Vsd team
3. CSIR CEERI LAB.
4. Bala and lakshaya (ps students)

