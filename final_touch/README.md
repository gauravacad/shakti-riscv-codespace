# Final Touch: Shakti E-Class Complete Bundle

This all-in-one folder contains the essential scripts, Verilog models, testbenches, documentation, and presentation slide decks developed for the **Shakti E-Class (E32-A35 / SP2020) and Spike Simulation**.

---

## 📂 Contents Overview

### 1. Documentation & Visual Presentations
* **`SP2020_STEPS_1_TO_8_SIMPLE_DOC.md`**: Clean, direct step-by-step document (Steps 1 to 8) with copy-paste commands.
* **`Shakti_SP2020_White_Theme_Slides.html`**: Interactive, colourful, white-background presentation slide deck (Steps 1 to 8).
* **`UART_vs_HTIF_Slides.md`**: Comprehensive 2-slide architectural comparison of Physical UART vs. HTIF (`tohost`).

### 2. Fast-Baud SP2020 Simulation (81.5x Accelerated)
* **`run_baud_fix.sh`**: Master simulation script using the 32-clock simulation baud trick (streams output in 3–5 seconds).
* **`tb_soc_baud_fix.v`**: Top-level testbench calibrated for 32 clocks/bit.
* **`uart_rx_monitor.v`**: Serial UART receiver monitor supporting runtime baud adjustment.
* **`multiplier.v`**: Behavioral 4-stage pipelined multiplier resolving `mkmuldiv.v` elaboration.

### 3. Pure SP2020 Real-Time Simulation (Physical 19,200 Baud)
* **`run_sp2020.sh`**: Master simulation script for authentic physical 19,200 Baud ($2,608\text{ clocks/bit}$).
* **`tb_soc_sp2020.v`**: Top-level testbench for pure SP2020 timing.

### 4. Spike Baremetal HTIF Simulation (Zero PK Required)
* **`shakti_boot_logo.c`**: Baremetal HTIF code printing the Flame Logo directly via `.tohost`.
* **`spike.ld`**: Baremetal linker script mapping code to `0x80000000` with `.tohost`.
* **`run_spike_logo.sh`**: Script to compile and run directly on Spike in 0.05 seconds.
