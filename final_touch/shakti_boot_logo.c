#include <stdint.h>

volatile uint64_t tohost __attribute__((section(".tohost"))) = 0;
volatile uint64_t fromhost __attribute__((section(".tohost"))) = 0;

void put_c(char c) {
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
    tohost = (code << 1) | 1;
    while (1);
}

static const char shakti_logo[] =
    "\n"
    "                        ./((*\n"
    "                     ,(((((,\n"
    "                   *((((((,\n"
    "               ./(((((((,\n"
    "             ./((((((((* \n"
    "          *(((((((((/\n"
    "       .(((((((((((,\n"
    "    ,((((((((((((/\n"
    "  ((((((((((((((/\n"
    " .((((((((((((((/\n"
    "    *(((((((((((.\n"
    "        /(((((((.\n"
    "         ..   *(((\n"
    "             *((,   ,/\n"
    "               ((((((/.\n"
    "               ((((((((((/\n"
    "                ((((((((((((/\n"
    "                ((((((((((((((.\n"
    "               ((((((((((((/\n"
    "             *((((((((((* \n"
    "             ((((((((((.\n"
    "          /((((((((* \n"
    "       *(((((((,\n"
    "     *((((((.\n"
    "  .(((((\n"
    "./(((*\n"
    ".\n"
    "\n"
    "==================================================\n"
    "   SHAKTI PROCESSORS — IIT MADRAS E-CLASS CORE    \n"
    "   RV32IMAC RISC-V SoC Running in Software        \n"
    "   Developed by RISE Lab, IIT Madras              \n"
    "==================================================\n\n";

__attribute__((section(".text.init"))) void _start(void) {
    __asm__ volatile ("li sp, 0x80020000");

    // Print the Flame Logo
    print_str(shakti_logo);

    print_str(">> SHAKTI HARDWARE BOOT SUCCESSFUL! <<\n");
    print_str("Core Architecture : RV32IMAC (Integer + Mul/Div + Atomics + Compressed)\n");
    print_str("Simulation Engine : RISC-V Instruction Simulator (Zero Hardware Board)\n\n");

    exit_sim(0);
}
