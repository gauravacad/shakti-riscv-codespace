/* =============================================================================
   main.c — XMODEM Bootloader with Permanent Shakti Flame Boot Logo
   Target : Authentic IIT Madras Shakti E-Class (RV32IAC) on Lattice iCE40UP5K
   Baud   : 115,200 Baud 8N1 @ 12 MHz Hardware Clock

   Behavior:
   1. Prints official Shakti Flame ASCII Logo and system banner immediately.
   2. Listens for 5 seconds for XMODEM upload (Ctrl+A then Ctrl+S in picocom).
   3. On upload: writes binary into User SPRAM (0x00010000) and executes it!
   4. On timeout (no upload): loops cleanly and announces readiness again.
   5. Pure RV32IAC code: zero M-extension instructions (no MUL/DIV).
============================================================================= */

#include <stdint.h>

#define USER_RAM_ADDR 0x00010000UL

/* Register Addresses matching axi4lite_interconnect */
#define UART_BASE     0x02000000UL
#define UART_TX_REG   (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_ST_REG   (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_RX_REG   (*(volatile uint32_t *)(UART_BASE + 0x08))

#define LED_REG       (*(volatile uint32_t *)0x03000000UL)

/* Status bits */
#define UART_TX_BUSY  (1u << 0)
#define UART_RX_AVAIL (1u << 1)

/* LED bits */
#define LED_B (1u << 0)
#define LED_G (1u << 1)
#define LED_R (1u << 2)

/* XMODEM Control Characters */
#define SOH   0x01
#define EOT   0x04
#define ACK   0x06
#define NAK   0x15

static inline int uart_tx_busy(void) {
    return (UART_ST_REG & UART_TX_BUSY);
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
    "==================================================\r\n"
    "   SHAKTI PROCESSORS — IIT MADRAS E-CLASS CORE    \r\n"
    "   RV32IAC RISC-V SoC on VSD Squadron FM Board   \r\n"
    "   Clock: 12 MHz (Crystal) | UART: 115200 Baud 8N1\r\n"
    "   Boot ROM: 4KB EBR | User RAM: 128KB SPRAM     \r\n"
    "==================================================\r\n";

int main(void) {
    LED_REG = LED_B; // Blue LED = Bootloader active

    while (1) {
        /* 1. Print Official Shakti Flame Logo */
        uart_puts(shakti_logo);

        uart_puts(">> SHAKTI XMODEM BOOTLOADER READY <<\r\n");
        uart_puts("Commands:\r\n");
        uart_puts("  'u' -> Upload C application via XMODEM (app.bin)\r\n");
        uart_puts("  'r' -> Redisplay Shakti Boot Logo and banner\r\n");
        uart_puts("  'b' -> Boot existing program in SPRAM\r\n\r\n");
        uart_puts("Press 'u' to upload, or 'r' to redisplay logo (auto-upload in 5s)...\r\n");

        int mode = 0; // 0 = default upload, 1 = upload, 2 = redisplay logo, 3 = boot
        for (int countdown = 5; countdown > 0; countdown--) {
            uart_putc('[');
            print_dec(countdown);
            uart_puts("s] ");
            for (int k = 0; k < 10; k++) {
                int ch = uart_getc_timeout(TICKS_100MS);
                if (ch == 'u' || ch == 'U' || ch == SOH) {
                    mode = 1;
                    break;
                } else if (ch == 'r' || ch == 'R' || ch == '\r' || ch == '\n') {
                    mode = 2;
                    break;
                } else if (ch == 'b' || ch == 'B') {
                    mode = 3;
                    break;
                }
            }
            if (mode != 0) break;
        }

        if (mode == 2) {
            continue; // Loop back and redisplay logo
        }

        if (mode == 3) {
            uart_puts("\r\n[BOOT] Jumping directly to 0x00010000...\r\n");
            LED_REG = LED_G;
            delay_ms(50);
            void (*user_app)(void) = (void (*)(void))USER_RAM_ADDR;
            user_app();
            uart_puts("\r\n[BOOT] Program ended.\r\n\r\n");
            continue;
        }

        /* Mode 0 or 1: Enter XMODEM receive mode */
        uart_puts("\r\n\r\n[XMODEM] Ready! In picocom: press [Ctrl+A] then [Ctrl+S]\r\n");
        uart_puts("[XMODEM] Enter file: ./user_app/app.bin\r\n");
        uart_puts("[XMODEM] Waiting for transfer (press 'r' to cancel)...\r\n\r\n");

        uint8_t *dest = (uint8_t *)USER_RAM_ADDR;
        uint8_t expected_packet_num = 1;
        uint8_t packet_data[128];
        int upload_started = 0;
        int total_bytes = 0;

        /* XMODEM Receive Loop: Send NAK once per second until sender responds */
        while (!upload_started) {
            uart_putc(NAK);

            int ch = uart_getc_timeout(TICKS_1S);
            if (ch == 'r' || ch == 'R') {
                break; // User wants menu again
            }

            if (ch == SOH) {
                upload_started = 1;

                /* Receiving XMODEM Packets */
                while (1) {
                    if (ch == SOH) {
                        int pnum = uart_getc_timeout(TICKS_100MS);
                        int pnum_inv = uart_getc_timeout(TICKS_100MS);

                        uint8_t checksum = 0;
                        int error = 0;
                        for (int i = 0; i < 128; i++) {
                            int b = uart_getc_timeout(TICKS_100MS);
                            if (b == -1) { error = 1; break; }
                            packet_data[i] = (uint8_t)b;
                            checksum += (uint8_t)b;
                        }

                        int recv_chk = uart_getc_timeout(TICKS_100MS);

                        if (!error && (pnum + pnum_inv == 255) && (recv_chk == (int)checksum)) {
                            if (pnum == expected_packet_num) {
                                for (int i = 0; i < 128; i++) {
                                    *dest++ = packet_data[i];
                                }
                                total_bytes += 128;
                                expected_packet_num++;
                            }
                            uart_putc(ACK);
                        } else {
                            uart_putc(NAK);
                        }
                    } else if (ch == EOT) {
                        uart_putc(ACK);
                        break; // Transfer complete!
                    }

                    ch = uart_getc_timeout(TICKS_1S);
                }

                break;
            }
        }

        /* If upload succeeded, jump to user application in SPRAM! */
        if (upload_started && total_bytes > 0) {
            uart_puts("\r\n==================================================\r\n");
            uart_puts("[BOOT] Upload Successful (");
            print_dec(total_bytes);
            uart_puts(" bytes)!\r\n");
            uart_puts("[BOOT] Jumping to User Application @ 0x00010000...\r\n");
            uart_puts("==================================================\r\n\r\n");

            LED_REG = LED_G; // Green LED = User App Running
            delay_ms(100);

            /* Transfer execution to 0x00010000 in SPRAM */
            void (*user_app)(void) = (void (*)(void))USER_RAM_ADDR;
            user_app();

            /* If user app returns */
            uart_puts("\r\n[BOOT] User Application returned to Bootloader.\r\n\r\n");
            LED_REG = LED_B;
        }

        delay_ms(1000);
    }

    return 0;
}
