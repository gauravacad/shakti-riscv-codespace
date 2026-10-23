/* =============================================================================
   link.ld — Linker Script for Shakti E-Class Boot ROM (4 KB EBR BRAM)
   Memory Region: 0x00000000 - 0x00000FFF (4096 bytes)
============================================================================= */

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    BRAM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        *(.text.start)
        *(.text*)
        *(.rodata*)
        *(.srodata*)
        . = ALIGN(4);
        _etext = .;
    } > BRAM

    .data : {
        . = ALIGN(4);
        _sdata = .;
        *(.data*)
        *(.sdata*)
        . = ALIGN(4);
        _edata = .;
    } > BRAM

    .bss : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > BRAM

    _end = .;
}
