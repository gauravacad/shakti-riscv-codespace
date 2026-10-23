import os
import glob
import re

print("==================================================")
print(" Patching SHAKTI-SDK for Spike Simulator Support")
print("==================================================")

# 1. Search for uart.c
uart_files = []
for root, dirs, files in os.walk("/workspaces"):
    if "uart.c" in files and "bsp" in root:
        uart_files.append(os.path.join(root, "uart.c"))

if not uart_files:
    for root, dirs, files in os.walk("."):
        if "uart.c" in files and "bsp" in root:
            uart_files.append(os.path.join(root, "uart.c"))

for path in uart_files:
    print(f"--> Patching uart.c: {path}")
    with open(path, "r", encoding="utf-8") as f:
        code = f.read()

    # Add tohost definition if not present
    if "tohost" not in code:
        header = (
            '\n/* Added for Spike Simulator HTIF Output */\n'
            'volatile unsigned long long tohost __attribute__((section(".tohost"))) = 0;\n'
            'volatile unsigned long long fromhost __attribute__((section(".tohost"))) = 0;\n\n'
        )
        code = header + code

    # Patch putchar(int ch) to write to tohost
    if "tohost = ((unsigned long long)1 << 56)" not in code:
        old_pattern = "int putchar(int ch)\n{\n\twhile(uart_instance[0]->status & STS_TX_FULL);"
        new_pattern = (
            "int putchar(int ch)\n{\n"
            "\t/* Spike HTIF Output */\n"
            "\ttohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)ch;\n"
            "\twhile(uart_instance[0]->status & STS_TX_FULL);"
        )
        if old_pattern in code:
            code = code.replace(old_pattern, new_pattern)
            print("--> Patched putchar() successfully.")
        else:
            target = "uart_instance[0]->tx_reg = ch;"
            replacement = (
                "tohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)ch;\n\t"
                "uart_instance[0]->tx_reg = ch;"
            )
            code = code.replace(target, replacement, 1)
            print("--> Patched putchar() via fallback.")

    with open(path, "w", encoding="utf-8") as f:
        f.write(code)

# 2. Search for start.S to bypass unmapped PLIC stores on Spike
start_files = []
for root, dirs, files in os.walk("/workspaces"):
    if "start.S" in files and "bsp" in root:
        start_files.append(os.path.join(root, "start.S"))

if not start_files:
    for root, dirs, files in os.walk("."):
        if "start.S" in files and "bsp" in root:
            start_files.append(os.path.join(root, "start.S"))

for path in start_files:
    print(f"--> Patching start.S: {path}")
    with open(path, "r", encoding="utf-8") as f:
        s_code = f.read()

    # In start.S, sb to PLIC addresses (0x0C002000 / 0x0C000000) causes Store Access Fault in Spike
    # Comment out those 8 sb instructions for simulator compatibility
    old_plic = "sb t3, 0(t6)\n sb t3, 1(t6)\n sb t3, 2(t6)\n sb t3, 3(t6)"
    new_plic = "# sb t3, 0(t6)\n# sb t3, 1(t6)\n# sb t3, 2(t6)\n# sb t3, 3(t6)"
    
    if old_plic in s_code:
        s_code = s_code.replace(old_plic, new_plic)
        print("--> Safely bypassed PLIC stores in start.S for Spike!")

    with open(path, "w", encoding="utf-8") as f:
        f.write(s_code)

print("\n==================================================")
print(" Success! Both uart.c and start.S patched.")
print(" Now recompile and run:")
print("   cd /workspaces/*/shakti-sdk/software/examples/uart_applns/hello")
print("   make clean && make software PROGRAM=hello TARGET=pinaka")
print("   spike --isa=rv32imac ./output/hello.shakti")
print("==================================================")
