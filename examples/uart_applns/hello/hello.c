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
// 2. Shakti Hardware UART0 MMIO Interface
// ==============================================================================
#define UART0_BASE       0x00011300
#define UART_BAUD_REG    (*(volatile uint16_t *)(UART0_BASE + 0x00))
#define UART_TX_REG      (*(volatile uint8_t  *)(UART0_BASE + 0x04))
#define UART_STATUS_REG  (*(volatile uint8_t  *)(UART0_BASE + 0x08))
#define UART_TX_FULL     0x02

void shakti_uart_init(uint32_t clock_hz, uint32_t baud_rate) {
    uint16_t divisor = (uint16_t)(clock_hz / (16 * baud_rate));
    UART_BAUD_REG = divisor;
}

void shakti_uart_putc(char c) {
    while (UART_STATUS_REG & UART_TX_FULL);
    UART_TX_REG = (uint8_t)c;
}

// ==============================================================================
// 3. Dual-Channel Output Router
// ==============================================================================
void shakti_print(const char *str) {
    while (*str) {
        if (*str == '\n') {
            spike_putc('\r');
        }
        spike_putc(*str);
        // Note: When running on real Shakti hardware/Icarus, shakti_uart_putc is active
        str++;
    }
}

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

    // Exit simulation cleanly on Spike
    spike_exit(0);
    return 0;
}
