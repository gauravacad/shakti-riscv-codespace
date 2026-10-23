/* =============================================================================
   start.S — Startup Assembly for Shakti E-Class RV32IAC SoC
   Initializes stack pointer in BRAM and jumps to C main()
============================================================================= */

.section .text.start
.global _start
.type _start, @function

_start:
    /* 1. Initialize Stack Pointer at top of 4KB BRAM (0x00000FF0) */
    li sp, 0x00000FF0

    /* 2. Zero-out BSS section */
    la a0, _bss_start
    la a1, _bss_end
    bgeu a0, a1, .bss_done

.bss_loop:
    sw zero, 0(a0)
    addi a0, a0, 4
    bltu a0, a1, .bss_loop

.bss_done:
    /* 3. Jump to C main function */
    jal main

.hang:
    /* Infinite loop if main ever returns */
    j .hang

.size _start, . - _start
