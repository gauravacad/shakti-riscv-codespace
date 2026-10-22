# Shakti E-Class & RISC-V Development Codespace

This repository provides an automated, browser-based **GitHub Codespaces** development environment for Shakti RISC-V E-Class processor design and software development.

---

## 🛠️ Included Tools & Environment

The container comes pre-configured with:
- **RISC-V Toolchains:** `riscv32-unknown-elf-gcc`, `riscv64-unknown-elf-gcc`, `ar`, `objdump`, `objcopy` (with multilib RV32/RV64 support).
- **Simulators:** 
  - `spike` (RISC-V ISA simulator)
  - `pk` (RISC-V 32-bit proxy kernel)
  - `iverilog` (Icarus Verilog)
  - `verilator`
- **Bluespec Compiler:** BSC 2024.07 (`BLUESPECDIR=/usr/local/lib`, with `Prelude` symlinks and `BlueNoC` path fixes).
- **Python EDA tools:** `pyserial`, `miniterm`.
- **Shakti Repositories (Editable in Workspace):**
  - `shakti-e-class`: [https://github.com/anmolsahoo25/shakti-e-class](https://github.com/anmolsahoo25/shakti-e-class)
  - `shakti-sdk`: [https://gitlab.com/shaktiproject/software/shakti-sdk.git](https://gitlab.com/shaktiproject/software/shakti-sdk.git)

---

## 🚀 How to Put This on GitHub and Launch Codespace

### Step 1: Create a New GitHub Repository
1. Go to [github.com/new](https://github.com/new).
2. Enter a repository name (for example, `shakti-riscv-codespace`).
3. Choose **Public** (or Private) and leave initialize with README unchecked.
4. Click **Create repository**.

### Step 2: Push This Folder to GitHub
Run the following commands in your local terminal:

```bash
cd "e:\making an codespace"
git init -b main
git add .
git commit -m "feat: complete Shakti E-Class & RISC-V codespace devcontainer"
git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPO_NAME>.git
git push -u origin main
```

*(Replace `<YOUR_GITHUB_USERNAME>` and `<YOUR_REPO_NAME>` with your actual repository information).*

### Step 3: Launch in GitHub Codespaces
1. Open your repository on GitHub.
2. Click the green **Code** button.
3. Switch to the **Codespaces** tab.
4. Click **Create codespace on main**.

GitHub will automatically build the container and initialize the environment.

---

## 💻 Workflow & Commands Inside the Codespace

Once your Codespace opens in VS Code:

### 1. Verify Tool Installations
Run the diagnostic script:
```bash
./scripts/verify_tools.sh
```

### 2. Generate Shakti E-Class Verilog
You can use the helper script:
```bash
./scripts/generate_verilog.sh
```

Or run the manual steps:
```bash
cd shakti-e-class/base-sim
./manager.sh update_deps
make CONFIG=soc_config.inc generate_verilog
```
The generated Verilog files will appear in `shakti-e-class/base-sim/verilog/`.

### 3. Editing Code
All files under `shakti-e-class/` and `shakti-sdk/` are directly mounted in the workspace. You can edit any `.bsv`, `.v`, or `.c` files directly in VS Code, commit your changes, and push them to your git remote:
```bash
git status
git add .
git commit -m "Updated Shakti core modifications"
git push
```

---

## ⚙️ Applied Fixes Summary
The container automatically applies the following fixes upon creation:
1. **GHC Stack Integer Overflow:** Patched `-K40000M` to `-K4000M` in `shakti-e-class/base-sim/Makefile`.
2. **Obsolete Filter:** Stripped `-verilog-filter` from the Bluespec compile line.
3. **Library Paths:** Configured `/usr/local/lib/Prelude` and `/usr/local/lib/Libraries/BlueNoC` for modern BSC 2024.07 compatibility.
4. **Toolchain Symlinks:** Linked 64-bit multi-lib RISC-V GCC to `riscv32-unknown-elf-*` and generic `riscv-unknown-elf-*`.
