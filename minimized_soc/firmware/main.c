SHAKTI PROCESSORS\r\n\r\n"
    "Booting... vspil.0\r\n\r\n"
    "Booting on Pinaka! hart 0\r\n"
    "Pinaka is a SoC build on top of Artix7 35T.\r\n"
    "The core belongs to Shakti E class, 32 bit.\r\n\r\n"
    "Supported ISA: RV32IMACNU.\r\n"
    "Processor Arch ID: 0.\r\n"
    "Shakti booted\r\n";
}

static inline int uart_rx_avail(void) {
    return (UART_ST_REG & UART_RX_AVAIL);
}

static inline void uart_putc(char c) {
    while (uart_tx_busy());
    UART_TX_REG = (uint32_t)(unsigned char)c;
}

static inline char uart_getc(void) {
    while (!uart_rx_avail());
    return (char)(UART_RX_REG & 0xFF);
}

static inline void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

static void delay_ms(volatile unsigned int ms) {
    while (ms--) {
        volatile unsigned int count = 1200; // ~1 ms at 12 MHz
        while (count--) {
            __asm__ volatile ("nop");
        }
    }
}

#define TICKS_1S    2000000UL
#define TICKS_100MS  200000UL

/* High-speed cycle-accurate timeout polling (zero byte drops at 115200 baud) */
static inline int uart_getc_timeout(uint32_t ticks) {
    while (ticks--) {
        if (UART_ST_REG & UART_RX_AVAIL) {
            return (int)(UART_RX_REG & 0xFF);
        }
    }
    return -1;
}

static void print_dec(int val) {
    char buf[12];
    int idx = 0;
    if (val == 0) {
        uart_putc('0');
        return;
    }
    if (val < 0) {
        uart_putc('-');
        val = -val;
    }
    while (val > 0) {
        int rem = val;
        int q = 0;
        while (rem >= 10) {
            rem -= 10;
            q++;
        }
        buf[idx++] = (char)('0' + rem);
        val = q;
    }
    while (idx > 0) {
        uart_putc(buf[--idx]);
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

    /* Print Official Shakti Flame Logo */
    uart_puts(shakti_logo);

    while (1) {
        __asm__ volatile ("nop");
    }

    return 0;
}