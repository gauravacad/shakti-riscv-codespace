#ifndef _UART_H_
#define _UART_H_

#include <stdint.h>
#include <stdarg.h>

// 1. Spike Simulator HTIF Interface (Zero impact on VVP)
volatile uint64_t tohost __attribute__((section(".tohost"))) = 0;
volatile uint64_t fromhost __attribute__((section(".tohost"))) = 0;

// 2. Shakti Physical UART0 MMIO Registers (Active on VVP & FPGA)
#define UART0_BASE       0x00011300
#define UART_BAUD_REG    (*(volatile uint16_t *)(UART0_BASE + 0x00))
#define UART_TX_REG      (*(volatile uint8_t  *)(UART0_BASE + 0x04))
#define UART_STATUS_REG  (*(volatile uint8_t  *)(UART0_BASE + 0x08))
#define UART_TX_FULL     0x02

static inline void write_uart_character(char c) {
    // (A) Send to Spike HTIF:
    tohost = ((uint64_t)1 << 56) | ((uint64_t)1 << 48) | (uint8_t)c;

    // (B) Send to Shakti Hardware UART (VVP & FPGA):
    while (UART_STATUS_REG & UART_TX_FULL);
    UART_TX_REG = (uint8_t)c;
}

static inline void write_uart_string(const char *s) {
    while (*s) {
        if (*s == '\n') {
            write_uart_character('\r');
        }
        write_uart_character(*s++);
    }
}

static inline int printf(const char *format, ...) {
    write_uart_string(format);
    return 0;
}

// Baremetal reset entry point
__attribute__((section(".text.init"))) void _start(void) {
    __asm__ volatile ("li sp, 0x80020000");
    extern void main(void);
    main();
    tohost = 1; // Exit simulator cleanly
    while (1);
}

#endif // _UART_H_
