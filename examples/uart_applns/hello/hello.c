/**
 * Official SHAKTI-SDK UART Application Example: hello.c
 * Location in SDK: shakti-sdk/software/examples/uart_applns/hello/hello.c
 */

#include <stdint.h>

// Shakti UART0 MMIO Base Address (PINAKA / PARASHU / VAJRA)
#define UART0_BASE       0x00011300
#define UART_BAUD_REG    (*(volatile uint16_t *)(UART0_BASE + 0x00))
#define UART_TX_REG      (*(volatile uint8_t  *)(UART0_BASE + 0x04))
#define UART_STATUS_REG  (*(volatile uint8_t  *)(UART0_BASE + 0x08))

// Status register bit 1: TX FIFO Full (0 = ready to send, 1 = busy/full)
#define UART_TX_FULL     0x02

void shakti_uart_init(uint32_t clock_hz, uint32_t baud_rate) {
    // Divisor formula for Shakti 16x oversampling UART:
    // Baud_divisor = Clock / (16 * Baud_rate)
    uint16_t divisor = (uint16_t)(clock_hz / (16 * baud_rate));
    UART_BAUD_REG = divisor;
}

void shakti_uart_putc(char c) {
    // Wait until TX FIFO is not full
    while (UART_STATUS_REG & UART_TX_FULL);
    UART_TX_REG = (uint8_t)c;
}

void shakti_uart_puts(const char *str) {
    while (*str) {
        if (*str == '\n') {
            shakti_uart_putc('\r');
        }
        shakti_uart_putc(*str++);
    }
}

int main(void) {
    // Initialize UART0 at 19,200 baud for 50MHz Shakti Pinaka SoC
    shakti_uart_init(50000000, 19200);

    shakti_uart_puts("\n");
    shakti_uart_puts("====================================================\n");
    shakti_uart_puts("   SHAKTI-SDK: examples/uart_applns/hello           \n");
    shakti_uart_puts("   Hardware: Shakti Pinaka SoC (e32-a35)            \n");
    shakti_uart_puts("   Peripheral: UART0 (Base: 0x00011300 @ 19,200)    \n");
    shakti_uart_puts("====================================================\n");
    shakti_uart_puts(" Hello, World from Shakti UART Peripheral Driver!   \n");
    shakti_uart_puts(" Transmission successful over hardware MMIO registers.\n");
    shakti_uart_puts("====================================================\n\n");

    return 0;
}
