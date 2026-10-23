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
    echo "Please clone it or run inside your Codespace container."
    exit 1
fi

echo "--> Target SDK: ${SDK_DIR}"

UART_C="${SDK_DIR}/bsp/drivers/uart/uart.c"

if [ ! -f "${UART_C}" ]; then
    echo "Error: ${UART_C} not found!"
    exit 1
fi

# Backup original uart.c if not already backed up
if [ ! -f "${UART_C}.orig" ]; then
    cp "${UART_C}" "${UART_C}.orig"
    echo "--> Created backup: ${UART_C}.orig"
fi

echo "--> Patching ${UART_C} with Spike HTIF tohost support..."

python3 - <<EOF
with open('${UART_C}', 'r') as f:
    code = f.read()

# Check if already patched
if 'tohost __attribute__' in code:
    print('--> Already patched with tohost.')
else:
    # 1. Add tohost and fromhost globals
    spike_header = '''
/* Added for Spike Simulator HTIF Output (Zero VVP impact) */
volatile unsigned long long tohost __attribute__((section(".tohost"))) = 0;
volatile unsigned long long fromhost __attribute__((section(".tohost"))) = 0;
'''
    code = spike_header + code

    # 2. Update write_uart_character to write to tohost as well
    old_func = '''uint32_t write_uart_character(uart_struct * instance, uint8_t prn_character)
{
	while(instance->status & STS_TX_FULL);

	instance->tx_reg = prn_character;

	return 0;
}'''

    new_func = '''uint32_t write_uart_character(uart_struct * instance, uint8_t prn_character)
{
	/* Spike HTIF Output: write character to tohost */
	tohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)prn_character;

	/* Physical Hardware UART Output (Active for VVP and FPGA) */
	while(instance->status & STS_TX_FULL);
	instance->tx_reg = prn_character;

	return 0;
}'''

    if old_func in code:
        code = code.replace(old_func, new_func)
        print('--> Successfully updated write_uart_character()!')
    else:
        # Fallback replacement if formatting varies
        import re
        pattern = r'(uint32_t\s+write_uart_character\s*\([^)]*\)\s*\{)(.*?)(\binstance->tx_reg\s*=\s*prn_character;)'
        subst = r'\1\n\t/* Spike HTIF Output */\n\ttohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)prn_character;\n\2\3'
        code = re.sub(pattern, subst, code, flags=re.DOTALL)
        print('--> Applied regex patch to write_uart_character().')

    with open('${UART_C}', 'w') as f:
        f.write(code)
    print('--> Saved patched ${UART_C} successfully.')
EOF

echo ""
echo "=========================================================="
echo " Patch applied successfully!"
echo " You can now rebuild and run on Spike in shakti-sdk:"
echo "   cd ${SDK_DIR}/software/examples/uart_applns/hello"
echo "   make software PROGRAM=hello TARGET=pinaka"
echo "   spike --isa=rv32imac ./output/hello.shakti"
echo "=========================================================="
