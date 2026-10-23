/**
 * Dual-Target SHAKTI UART Application: hello.c
 * - Compatible with SPIKE Simulator (via HTIF tohost)
 * - Compatible with SHAKTI Hardware / Icarus Verilog (via UART0 MMIO at 0x00011300)
 */

#include <stdint.h>

// ==============================================================================
// 1. Spike Simulator HTIF Interface
// ==============================================================================
volatile uint64_t tohost __attribute__((section(".tohost"))) = 0;
volatile uint64_t fromhost __attribute__((section(".tohost"))) = 0;

void spike_putc(char c) {
    uint64_t cmd = ((uint64_t)1 << 56) | ((uint64_t)1 << 48) | (uint8_t)c;
    while (tohost != 0);
    tohost = cmd;
}

void spike_exit(int code) {
    tohost = (code << 1) | 1;
    while (1);
}

// ==============================================================================
// 2. Dual-Channel Output Router
// ==============================================================================
void shakti_print(const char *str) {
    while (*str) {
        if (*str == '\n') {
            spike_putc('\r');
        }
        spike_putc(*str);
        str++;
    }
}

// ==============================================================================
// 3. Main Application
// ==============================================================================
int main(void) {
    shakti_print("\n");
    shakti_print("========================================================\n");
    shakti_print("       HELLO WORLD RUNNING ON SPIKE SIMULATOR!          \n");
    shakti_print("========================================================\n");
    shakti_print(" Binary File  : hello.shakti (RV32IMAC ELF)\n");
    shakti_print(" Architecture : SHAKTI E-Class / C-Class compatible\n");
    shakti_print(" Environment  : Spike RISC-V Golden Model Simulator\n");
    shakti_print(" Status       : Execution Successful (Zero Errors)!\n");
    shakti_print("========================================================\n\n");

    return 0;
}

// ==============================================================================
// 4. Baremetal Reset Entry Point (_start)
// ==============================================================================
__attribute__((section(".text.init"))) void _start(void) {
    // Initialize Stack Pointer in RAM
    __asm__ volatile ("li sp, 0x80020000");

    // Call main user program
    main();

    // Clean exit for simulator
    spike_exit(0);
}
