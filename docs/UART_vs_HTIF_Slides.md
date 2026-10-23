# Physical UART vs. HTIF (`tohost`) Architecture

---

## Slide 1: Physical UART — Communicating with the Real World & User

> **Core Concept:** Physical UART is how the chip drives physical voltage levels over copper pins to talk to **human users** through terminal screens.

```
+-----------------------------------------------------------------------------------------+
| PHYSICAL SoC / FPGA (e.g. Pinaka / Shakti E-Class)                                      |
|                                                                                         |
|  [RISC-V Core]                                                                          |
|       |                                                                                 |
|       | sw a0, 0(UART)                                                                  |
|       v                                                                                 |
|  [AXI-Lite Bus (0x02000000)]                                                            |
|       |                                                                                 |
|       v                                                                                 |
|  [UART Peripheral (mkuart.v)]                                                           |
|       |                                                                                 |
|       v                                                                                 |
|  [TX Buffer & Shift Register] ===> [Physical FPGA Pin (TX)]                             |
+---------------------------------------------------|-------------------------------------+
                                                    | (Serial Voltages: 19,200 Baud)
                                                    v
                                  +-------------------------------------+
                                  | USB-to-UART Bridge (FT2232 / CP2102)|
                                  +-----------------|-------------------+
                                                    | Physical USB Cable
                                                    v
                                  +-------------------------------------+
                                  | Host PC: /dev/ttyUSB1               |
                                  | [User Terminal: miniterm / picocom] |
                                  +-------------------------------------+
```

### Key Characteristics:
* **Target Audience:** Humans sitting in front of a serial monitor (`miniterm`, `picocom`, PuTTY).
* **Hardware Dependencies:** Needs physical silicon/FPGA, a clock generator, shift registers, and a USB-UART converter chip.
* **Timing:** Governed by physical Baud rates (e.g., 19,200 Baud = 2,608 cycles/bit).
* **Real-World Role:** Bootloader prompts, interactive shells, runtime logging on physical boards.

---

## Slide 2: HTIF (`tohost`) — Communicating with Simulators & Verification

> **Core Concept:** HTIF (Host-Target Interface) is a zero-hardware **software mailbox in RAM** used by verification testbenches, automated CI/CD runners, and simulators.

```
+-----------------------------------------------------------------------------------------+
| SPIKE SIMULATOR / VERILATOR C++ ENGINE                                                  |
|                                                                                         |
|  [Simulated RISC-V Target Memory Space]                [Host C++ Simulator Engine]      |
|                                                                                         |
|   +----------------------------------+                   +--------------------------+   |
|   | RISC-V Core (Running C / Asm)    |                   | HTIF Watcher (sim.cc)    |   |
|   +----------------|-----------------+                   +------------|-------------+   |
|                    | (1-cycle write)                                  |                 |
|                    v                                                  v                 |
|   +----------------------------------+   Memory Hook     +--------------------------+   |
|   | RAM: .tohost (0x80001000)        | =================>| Intercepts putchar()     |   |
|   | Mailbox Register                 |                   | & Exit Code: (code<<1)|1 |   |
|   +----------------------------------+                   +------------|-------------+   |
+-----------------------------------------------------------------------|-----------------+
                                                                        |
                                         +------------------------------+--------------------+
                                         |                                                   |
                                         v                                                   v
                       +-----------------------------------+               +-----------------------------------+
                       | Cloud CI/CD (GitHub Actions)      |               | Official RISC-V Compliance Suite  |
                       | Automated Pass/Fail (Code 0)      |               | riscv-arch-test (gp=1: PASS)      |
                       +-----------------------------------+               +-----------------------------------+
```

### Key Characteristics:
* **Target Audience:** Automated testbenches, cloud regression servers (GitHub Actions), and compiler verification suites.
* **Hardware Dependencies:** **Zero physical wires, zero UART chips.** Runs entirely in memory before chips are fabricated.
* **Timing:** **Instantaneous (1 clock cycle).** No waiting for serial shift registers or baud delays.
* **Real-World Role:** 
  - The universal standard for the **Official RISC-V Architectural Compliance Test Suite**.
  - Automated pass/fail grading (`gp = 1` for pass, `gp > 1` for fail).
  - Pre-silicon CPU pipeline verification.

---

## Summary Comparison Table

| Attribute | Physical UART (`boot.c` / `main.c`) | HTIF (`tohost` in `shakti_boot_logo.c`) |
| :--- | :--- | :--- |
| **Who is on the other side?** | **A human user** reading a terminal | **An automated test harness** / simulator |
| **Medium** | Physical copper pins, RX/TX lines, USB bridge | A 64-bit RAM mailbox inspected by C++ simulator |
| **Baud Rate & Delay** | Strict physical baud (takes 26,080 cycles/char) | **0 cycles delay** (instant 1-cycle memory write) |
| **Primary Industry Purpose** | Product firmware, embedded shells, board bring-up | Pre-silicon chip verification, RISC-V compliance |
| **How it Exits** | Never exits (infinite `while(1)` embedded loop) | `tohost = (exit_code << 1) \| 1;` signals simulator to stop |
