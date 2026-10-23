# ==============================================================================
# core_config_base_rv32i.inc — Pure Base ISA (RV32I) Configuration for Shakti E-Class
# Strips M, A, C extensions for ultra-minimal area, fast compilation & zero DSP usage
# ==============================================================================

# 1. Base Architecture
ISA=RV32I
MUL=disable
DIV=disable
ATOMIC=disable
COMPRESSED=disable
USER=disable
SUP=disable

# 2. Pipeline Configuration
MULSTAGES=0
DIVSTAGES=0

# 3. Cache Options (can be enabled or disabled for minimal RAM)
ICACHE=enable
DCACHE=enable

# 4. Clock & Communication
CLOCK=50000000
BAUDRATE=19200
