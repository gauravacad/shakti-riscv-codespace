FROM mcr.microsoft.com/devcontainers/base:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV BLUESPECDIR=/usr/local/lib
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin"

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
    libfdt-dev \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install prebuilt SiFive multi-lib RISC-V GCC toolchain (with full Newlib libc)
WORKDIR /opt
RUN wget -q https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz && \
    tar -xzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz && \
    mv riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 /opt/riscv && \
    rm -f *.tar.gz && \
    for tool in gcc g++ ar as ld nm objcopy objdump ranlib size strings strip; do \
        ln -sf /opt/riscv/bin/riscv64-unknown-elf-$tool /usr/local/bin/riscv64-unknown-elf-$tool && \
        ln -sf /opt/riscv/bin/riscv64-unknown-elf-$tool /usr/local/bin/riscv32-unknown-elf-$tool && \
        ln -sf /opt/riscv/bin/riscv64-unknown-elf-$tool /usr/local/bin/riscv-unknown-elf-$tool ; \
    done

# 3. Build & Install Spike
WORKDIR /tmp
RUN git clone --recurse-submodules --depth 1 https://github.com/riscv-software-src/riscv-isa-sim.git /tmp/spike && \
    mkdir -p /tmp/spike/build && cd /tmp/spike/build && \
    ../configure --prefix=/opt/riscv && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/spike && \
    ln -sf /opt/riscv/bin/spike /usr/local/bin/spike

# 4. Build & Install riscv-pk (pinned to v1.0.0 matching SiFive toolchain)
WORKDIR /tmp
RUN git clone https://github.com/riscv-software-src/riscv-pk.git /tmp/riscv-pk && \
    cd /tmp/riscv-pk && git checkout v1.0.0 && \
    mkdir -p build && cd build && \
    PATH="/opt/riscv/bin:${PATH}" CC=/opt/riscv/bin/riscv64-unknown-elf-gcc ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf && \
    PATH="/opt/riscv/bin:${PATH}" make -j$(nproc) && \
    make install && \
    ln -sf /opt/riscv/riscv64-unknown-elf/bin/pk /usr/local/bin/pk && \
    rm -rf /tmp/riscv-pk

# 5. Download and install pre-built Bluespec Compiler (BSC 2024.07 for Ubuntu 22.04)
RUN wget -q https://github.com/B-Lang-org/bsc/releases/download/2024.07/bsc-2024.07-ubuntu-22.04.tar.gz -O /tmp/bsc.tar.gz && \
    tar -xzf /tmp/bsc.tar.gz -C /usr/local --strip-components=1 && \
    rm -f /tmp/bsc.tar.gz && \
    ln -sf /usr/local/lib/Libraries /usr/local/lib/Prelude && \
    mkdir -p /usr/local/lib/Libraries/BlueNoC

# 6. Install Python Serial tools & create miniterm wrapper
RUN pip3 install --no-cache-dir pyserial && \
    echo '#!/usr/bin/env bash\nexec python3 -m serial.tools.miniterm "$@"' > /usr/local/bin/miniterm && \
    chmod +x /usr/local/bin/miniterm

# 7. Environment variable setup for all login & interactive shells
RUN echo "export BLUESPECDIR=/usr/local/lib" >> /etc/profile.d/shakti-env.sh && \
    echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin" >> /etc/profile.d/shakti-env.sh && \
    echo "export BLUESPECDIR=/usr/local/lib" >> /home/vscode/.bashrc && \
    echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin" >> /home/vscode/.bashrc && \
    chown vscode:vscode /home/vscode/.bashrc

WORKDIR /workspaces
