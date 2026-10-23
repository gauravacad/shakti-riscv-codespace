#include <stdint.h>

// HTIF interface registers for Spike RISC-V simulator
volatile uint64_t tohost __attribute__((section(".tohost"))) = 0;
volatile uint64_t fromhost __attribute__((section(".tohost"))) = 0;

void put_c(char c) {
    // Syscall write: device 1, subcmd 1 (putchar)
    uint64_t cmd = ((uint64_t)1 << 56) | ((uint64_t)1 << 48) | (uint8_t)c;
    while (tohost != 0);
    tohost = cmd;
}

void print_str(const char *s) {
    while (*s) {
        if (*s == '\n') put_c('\r');
        put_c(*s++);
    }
}

void exit_sim(int code) {
    // HTIF exit: (code << 1) | 1
    tohost = (code << 1) | 1;
    while (1);
}

int main(void) {
    print_str("\n");
    print_str("********************************************************\n");
    print_str("*                                                      *\n");
    print_str("*        HELLO WORLD FROM SHAKTI RISC-V CORE!          *\n");
    print_str("*                                                      *\n");
    print_str("*  Running natively inside your GitHub Codespace       *\n");
    print_str("*  Core Architecture: SHAKTI E-Class / C-Class          *\n");
    print_str("*  Target ISA: RV32IMAC (32-bit Integer + Extensions)  *\n");
    print_str("*                                                      *\n");
    print_str("********************************************************\n\n");

    exit_sim(0);
    return 0;
}
