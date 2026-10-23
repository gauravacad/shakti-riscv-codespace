#!/usr/bin/env bash
# ==============================================================================
# Patch SHAKTI-SDK to support Spike Simulator without affecting VVP or Hardware
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================="
echo " Patching SHAKTI-SDK for Dual-Target Spike + VVP Support"
echo "=========================================================="

SDK_DIR="${WORKSPACE_ROOT}/shakti-sdk"

if [ ! -d "${SDK_DIR}" ]; then
    echo "Warning: ${SDK_DIR} not found. Searching for shakti-sdk..."
    SDK_DIR=$(find "${WORKSPACE_ROOT}" -maxdepth 2 -type d -name "shakti-sdk" | head -n 1)
fi

if [ -z "${SDK_DIR}" ] || [ ! -d "${SDK_DIR}" ]; then
    echo "Error: shakti-sdk directory not found."
    exit 1
fi

echo "--> Target SDK: ${SDK_DIR}"

UART_C="${SDK_DIR}/bsp/drivers/uart/uart.c"

if [ ! -f "${UART_C}" ]; then
    echo "Error: ${UART_C} not found!"
    exit 1
fi

# Restore backup if available so we have a clean slate
if [ -f "${UART_C}.orig" ]; then
    cp "${UART_C}.orig" "${UART_C}"
else
    cp "${UART_C}" "${UART_C}.orig"
fi

echo "--> Patching ${UART_C} (both putchar and write_uart_character)..."

python3 - <<EOF
with open('${UART_C}', 'r') as f:
    code = f.read()

# 1. Add tohost and fromhost globals
spike_header = '''
/* Added for Spike Simulator HTIF Output (Zero VVP / FPGA impact) */
volatile unsigned long long tohost __attribute__((section(".tohost"))) = 0;
volatile unsigned long long fromhost __attribute__((section(".tohost"))) = 0;
'''
if 'tohost __attribute__' not in code:
    code = spike_header + code

# 2. Patch putchar(int ch) -- this is what printf() actually calls!
old_putchar = '''int putchar(int ch)
{
	while(uart_instance[0]->status & STS_TX_FULL);

	uart_instance[0]->tx_reg = ch;

	return 0;
}'''

new_putchar = '''int putchar(int ch)
{
	/* Spike HTIF Output: write character to Spike terminal */
	tohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)ch;

	/* Physical Hardware UART Output (Active for VVP and FPGA) */
	while(uart_instance[0]->status & STS_TX_FULL);
	uart_instance[0]->tx_reg = ch;

	return 0;
}'''

if old_putchar in code:
    code = code.replace(old_putchar, new_putchar)
    print('--> Successfully patched putchar() for printf()!')
else:
    # Fallback regex
    import re
    code = re.sub(
        r'(int\s+putchar\s*\([^)]*\)\s*\{)(.*?)(\buart_instance\[0\]->tx_reg\s*=\s*ch;)',
        r'\1\n\t/* Spike HTIF Output */\n\ttohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)ch;\n\2\3',
        code,
        flags=re.DOTALL
    )
    print('--> Applied regex patch to putchar().')

# 3. Patch write_uart_character as well
old_write = '''uint32_t write_uart_character(uart_struct * instance, uint8_t prn_character)
{
	while(instance->status & STS_TX_FULL);

	instance->tx_reg = prn_character;

	return 0;
}'''

new_write = '''uint32_t write_uart_character(uart_struct * instance, uint8_t prn_character)
{
	tohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)prn_character;
	while(instance->status & STS_TX_FULL);
	instance->tx_reg = prn_character;
	return 0;
}'''

if old_write in code:
    code = code.replace(old_write, new_write)
    print('--> Successfully patched write_uart_character()!')

with open('${UART_C}', 'w') as f:
    f.write(code)
print('--> Saved patched ${UART_C} successfully.')
EOF

echo ""
echo "=========================================================="
echo " Patch applied successfully to putchar()!"
echo " Now recompile: make clean && make software PROGRAM=hello TARGET=pinaka"
echo "=========================================================="
