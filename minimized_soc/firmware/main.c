/* =============================================================================
   main.c — Bootloader with Authentic Shakti Flame Boot Logo & Pinaka Banner
   Target : Authentic IIT Madras Shakti E-Class (RV32IAC)
============================================================================= */

#include <stdint.h>

#define UART_BASE     0x02000000UL
#define UART_TX_REG   (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_ST_REG   (*(volatile uint32_t *)(UART_BASE + 0x04))

#define LED_REG       (*(volatile uint32_t *)0x03000000UL)

/* Status bits */
#define UART_TX_BUSY  (1u << 0)

#define LED_B (1u << 0)
#define LED_G (1u << 1)
#define LED_R (1u << 2)

static inline int uart_tx_busy(void) {
    return (UART_ST_REG & UART_TX_BUSY);
}

static inline void uart_putc(char c) {
    while (uart_tx_busy());
    UART_TX_REG = (uint32_t)(unsigned char)c;
}

static inline void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

static const char shakti_logo[] =
    "\r\n"
    "                        ./((*\r\n"
    "                     ,(((((,\r\n"
    "                   *((((((,\r\n"
    "               ./(((((((,\r\n"
    "             ./((((((((* \r\n"
    "          *(((((((((/\r\n"
    "       .(((((((((((,\r\n"
    "    ,((((((((((((/\r\n"
    "  ((((((((((((((/\r\n"
    " .((((((((((((((/\r\n"
    "    *(((((((((((.\r\n"
    "        /(((((((.\r\n"
    "         ..   *(((\r\n"
    "             *((,   ,/\r\n"
    "               ((((((/.\r\n"
    "               ((((((((((/\r\n"
    "                ((((((((((((/\r\n"
    "                ((((((((((((((.\r\n"
    "               ((((((((((((/\r\n"
    "             *((((((((((* \r\n"
    "             ((((((((((.\r\n"
    "          /((((((((* \r\n"
    "       *(((((((,\r\n"
    "     *((((((.\r\n"
    "  .(((((\r\n"
    "./(((*\r\n"
    ".\r\n"
    "\r\n"
    "SHAKTI PROCESSORS\r\n\r\n"
    "Booting... vspil.0\r\n\r\n"
    "Booting on Pinaka! hart 0\r\n"
    "Pinaka is a SoC build on top of Artix7 35T.\r\n"
    "The core belongs to Shakti E class, 32 bit.\r\n\r\n"
    "Supported ISA: RV32IMACNU.\r\n"
    "Processor Arch ID: 0.\r\n"
    "Shakti booted\r\n";

int main(void) {
    LED_REG = LED_B;

    /* Print Official Shakti Flame Logo & Pinaka Banner */
    uart_puts(shakti_logo);

    while (1) {
        __asm__ volatile ("nop");
    }

    return 0;
}
