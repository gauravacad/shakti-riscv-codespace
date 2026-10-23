# Complete Guide: Building & Accelerating Shakti E-Class (E32-A35 / SP2020) in Icarus Verilog

This guide explains the end-to-end methodology to clone, patch, build from Bluespec BSV, accelerate with the 32-clock baud trick, and simulate the pure **IIT Madras Shakti E-Class Pinaka SoC (`e32-a35`)** using Icarus Verilog (`iverilog` + `vvp`).

---

## 1. Download & Directory Navigation

Clone the authentic SP2020 Swadeshi Microprocessor Challenge repository and enter the Pinaka SoC directory:

```bash
git clone https://gitlab.com/shaktiproject/sp2020.git
cd sp2020/e32-a35
```

---

## 2. Essential Compatibility Patches

Open-source environments require 3 minor compatibility adjustments:

### A. Fix GHC Heap Overflow in BSC (`Makefile`)
The default `-K40000M` exceeds 32-bit integer limits in Haskell GHC runtimes, causing compiler crashes. Also remove the obsolete proprietary filter `basicinout`:
```bash
sed -i 's/-K40000M/-K4000M/g' Makefile
sed -i 's|-verilog-filter [^ ]*||g' Makefile
```

### B. Fix GCC ABI in Boot Code (`boot-code/Makefile`)
Remove `--specs=picolibc.specs` and add `-mabi=ilp32` for modern multilib RISC-V GCC compatibility:
```bash
sed -i 's/--specs=picolibc.specs//g' boot-code/Makefile
sed -i 's/-march=rv$(XLEN)imac/-march=rv$(XLEN)imac -mabi=ilp32/g' boot-code/Makefile
```

### C. Provide the Multiplier BVI Model
Bluespec outputs `mkmuldiv.v` referencing an unelaborated primitive `multiplier`. Create `common_verilog/multiplier.v`:
```verilog
`timescale 1ns/1ps
module multiplier #(parameter WIDTH = 32, parameter STAGES = 4)(
    input  wire                 CLK,
    input  wire [WIDTH-1:0]     A,
    input  wire [WIDTH-1:0]     B,
    output wire [(2*WIDTH)-1:0] P
);
    reg [(2*WIDTH)-1:0] pipe [0:STAGES-1];
    integer i;
    always @(posedge CLK) begin
        pipe[0] <= A * B;
        for (i = 1; i < STAGES; i = i + 1) pipe[i] <= pipe[i-1];
    end
    assign P = pipe[STAGES-1];
endmodule
```

---

## 3. Generate Verilog from Bluespec BSV

Compile the Bluespec high-level hardware description into cycle-accurate Verilog modules (`mkSoc.v`, `mkeclass.v`, etc.):

```bash
make generate_verilog CONFIG=core_config.inc
```

---

## 4. The 81.5x Acceleration Trick (32-Clock Baud System)

### The Problem:
At physical 19,200 Baud on a 50 MHz clock, each bit requires **2,608 clock cycles** (26,080 cycles/character). Simulating this in `vvp` takes ~15 seconds per character.

### The Solution:
Reduce the baud clock divider in software to `2` ($16 \times 2 = \mathbf{32\text{ clock cycles/bit}}$). This accelerates transmission by **81.5x** without modifying any processor RTL!

```bash
# 1. Update boot-code baud divisor to 2
for bfile in boot-code/*.c boot-code/*.h; do
    sed -i 's/\b163\b/2/g' "$bfile" || true
    sed -i 's/\*uart0_baud *= *[0-9]*;/\*uart0_baud = 2;/g' "$bfile" || true
done

# 2. Compile the Boot ROM code into boot.mem
make generate_boot_files CONFIG=core_config.inc
```

---

## 5. Prepare Simulation Directory & Preload Files

```bash
mkdir -p sim_baud_fix
cp boot-code/outputs/boot.mem sim_baud_fix/boot.mem
touch sim_baud_fix/code.mem sim_baud_fix/code1.mem
```

---

## 6. Compile the Complete SoC with Icarus Verilog (`iverilog`)

Run `iverilog` to elaborate all Verilog modules and build the executable simulation model `shakti_soc.vvp`:

```bash
BSV_VDIR="/usr/local/lib/Verilog"
[ ! -d "$BSV_VDIR" ] && BSV_VDIR="/usr/local/lib/Libraries/Verilog"

iverilog -g2012 \
    -o sim_baud_fix/shakti_soc.vvp \
    -I ${BSV_VDIR} -y ${BSV_VDIR} \
    -I verilog -y verilog \
    -I common_verilog -y common_verilog \
    -I devices -y devices \
    -I fabrics -y fabrics \
    /workspaces/shakti-riscv-codespace/baud_fix/multiplier.v \
    /workspaces/shakti-riscv-codespace/baud_fix/uart_rx_monitor.v \
    /workspaces/shakti-riscv-codespace/baud_fix/tb_soc_baud_fix.v \
    verilog/*.v
```

---

## 7. Run Cycle-Accurate Simulation with `vvp`

Run the simulation model. Because it is matched to 32 clocks/bit, the Flame Logo and Pinaka boot lines stream to your console in **3 to 5 seconds**:

```bash
cd sim_baud_fix
vvp shakti_soc.vvp
```

*(You can also explicitly pass the rate: `vvp shakti_soc.vvp +CLKS_PER_BIT=32`).*

---

## 8. Expected Console Output

```text
[TB] System reset released. Starting Fast-Baud Shakti SP2020 simulation...

                        ./((*
                     ,(((((,
                   *((((((,
               ./(((((((,
             ./((((((((* 
          *(((((((((/*
       .(((((((((((,
    ,((((((((((((/
  ((((((((((((((/
 .((((((((((((((/
    *(((((((((((.
        /(((((((.
         ..   *(((
             *((,   ,/
               ((((((/.
               ((((((((((/
                ((((((((((((/
                ((((((((((((((.
               ((((((((((((/
             *((((((((((* 
             ((((((((((.
          /((((((((* 
       *(((((((,
     *((((((.
  .(((((
./(((*
.

SHAKTI PROCESSORS

Booting... vspil.0

Booting on Pinaka! hart 0
Pinaka is a SoC build on top of Artix7 35T.
The core belongs to Shakti E class, 32 bit.

Supported ISA: RV32IMACNU.
Processor Arch ID: 0.
Shakti booted

   6733200 SPI : Transmit state is in idle
 id ffff 
No content to boot
```

---

## 9. 1-Command Automated Shortcut

All the steps above are fully automated in your workspace. You can run the entire flow at any time with:

```bash
./baud_fix/run_baud_fix.sh
```
