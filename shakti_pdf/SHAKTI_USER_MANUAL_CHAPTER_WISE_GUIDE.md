# SHAKTI User Manual (v1.3.1) — Chapter-Wise Technical Guide

> **Official Reference Walkthrough**  
> **Source:** `SHAKTI USER MANUAL V1.3.1.pdf`  
> **Origin:** Reconfigurable Intelligent Systems Engineering (RISE) Lab, IIT Madras  
> **Initiative:** Swadeshi Microprocessor Challenge, Ministry of Electronics & IT (MeitY), Government of India  

---

## 📑 Table of Contents

1. [Chapter 1: Introduction to SHAKTI & Processor Families](#chapter-1-introduction-to-shakti--processor-families)
   - [1.1 E-Class Microarchitecture (RV32)](#11-e-class-microarchitecture-rv32)
   - [1.2 C-Class Microarchitecture (RV64)](#12-c-class-microarchitecture-rv64)
   - [1.3 E-Class vs. C-Class Architectural Comparison](#13-e-class-vs-c-class-architectural-comparison)
2. [Chapter 2: Development Boards & Reference SoCs](#chapter-2-development-boards--reference-socs)
   - [2.1 Supported FPGA Platforms (Arty A7-35T & A7-100T)](#21-supported-fpga-platforms-arty-a7-35t--a7-100t)
   - [2.2 Reference SoC Flavors: PINAKA, PARASHU, VAJRA](#22-reference-soc-flavors-pinaka-parashu-vajra)
3. [Chapter 3: Hardware Board Setup & FPGA Programming](#chapter-3-hardware-board-setup--fpga-programming)
   - [3.1 Single-Cable Dual-Channel FTDI Architecture](#31-single-cable-dual-channel-ftdi-architecture)
   - [3.2 Hardware Connection Checklist](#32-hardware-connection-checklist)
   - [3.3 Flashing Persistent `.mcs` Configuration to SPI Flash](#33-flashing-persistent-mcs-configuration-to-spi-flash)
4. [Chapter 4: SoC Memory Map & Peripheral Addressing](#chapter-4-soc-memory-map--peripheral-addressing)
   - [4.1 Unified MMIO Architecture](#41-unified-mmio-architecture)
   - [4.2 Comprehensive Peripheral Address Map](#42-comprehensive-peripheral-address-map)
5. [Chapter 5: Software Development Flow (SHAKTI-SDK)](#chapter-5-software-development-flow-shakti-sdk)
   - [5.1 Layered Architecture (BSP, Drivers, OS)](#51-layered-architecture-bsp-drivers-os)
   - [5.2 Host System Setup & Toolchain Installation](#52-host-system-setup--toolchain-installation)
   - [5.3 Application Lifecycle: Adding & Compiling Code](#53-application-lifecycle-adding--compiling-code)
   - [5.4 Interactive Debugging Mode (3-Terminal GDB Workflow)](#54-interactive-debugging-mode-3-terminal-gdb-workflow)
   - [5.5 Standalone Flash Execution Mode (Autonomous Power-On Boot)](#55-standalone-flash-execution-mode-autonomous-power-on-boot)
6. [Appendices: Pin Mapping & Dynamic PinMux Design](#appendices-pin-mapping--dynamic-pinmux-design)
   - [Appendix A: Arduino Uno R3 Header & PMOD Mapping](#appendix-a-arduino-uno-r3-header--pmod-mapping)
   - [Appendix B: Dynamic 2-Bit PinMux Register Programming](#appendix-b-dynamic-2-bit-pinmux-register-programming)

---

## Chapter 1: Introduction to SHAKTI & Processor Families

SHAKTI is an open-source microprocessor development initiative led by the **RISE Lab at IIT Madras**. Built on the open **RISC-V Instruction Set Architecture (ISA)**, SHAKTI delivers production-grade silicon IP designed in **Bluespec SystemVerilog (BSV)** for formal verification and high reliability.

The project encompasses a family of 6 distinct processor classes:
* **E-Class:** 32-bit embedded microcontroller (smart cards, automotive, IoT).
* **C-Class:** 64-bit industrial controller (Linux, networking, storage).
* **I-Class:** 64-bit out-of-order superscalar processor (enterprise compute).
* **M-Class:** Multi-core processors for mobile and general-purpose workloads.
* **S-Class:** Secure server processor with hardware enclaves.
* **H-Class:** High-Performance Computing (HPC) & vector processing cores.

---

### 1.1 E-Class Microarchitecture (RV32)
* **Word Size:** 32-bit (`XLEN=32`).
* **Pipeline:** In-Order **3-stage pipeline**:
  1. **Instruction Fetch (IF):** PC generation, I-Cache lookup / BRAM access, 16-bit compressed instruction decompressor.
  2. **Decode & Execute (ID / EX):** Instruction decode, register file read, 32-bit integer ALU, branch evaluation, multi-stage pipelined multiplier/divider.
  3. **Memory & Writeback (MEM / WB):** D-Cache / MMIO access, register writeback commit, CSR updates.
* **Clock Frequency:** Operational up to **200 MHz** on ASIC silicon; 50 MHz on Artix-7 FPGA.
* **ISA Extensions:** `RV32IMAC` (Base Integer, M-Extension Multiply/Divide, A-Extension Atomics, C-Extension 16-bit Compressed instructions).
* **Privilege:** Machine (M) mode with optional User (U) mode; Physical Memory Protection (PMP).
* **Positioning:** Direct competitor to ARM's **Cortex-M0+ / Cortex-M3 / Cortex-M4**.

---

### 1.2 C-Class Microarchitecture (RV64)
* **Word Size:** 64-bit (`XLEN=64`).
* **Pipeline:** In-Order **5-stage pipeline** (Fetch $\to$ Decode $\to$ Execute $\to$ Memory $\to$ Writeback).
* **Clock Frequency:** Operational between **800 MHz and 1.0 GHz** on ASIC silicon.
* **Memory Management:** Full **Sv39 MMU** (Page-based virtual memory translation supporting Linux / FreeBSD).
* **ISA Extensions:** `RV64IMAC` with optional single- and double-precision IEEE-754 floating point units (`F` and `D`).
* **Positioning:** Direct competitor to ARM's **Cortex-A35 / Cortex-A55**.

---

### 1.3 E-Class vs. C-Class Architectural Comparison

| Parameter | SHAKTI E-Class | SHAKTI C-Class |
| :--- | :--- | :--- |
| **Data Width** | 32-bit (`RV32`) | 64-bit (`RV64`) |
| **Pipeline Depth** | 3-Stage In-Order | 5-Stage In-Order |
| **ASIC Clock Speed** | $< 200\text{ MHz}$ | $800\text{ MHz} - 1.0\text{ GHz}$ |
| **Virtual Memory** | Physical Memory Protection (PMP) | Sv39 Page-Based MMU |
| **Privilege Modes** | Machine (M) / User (U) | Machine (M), Supervisor (S), User (U) |
| **Target OS** | Baremetal, FreeRTOS, Zephyr | Full Linux, FreeBSD, RTEMS |
| **ARM Benchmark** | Cortex-M0+ / M4 | Cortex-A35 / A55 |

---

## Chapter 2: Development Boards & Reference SoCs

Under the **Swadeshi Microprocessor Challenge (MeitY)**, hardware support was implemented on Digilent's Xilinx Artix-7 FPGA development platforms.

### 2.1 Supported FPGA Platforms
1. **Arty A7-35T (`xc7a35ticsg324-1L`):** 33,280 logic cells, 90 DSP slices, 1,800 Kbits BRAM.
2. **Arty A7-100T (`xc7a100tcsg324-1`):** 101,440 logic cells, 240 DSP slices, 4,860 Kbits BRAM, 256MB DDR3L memory.

---

### 2.2 Reference SoC Flavors: PINAKA, PARASHU, VAJRA

| Feature | PINAKA (`e32-a35`) | PARASHU (`e32-a100`) | VAJRA (`c64-a100`) |
| :--- | :--- | :--- | :--- |
| **Core Architecture** | E-Class 32-bit (`RV32IMAC`) | E-Class 32-bit (`RV32IMAC`) | C-Class 64-bit (`RV64IMAC`) |
| **Target FPGA** | Arty A7-35T | Arty A7-100T | Arty A7-100T |
| **System RAM** | 128KB On-Chip BRAM | **256MB DDR3** RAM | **128MB DDR3** RAM |
| **Ethernet Lite** | None | 10/100 AXI Ethernet | 10/100 AXI Ethernet |
| **UART Channels** | 3 Channels (UART0, 1, 2) | 3 Channels (UART0, 1, 2) | 3 Channels (UART0, 1, 2) |
| **SPI Interfaces** | 2 Controllers (SPI0, SPI1) | 2 Controllers (SPI0, SPI1) | 2 Controllers (SPI0, SPI1) |
| **PWM Generators** | 6 Channels (PWM0 to PWM5) | 6 Channels (PWM0 to PWM5) | 6 Channels (PWM0 to PWM5) |
| **I2C Controllers** | 2 Controllers (I2C0, I2C1) | 2 Controllers (I2C0, I2C1) | 2 Controllers (I2C0, I2C1) |
| **Analog ADC** | Xilinx XADC Header | Xilinx XADC Header | Xilinx XADC Header |
| **Primary Workload** | Low-cost sensors & motor drives | Networked IoT & large buffers | Full Linux distribution boot |

---

## Chapter 3: Hardware Board Setup & FPGA Programming

### 3.1 Single-Cable Dual-Channel FTDI Architecture
The Arty-7 board incorporates an onboard **FTDI FT2232H** USB controller connected to **Micro-USB port J10**:
* **Channel A (MPSSE Engine):** Dedicated to **JTAG Hardware Debugging** (TCK, TMS, TDI, TDO). OpenOCD communicates directly over this port to access the RISC-V Debug Module.
* **Channel B (Virtual COM Port):** Dedicated to the **SoC UART0 Console** at 19,200 baud (8N1). Connects terminal emulators (`miniterm`, `picocom`, PuTTY) to the processor console.

> [!NOTE]
> No external JTAG emulator pod (such as Olimex ARM-USB-TINY-H or Segger J-Link) is required for standard debugging!

---

### 3.2 Hardware Connection Checklist
1. Connect the Micro-USB cable between **connector J10** on the Arty board and your PC.
2. Confirm that the green power indicator LED (**LD11**) illuminates.
3. On Linux host systems, verify device enumeration:
   ```bash
   ls -l /dev/ttyUSB*
   # /dev/ttyUSB0 -> UART0 serial console
   # /dev/ttyUSB1 -> FTDI JTAG channel
   ```
4. Grant serial permissions:
   ```bash
   sudo usermod -a -G dialout $USER
   sudo chmod 666 /dev/ttyUSB*
   ```

---

### 3.3 Flashing Persistent `.mcs` Configuration to SPI Flash

By default, loading a `.bit` file over JTAG is volatile (lost on power loss). To achieve **persistent autonomous boot**, flash the `.mcs` bitstream into the onboard Quad-SPI Flash memory (Spansion `s25fl128s` or Micron `n25q128`).

#### Vivado GUI Flow:
1. Open **Vivado** $\to$ **Hardware Manager** $\to$ **Open Target** $\to$ **Auto Connect**.
2. Right-click the FPGA part (`xc7a35t` or `xc7a100t`) $\to$ **Add Configuration Memory Device**.
3. Select configuration memory parameters:
   - Manufacturer: **Spansion** or **Micron**
   - Density: **128**
   - Type: **spi**
   - Width: **x1_x2_x4**
4. Choose the downloaded `pinaka.mcs` (or `parashu.mcs` / `vajra.mcs`).
5. Click **OK** to program flash memory.
6. Press the board's **PROG** button to immediately boot SHAKTI from Flash!

#### Automated Command-Line Flow:
```bash
git clone --recursive https://gitlab.com/shaktiproject/sp2020.git
cd sp2020/e32-a35/
make generate_verilog generate_boot_files ip_build arty_build generate_mcs program_mcs JOBS=4
```

---

## Chapter 4: SoC Memory Map & Peripheral Addressing

### 4.1 Unified MMIO Architecture
SHAKTI processors implement standard **Memory-Mapped I/O (MMIO)**. Peripherals reside in the physical address space and are manipulated via standard RISC-V load and store instructions (`lw`, `sw`).

### 4.2 Comprehensive Peripheral Address Map

| Peripheral Name | Physical Base Start | Physical Base End | Function / Notes |
| :--- | :--- | :--- | :--- |
| **Debug Module** | `0x0000_0010` | `0x0000_001F` | RISC-V Debugger interface (DMI registers) |
| **Boot ROM** | `0x0000_1000` | `0x0001_0FFF` | First-stage bootloader & ASCII boot banner |
| **UART 0** | `0x0001_1300` | `0x0001_1340` | Primary console over FTDI USB (19,200 baud) |
| **UART 1** | `0x0001_1400` | `0x0001_1440` | Auxiliary serial channel (Arduino IO0/IO1) |
| **UART 2** | `0x0001_1500` | `0x0001_1540` | Auxiliary serial channel (Arduino IO2/IO3) |
| **SPI 0** | `0x0002_0000` | `0x0002_00FF` | Primary SPI controller for onboard Flash |
| **SPI 1** | `0x0002_0100` | `0x0002_01FF` | External SPI bus (Arduino IO10-IO13) |
| **PWM 0 to 5** | `0x0003_0000` | `0x0003_05FF` | 6 independent PWM channels |
| **I2C 0** | `0x0004_0000` | `0x0004_00FF` | Primary I2C bus (PMOD JB) |
| **GPIO** | `0x0004_0100` | `0x0004_01FF` | 32-bit GPIO direction and data registers |
| **XADC** | `0x0004_1000` | `0x0004_13FF` | Xilinx analog-to-digital converter interface |
| **I2C 1** | `0x0004_1400` | `0x0004_14FF` | Secondary I2C bus (Arduino SDA/SCL) |
| **PinMux** | `0x0004_1500` | `0x0004_15FF` | Dynamic pin multiplexing control register |
| **Ethernet Lite**| `0x0004_4000` | `0x0004_7FFF` | 10/100 AXI Ethernet MAC (Parashu & Vajra) |
| **CLINT** | `0x0200_0000` | `0x020B_FFFF` | Core Local Interruptor (`mtime`, `mtimecmp`, IPI) |
| **PLIC** | `0x0C00_0000` | `0x0C01_001F` | Platform-Level Interrupt Controller |
| **Main RAM** | `0x8000_0000` | `0x8FFF_FFFF` | Pinaka: 128KB BRAM \| Parashu/Vajra: DDR3 |

---

## Chapter 5: Software Development Flow (SHAKTI-SDK)

### 5.1 Layered Architecture (BSP, Drivers, OS)
The SHAKTI-SDK separates platform specifics from user logic through four clean layers:
1. **Application Layer:** User code and demo sensor routines (`software/examples/`).
2. **OS Layer:** Real-Time Operating Systems (FreeRTOS, Zephyr RTOS) and standard C runtime (`picolibc`).
3. **Board Support Package (BSP):** Peripheral drivers (`uart.c`, `i2c.c`, `spi.c`, `pwm.c`, `gpio.c`), linker scripts (`artix7_35t.ld`), and startup assembly (`crt0.s`).
4. **Hardware Fabric:** The synthesized RISC-V SoC executing on the FPGA.

---

### 5.2 Host System Setup & Toolchain Installation

```bash
# 1. Install prerequisites on Ubuntu:
sudo apt-get install autoconf automake autotools-dev curl \
     libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev bc \
     gawk build-essential bison flex texinfo gperf libtool \
     patchutils zlib1g-dev libftdi1 libftdi1-2 python3-serial

# 2. Clone SHAKTI-SDK & SHAKTI-TOOLS:
git clone https://gitlab.com/shaktiproject/software/shakti-sdk.git
git clone https://gitlab.com/shaktiproject/software/shakti-tools.git

# 3. Build toolchain & export PATH:
cd shakti-tools && ./setup.sh
export PATH=$PWD/bin:$PWD/openocd/bin:$PATH
```

---

### 5.3 Application Lifecycle: Adding & Compiling Code

1. **Locate Device Directory:** Under `software/examples/XYZ_applns` (e.g. `uart_applns/`).
2. **Create Application:** Create folder `my_app/` and author `my_app.c`:
   ```c
   #include "uart.h"
   int main(void) {
       uart_init(UART0, 19200);
       printf("Hello from SHAKTI Pinaka SoC!\n");
       while (1);
       return 0;
   }
   ```
3. **Register in Makefile:** Add `my_app` to the target list in `software/examples/Makefile`.
4. **Compile:**
   ```bash
   make software PROGRAM=my_app TARGET=pinaka
   ```
   *Generates `output/my_app.elf`, `output/my_app.dump`, and `output/my_app.hex`.*

---

### 5.4 Interactive Debugging Mode (3-Terminal GDB Workflow)

Debugging uses an in-circuit emulation flow across 3 synchronized terminal windows:

```
[ Terminal 1: Console ]        [ Terminal 2: OpenOCD ]        [ Terminal 3: GDB Client ]
$ miniterm.py /dev/ttyUSB0     $ sudo openocd -f ftdi.cfg     $ riscv32-unknown-elf-gdb
  19200 baud, 8N1                Listens on port :3333          target remote :3333
  Shows printf outputs           Hardware JTAG TAP connection   file my_app.elf
                                                                load && continue
```

#### Step-by-Step Execution:
1. **Terminal 1 (Console):**
   ```bash
   sudo miniterm.py /dev/ttyUSB0 19200
   ```
2. **Terminal 2 (OpenOCD JTAG Server):**
   ```bash
   cd ./bsp/third_party/artix7_35t
   sudo openocd -f ftdi.cfg
   ```
3. **Terminal 3 (RISC-V GDB Client):**
   ```bash
   riscv32-unknown-elf-gdb
   (gdb) target remote localhost:3333
   (gdb) file output/my_app.elf
   (gdb) load
   (gdb) b main
   (gdb) continue
   ```

---

### 5.5 Standalone Flash Execution Mode (Autonomous Power-On Boot)

Once firmware is verified in RAM, burn it to Flash memory for production deployment:
```bash
cd shakti-sdk
make upload PROGRAM=my_app TARGET=pinaka
```

#### Hardware Boot Sequence:
1. Power-on reset forces program counter to `0x0000_1000` (**BootROM**).
2. BootROM initializes memory controllers and checks SPI Flash.
3. The executable payload is copied from **SPI Flash** (`0x0002_0000`) into **RAM** (`0x8000_0000`).
4. Core jumps to `0x8000_0000` and executes user firmware autonomously!

---

## Appendices: Pin Mapping & Dynamic PinMux Design

### Appendix A: Arduino Uno R3 Header & PMOD Mapping

The Arty-7 development board connects SHAKTI SoC lines to standard Arduino headers:
* **`CK_IO[0]` / `CK_IO[1]`:** Arduino Pin 0 (RX) & Pin 1 (TX) $\to$ `UART1`
* **`CK_IO[2]` / `CK_IO[3]`:** Arduino Pin 2 & Pin 3 $\to$ `UART2` / `PWM0`
* **`CK_IO[10]` to `CK_IO[13]`:** Arduino SPI Pins (SS, MOSI, MISO, SCK) $\to$ `SPI1`
* **`CK_A0` to `CK_A5`:** Single-ended analog inputs $\to$ `XADC`
* **Upper 8 GPIOs (`GPIO[16]` to `GPIO[23]`):** Wired directly to onboard pushbuttons and LEDs!

---

### Appendix B: Dynamic 2-Bit PinMux Register Programming

The **PinMux register at `0x0004_1500`** allows software to dynamically repurpose physical pins during execution:

| 2-Bit Value | Configured Mode | Peripheral Routed |
| :---: | :--- | :--- |
| **`00`** | **GPIO Mode (Default)** | Standard General Purpose I/O pin |
| **`01`** | **Serial Peripheral** | `UART1` / `UART2` / `SPI1` bus lines |
| **`10`** | **PWM Generation** | `PWM0` to `PWM5` output channels |
| **`11`** | **Reserved** | Undefined hardware behavior |

#### C Programming Example:
```c
#include <stdint.h>

#define PINMUX_REG (*(volatile uint32_t *)0x00041500)

// Example: Configure Arduino Pin IO3 (CK_IO[3]), controlled by bits [7:6]:

void set_pin3_mode(void) {
    // 1. Enable PWM0 output on Pin IO3:
    PINMUX_REG &= ~(0b11 << 6);  // Clear bits 7:6
    PINMUX_REG |=  (0b10 << 6);  // Set bits 7:6 to 10 (PWM0)

    // 2. Switch Pin IO3 to UART2 TX dynamically:
    PINMUX_REG &= ~(0b11 << 6);
    PINMUX_REG |=  (0b01 << 6);  // Set bits 7:6 to 01 (UART2 TX)

    // 3. Revert back to standard GPIO:
    PINMUX_REG &= ~(0b11 << 6);  // Set bits 7:6 to 00 (GPIO)
}
```

---

## 🎯 Summary of Delivered Resources

1. **Interactive HTML Slide Deck:** [`shakti_pdf/SHAKTI_User_Manual_Slides.html`](file:///e:/making%20an%20codespace/shakti_pdf/SHAKTI_User_Manual_Slides.html)
2. **Microsoft PowerPoint (.pptx) Deck:** [`shakti_pdf/SHAKTI_User_Manual_Slides.pptx`](file:///e:/making%20an%20codespace/shakti_pdf/SHAKTI_User_Manual_Slides.pptx)
3. **Comprehensive Chapter Guide:** [`shakti_pdf/SHAKTI_USER_MANUAL_CHAPTER_WISE_GUIDE.md`](file:///e:/making%20an%20codespace/shakti_pdf/SHAKTI_USER_MANUAL_CHAPTER_WISE_GUIDE.md)
