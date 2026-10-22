FROM mcr.microsoft.com/devcontainers/base:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV BLUESPECDIR=/usr/local/lib
ENV PATH="/usr/local/bin:/opt/riscv/bin:${PATH}"

# 1. Install system prerequisites, build tools, Verilog EDA tools, and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bison \
    flex \
    bc \
    git \
    curl \
    wget \
    vim \
    tar \
    unzip \
    ca-certificates \
    libtinfo6 \
    libtinfo-dev \
    libgmp10 \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    zlib1g-dev \
    device-tree-compiler \
    iverilog \
    verilator \
    gtkwave \
    openocd \
    gdb-multiarch \
    python3 \
    python3-pip \
    python3-setuptools \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-all-dev \
    gcc-riscv64-unknown-elf \
    binutils-riscv64-unknown-elf \
    picolibc-riscv64-unknown-elf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure RISC-V Toolchain Aliases & Symlinks (/opt/riscv, riscv32-, riscv-)
RUN mkdir -p /opt/riscv/bin && \
    for tool in gcc g++ ar as ld nm objcopy objdump ranlib size strings strip; do \
        if [ -f "/usr/bin/riscv64-unknown-elf-$tool" ]; then \
            ln -sf "/usr/bin/riscv64-unknown-elf-$tool" "/opt/riscv/bin/riscv64-unknown-elf-$tool" && \
            ln -sf "/usr/bin/riscv64-unknown-elf-$tool" "/usr/local/bin/riscv32-unknown-elf-$tool" && \
            ln -sf "/usr/bin/riscv64-unknown-elf-$tool" "/usr/local/bin/riscv-unknown-elf-$tool" ; \
        fi \
    done

# 3. Download and install pre-built Bluespec Compiler (BSC 2024.07 for Ubuntu 22.04)
RUN wget -q https://github.com/B-Lang-org/bsc/releases/download/2024.07/bsc-2024.07-ubuntu-22.04.tar.gz -O /tmp/bsc.tar.gz && \
    tar -xzf /tmp/bsc.tar.gz -C /usr/local --strip-components=1 && \
    rm -f /tmp/bsc.tar.gz && \
    ln -sf /usr/local/lib/Libraries /usr/local/lib/Prelude && \
    mkdir -p /usr/local/lib/Libraries/BlueNoC

# 4. Install Python Serial tools & create miniterm wrapper
RUN pip3 install --no-cache-dir pyserial && \
    echo '#!/usr/bin/env bash\nexec python3 -m serial.tools.miniterm "$@"' > /usr/local/bin/miniterm && \
    chmod +x /usr/local/bin/miniterm

# 7. Environment variable setup for all login & interactive shells
RUN echo "export BLUESPECDIR=/usr/local/lib" >> /etc/profile.d/shakti-env.sh && \
    echo "export PATH=/usr/local/bin:/opt/riscv/bin:\$PATH" >> /etc/profile.d/shakti-env.sh && \
    echo "export BLUESPECDIR=/usr/local/lib" >> /home/vscode/.bashrc && \
    echo "export PATH=/usr/local/bin:/opt/riscv/bin:\$PATH" >> /home/vscode/.bashrc && \
    chown vscode:vscode /home/vscode/.bashrc
