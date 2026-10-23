import os
import glob

print("==================================================")
print(" Patching SHAKTI-SDK uart.c for Spike Simulator")
print("==================================================")

# Search for uart.c
candidates = []
for root, dirs, files in os.walk("/workspaces"):
    if "uart.c" in files and "bsp" in root:
        candidates.append(os.path.join(root, "uart.c"))

if not candidates:
    for root, dirs, files in os.walk("."):
        if "uart.c" in files and "bsp" in root:
            candidates.append(os.path.join(root, "uart.c"))

if not candidates:
    print("Error: Could not locate uart.c in /workspaces or current directory.")
    exit(1)

for path in candidates:
    print(f"--> Found: {path}")
    with open(path, "r", encoding="utf-8") as f:
        code = f.read()

    # 1. Add tohost definition if not present
    if "tohost" not in code:
        header = (
            "\n/* Added for Spike Simulator HTIF Output (Zero VVP/FPGA impact) */\n"
            'volatile unsigned long long tohost __attribute__((section(".tohost"))) = 0;\n'
            'volatile unsigned long long fromhost __attribute__((section(".tohost"))) = 0;\n\n'
        )
        code = header + code

    # 2. Patch putchar(int ch)
    tohost_write = "tohost = ((unsigned long long)1 << 56) | ((unsigned long long)1 << 48) | (unsigned char)ch;\n\t"
    if "tohost = " not in code or "putchar" not in code.split("tohost = ")[-1]:
        # Replace inside putchar
        old_pattern = "int putchar(int ch)\n{\n\twhile(uart_instance[0]->status & STS_TX_FULL);"
        new_pattern = f"int putchar(int ch)\n{{\n\t{tohost_write}while(uart_instance[0]->status & STS_TX_FULL);"
        
        if old_pattern in code:
            code = code.replace(old_pattern, new_pattern)
            print("--> Replaced in putchar() via exact match.")
        else:
            # Fallback string replacement
            target = "uart_instance[0]->tx_reg = ch;"
            replacement = f"{tohost_write}uart_instance[0]->tx_reg = ch;"
            code = code.replace(target, replacement, 1)
            print("--> Replaced in putchar() via fallback match.")

    with open(path, "w", encoding="utf-8") as f:
        f.write(code)
    print(f"--> Successfully patched {path}!")

print("\nAll done! Now rebuild and run on Spike:")
print("  cd /workspaces/*/shakti-sdk/software/examples/uart_applns/hello")
print("  make clean")
print("  make software PROGRAM=hello TARGET=pinaka")
print("  spike --isa=rv32imac ./output/hello.shakti")
