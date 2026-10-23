import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5) # 16:9 widescreen layout

blank_layout = prs.slide_layouts[6]

DARK_SLATE = RGBColor(15, 23, 42)
TEXT_MUTED = RGBColor(100, 116, 139)
CARD_BG = RGBColor(248, 250, 252)
CARD_BORDER = RGBColor(226, 232, 240)
DARK_TERM_BG = RGBColor(15, 23, 42)
DARK_TERM_BORDER = RGBColor(30, 41, 59)

def add_header(slide, title_text, chapter_badge, page_ref, badge_color):
    top_line = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(0.1))
    top_line.fill.solid()
    top_line.fill.fore_color.rgb = badge_color
    top_line.line.color.rgb = badge_color
    
    badge = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(0.32), Inches(3.4), Inches(0.36))
    badge.fill.solid()
    badge.fill.fore_color.rgb = RGBColor(241, 245, 249)
    badge.line.color.rgb = badge_color
    badge.line.width = Pt(1.5)
    tf = badge.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = chapter_badge
    p.font.size = Pt(9.5)
    p.font.bold = True
    p.font.color.rgb = badge_color
    p.alignment = PP_ALIGN.CENTER
    
    tx_box = slide.shapes.add_textbox(Inches(9.2), Inches(0.32), Inches(3.3), Inches(0.36))
    p_ref = tx_box.text_frame.paragraphs[0]
    p_ref.text = page_ref
    p_ref.font.size = Pt(9.5)
    p_ref.font.color.rgb = RGBColor(148, 163, 184)
    p_ref.alignment = PP_ALIGN.RIGHT
    
    t_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.72), Inches(11.7), Inches(0.7))
    p_title = t_box.text_frame.paragraphs[0]
    p_title.text = title_text
    p_title.font.size = Pt(21)
    p_title.font.bold = True
    p_title.font.color.rgb = DARK_SLATE

def add_footer(slide, current_idx, total=12):
    f_box = slide.shapes.add_textbox(Inches(0.8), Inches(6.9), Inches(11.7), Inches(0.35))
    p = f_box.text_frame.paragraphs[0]
    p.text = f'SHAKTI User Manual v1.3.1 (RISE Lab, IIT Madras)  •  Module {current_idx} of {total}'
    p.font.size = Pt(9)
    p.font.color.rgb = RGBColor(148, 163, 184)

# ==================== SLIDE 1: Cover ====================
s1 = prs.slides.add_slide(blank_layout)
add_header(s1, 'SHAKTI Processor & SoC Platform Walkthrough', 'OFFICIAL MANUAL WALKTHROUGH', 'Manual v1.3.1', RGBColor(234, 88, 12))
sub_box = s1.shapes.add_textbox(Inches(0.8), Inches(1.4), Inches(11.7), Inches(0.8))
p_sub = sub_box.text_frame.paragraphs[0]
p_sub.text = 'Complete Chapter-Wise Visual Engineering Guide based on SHAKTI User Manual V1.3.1\nRISE Lab, IIT Madras • Swadeshi Microprocessor Challenge (MeitY)'
p_sub.font.size = Pt(13)
p_sub.font.color.rgb = RGBColor(71, 85, 105)

colors = [RGBColor(254, 242, 242), RGBColor(239, 246, 255), RGBColor(236, 253, 245)]
borders = [RGBColor(248, 113, 113), RGBColor(96, 165, 250), RGBColor(52, 211, 153)]
titles = ['🇮🇳 Swadeshi Initiative', '🧩 6 Processor Classes', '⚡ Complete Ecosystem']
bodies = [
    'Indigenous open-source production-grade processors developed at IIT Madras, funded by MeitY to create sovereign silicon solutions.',
    'Full RISC-V roadmap spanning from ultra-low power 32-bit microcontrollers (E-Class) to 64-bit multi-core servers (C-Class & I-Class).',
    'Full ecosystem: Bluespec SystemVerilog (BSV) RTL, Vivado bitstreams, Board Support Packages (BSP), FreeRTOS, and OpenOCD GDB debugging.'
]
for i in range(3):
    c = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8 + i*4.0), Inches(2.4), Inches(3.7), Inches(4.2))
    c.fill.solid()
    c.fill.fore_color.rgb = colors[i]
    c.line.color.rgb = borders[i]
    c.line.width = Pt(1.5)
    tf = c.text_frame
    tf.word_wrap = True
    p1 = tf.paragraphs[0]
    p1.text = titles[i]
    p1.font.size = Pt(15)
    p1.font.bold = True
    p1.font.color.rgb = DARK_SLATE
    p2 = tf.add_paragraph()
    p2.text = '\n' + bodies[i]
    p2.font.size = Pt(11)
    p2.font.color.rgb = RGBColor(51, 65, 85)
add_footer(s1, 1)

# ==================== SLIDE 2: E-Class ====================
s2 = prs.slides.add_slide(blank_layout)
add_header(s2, 'E-Class: Embedded & IoT Microcontroller Core', 'CHAPTER 1.1 • PROCESSOR FAMILIES', 'Page 6-7 (Sec 1.1.1)', RGBColor(37, 99, 235))
# Subtitle
sub = s2.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Positioned against ARM Cortex-M series for low-power compute, automotive sensors, and smart meters.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left Card: Specs
c_left = s2.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_left.fill.solid()
c_left.fill.fore_color.rgb = CARD_BG
c_left.line.color.rgb = CARD_BORDER
tf_l = c_left.text_frame
tf_l.word_wrap = True
p = tf_l.paragraphs[0]
p.text = 'MICROARCHITECTURE SPECIFICATIONS'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(37, 99, 235)
specs = [
    ('Architecture', '32-bit RISC-V In-Order pipeline'),
    ('Pipeline Depth', '3-Stage (Fetch → Decode/Execute → Writeback)'),
    ('Operating Frequency', '< 200 MHz on ASIC silicon; 50 MHz on Artix-7 FPGA'),
    ('ISA Support', 'RV32IMAC (Base Integer, Mul/Div, Atomic, Compressed)'),
    ('Privilege Modes', 'Machine (M) mode and optional User (U) mode'),
    ('Physical Protection', 'PMP (Physical Memory Protection) enabled'),
    ('Target Workloads', 'Motor control, IoT sensor nodes, smart cards, automation')
]
for title, desc in specs:
    p_i = tf_l.add_paragraph()
    p_i.text = f'• {title}: {desc}'
    p_i.font.size = Pt(10)
    p_i.font.color.rgb = DARK_SLATE

# Right Card: 3-Stage Pipeline Diagram
c_right = s2.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_right.fill.solid()
c_right.fill.fore_color.rgb = CARD_BG
c_right.line.color.rgb = CARD_BORDER
tf_r = c_right.text_frame
tf_r.word_wrap = True
p = tf_r.paragraphs[0]
p.text = '3-STAGE IN-ORDER PIPELINE FLOW'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(79, 70, 229)

stages = [
    ('Stage 1: Instruction Fetch (IF)', 'Program counter generation, Instruction cache lookup or BRAM memory access, 16-bit compressed instruction decompressor.'),
    ('Stage 2: Decode & Execute (ID / EX)', 'Instruction decoding, Register file operand read, Integer ALU arithmetic/logic, Branch resolution, Multi-cycle pipelined multiplier/divider.'),
    ('Stage 3: Memory & Writeback (MEM / WB)', 'Data cache / peripheral MMIO read/write access, Register file commit, CSR updates, Exception & Interrupt handling.')
]
for title, desc in stages:
    p_t = tf_r.add_paragraph()
    p_t.text = f'\n📌 {title}'
    p_t.font.size = Pt(11)
    p_t.font.bold = True
    p_t.font.color.rgb = DARK_SLATE
    p_d = tf_r.add_paragraph()
    p_d.text = desc
    p_d.font.size = Pt(10)
    p_d.font.color.rgb = RGBColor(71, 85, 105)
add_footer(s2, 2)

# ==================== SLIDE 3: C-Class ====================
s3 = prs.slides.add_slide(blank_layout)
add_header(s3, 'C-Class: Mid-Range 64-Bit Controller Core', 'CHAPTER 1.1 • PROCESSOR FAMILIES', 'Page 6-7 (Sec 1.1.2)', RGBColor(147, 51, 234))
sub = s3.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Industrial 64-bit core running up to 1 GHz, equipped with Sv39 MMU to boot full Linux distributions.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Table comparing E-Class vs C-Class
rows, cols = 7, 3
left, top, width, height = Inches(0.8), Inches(2.0), Inches(11.7), Inches(4.5)
table_shape = s3.shapes.add_table(rows, cols, left, top, width, height)
tbl = table_shape.table
tbl.columns[0].width = Inches(3.7)
tbl.columns[1].width = Inches(4.0)
tbl.columns[2].width = Inches(4.0)

headers = ['Feature Attribute', 'SHAKTI E-Class (e32)', 'SHAKTI C-Class (c64)']
for j, h in enumerate(headers):
    cell = tbl.cell(0, j)
    cell.fill.solid()
    cell.fill.fore_color.rgb = RGBColor(241, 245, 249)
    p = cell.text_frame.paragraphs[0]
    p.text = h
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = DARK_SLATE

comparison = [
    ('Word Size (XLEN)', '32-bit (RV32)', '64-bit (RV64)'),
    ('Pipeline Structure', '3-Stage In-Order (Fetch, Decode/Exec, WB)', '5-Stage In-Order (Fetch, Decode, Exec, Mem, WB)'),
    ('Silicon Clock Frequency', '< 200 MHz on ASIC', '800 MHz – 1.0 GHz on ASIC'),
    ('Memory Management (MMU)', 'Physical Memory Protection (PMP)', 'Sv39 MMU (Full Virtual Memory for Linux)'),
    ('Target ARM Equivalent', 'ARM Cortex-M0+ / M4', 'ARM Cortex-A35 / Cortex-A55'),
    ('Supported Operating Systems', 'Baremetal, FreeRTOS, Zephyr RTOS', 'Full Linux, FreeBSD, RTEMS, FreeRTOS')
]
for i, row in enumerate(comparison):
    for j, val in enumerate(row):
        cell = tbl.cell(i+1, j)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(255, 255, 255) if i % 2 == 0 else RGBColor(248, 250, 252)
        p = cell.text_frame.paragraphs[0]
        p.text = val
        p.font.size = Pt(10)
        if j == 0:
            p.font.bold = True
            p.font.color.rgb = DARK_SLATE
        elif j == 2:
            p.font.bold = True
            p.font.color.rgb = RGBColor(147, 51, 234)
        else:
            p.font.color.rgb = RGBColor(37, 99, 235)
add_footer(s3, 3)

# ==================== SLIDE 4: Boards & SoC Flavors ====================
s4 = prs.slides.add_slide(blank_layout)
add_header(s4, 'Development Boards & 3 Reference SoC Flavors', 'CHAPTER 2 • BOARD DETAILS & SOCS', 'Page 9-11 (Sec 2.1)', RGBColor(16, 185, 129))
sub = s4.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'The Swadeshi Microprocessor Challenge supports three official SoCs targeting Digilent Xilinx Artix-7 boards.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

soc_cards = [
    ('PINAKA (e32-a35)', 'Arty A7-35T FPGA', RGBColor(239, 246, 255), RGBColor(96, 165, 250), [
        'Core: E-Class 32-bit (RV32IMAC)',
        'RAM: 128KB On-Chip BRAM (No DDR)',
        'Peripherals: 3 UART, 2 SPI, 2 I2C, 6 PWM, 32 GPIO',
        'Special: Xilinx ADC (XADC) hardware interface',
        'Use Case: Low cost embedded sensors & motor drives'
    ]),
    ('PARASHU (e32-a100)', 'Arty A7-100T FPGA', RGBColor(254, 243, 199), RGBColor(251, 191, 36), [
        'Core: E-Class 32-bit (RV32IMAC)',
        'RAM: 256MB DDR3 High-Speed External RAM',
        'Networking: 10/100 AXI Ethernet Lite MAC',
        'Peripherals: Full Pinaka I/O set + Ethernet',
        'Use Case: Networked IoT gateways & buffer-heavy apps'
    ]),
    ('VAJRA (c64-a100)', 'Arty A7-100T FPGA', RGBColor(243, 232, 255), RGBColor(192, 132, 252), [
        'Core: C-Class 64-bit (RV64IMAC)',
        'RAM: 128MB DDR3 High-Speed External RAM',
        'Networking: 10/100 AXI Ethernet Lite MAC',
        'Privilege Modes: Machine, Supervisor, User',
        'Use Case: Capable of booting full Linux OS kernel'
    ])
]
for i, (name, target, bg, border, points) in enumerate(soc_cards):
    c = s4.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8 + i*4.0), Inches(2.0), Inches(3.7), Inches(4.6))
    c.fill.solid()
    c.fill.fore_color.rgb = bg
    c.line.color.rgb = border
    c.line.width = Pt(1.5)
    tf = c.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = name
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = DARK_SLATE
    p_t = tf.add_paragraph()
    p_t.text = f'Target: {target}\n'
    p_t.font.size = Pt(10)
    p_t.font.bold = True
    p_t.font.color.rgb = TEXT_MUTED
    for pt in points:
        p_pt = tf.add_paragraph()
        p_pt.text = f'• {pt}'
        p_pt.font.size = Pt(9.5)
        p_pt.font.color.rgb = DARK_SLATE
add_footer(s4, 4)

# ==================== SLIDE 5: Board Setup & FTDI ====================
s5 = prs.slides.add_slide(blank_layout)
add_header(s5, 'Hardware Connections & Dual-Channel FTDI Debugger', 'CHAPTER 3.1 & 3.2 • BOARD SETUP', 'Page 11-13 (Sec 3.1-3.2)', RGBColor(245, 158, 11))
sub = s5.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Single Micro-USB connector (J10) supplies 5V power, JTAG hardware debugging, and UART0 serial console.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left Card: FTDI Dual Channel
c_l5 = s5.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_l5.fill.solid()
c_l5.fill.fore_color.rgb = CARD_BG
c_l5.line.color.rgb = CARD_BORDER
tf_l5 = c_l5.text_frame
tf_l5.word_wrap = True
p = tf_l5.paragraphs[0]
p.text = 'FTDI FT2232H DUAL-CHANNEL ROUTING'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(245, 158, 11)

ftdi_info = [
    ('Channel A (MPSSE Engine): JTAG Hardware Debugging', 'Wired to FPGA JTAG pins (TCK, TMS, TDI, TDO). Used directly by OpenOCD to communicate with the RISC-V Debug Module over JTAG, providing hardware breakpoints and stepping without an external pod.'),
    ('Channel B (Serial UART): System Console Terminal', 'Wired directly to the SHAKTI SoC UART0 (TX/RX) pins at 19,200 baud (8N1). Presents a standard virtual COM port (/dev/ttyUSB0 or COMx) on the host PC for console printf output.')
]
for title, desc in ftdi_info:
    p_t = tf_l5.add_paragraph()
    p_t.text = f'\n🔹 {title}'
    p_t.font.size = Pt(10.5)
    p_t.font.bold = True
    p_t.font.color.rgb = DARK_SLATE
    p_d = tf_l5.add_paragraph()
    p_d.text = desc
    p_d.font.size = Pt(9.5)
    p_d.font.color.rgb = RGBColor(71, 85, 105)

# Right Card: Step-by-Step Connection
c_r5 = s5.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_r5.fill.solid()
c_r5.fill.fore_color.rgb = DARK_TERM_BG
c_r5.line.color.rgb = DARK_TERM_BORDER
tf_r5 = c_r5.text_frame
tf_r5.word_wrap = True
p = tf_r5.paragraphs[0]
p.text = 'SETUP PROCEDURE & VERIFICATION'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(56, 189, 248)

steps_r5 = [
    '1. Connect J10 Port: Plug Micro-USB cable into connector J10 on the Arty-7 board and host PC.',
    '2. Verify Power LED: Green LED LD11 turns ON, confirming 5V bus power delivery.',
    '3. Check Linux Device Nodes:',
    '   $ ls -l /dev/ttyUSB*',
    '   /dev/ttyUSB0  (UART0 Console @ 19,200 baud)',
    '   /dev/ttyUSB1  (OpenOCD JTAG MPSSE Engine)',
    '4. Grant Serial Permissions on Host PC:',
    '   $ sudo usermod -a -G dialout $USER',
    '   $ sudo chmod 666 /dev/ttyUSB*'
]
for step in steps_r5:
    p_s = tf_r5.add_paragraph()
    p_s.text = step
    p_s.font.size = Pt(9.5)
    p_s.font.color.rgb = RGBColor(226, 232, 240) if not step.startswith('   $') else RGBColor(52, 211, 153)
add_footer(s5, 5)

# ==================== SLIDE 6: FPGA Programming ====================
s6 = prs.slides.add_slide(blank_layout)
add_header(s6, 'Programming SHAKTI onto SPI Configuration Memory', 'CHAPTER 3.3 • FPGA FLASHING', 'Page 13-19 (Sec 3.3.3-3.3.6)', RGBColor(225, 29, 72))
sub = s6.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Burn the compiled .mcs configuration file into onboard Quad-SPI Flash memory for persistent power-on boot.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left: Vivado GUI Steps
c_l6 = s6.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_l6.fill.solid()
c_l6.fill.fore_color.rgb = CARD_BG
c_l6.line.color.rgb = CARD_BORDER
tf_l6 = c_l6.text_frame
tf_l6.word_wrap = True
p = tf_l6.paragraphs[0]
p.text = 'VIVADO HARDWARE MANAGER WORKFLOW'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(225, 29, 72)

v_steps = [
    '1. Open Vivado: Launch Vivado Design Suite 2018.3 or newer.',
    '2. Open Hardware Manager: Click "Open Target" → "Auto Connect".',
    '3. Add Configuration Memory: Right-click FPGA target (xc7a35t or xc7a100t) and select "Add Configuration Memory Device".',
    '4. Select SPI Flash Part Parameters:',
    '   • Manufacturer: Spansion (s25fl128sxxxxxx0) or Micron (n25q128-3.3v)',
    '   • Density: 128 | Type: spi | Width: x1_x2_x4',
    '5. Program Flash: Select downloaded pinaka.mcs file and click OK.',
    '6. Reload FPGA: Press the board PROG button or power-cycle to boot!'
]
for st in v_steps:
    p_st = tf_l6.add_paragraph()
    p_st.text = st
    p_st.font.size = Pt(9.5)
    p_st.font.color.rgb = DARK_SLATE

# Right: Automated Command Line
c_r6 = s6.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_r6.fill.solid()
c_r6.fill.fore_color.rgb = DARK_TERM_BG
c_r6.line.color.rgb = DARK_TERM_BORDER
tf_r6 = c_r6.text_frame
tf_r6.word_wrap = True
p = tf_r6.paragraphs[0]
p.text = 'COMMAND-LINE AUTOMATED BUILD & FLASH'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(244, 63, 94)

cmds_r6 = [
    '# 1. Clone official SP2020 repository:',
    'git clone --recursive https://gitlab.com/shaktiproject/sp2020.git',
    'cd sp2020/e32-a35/',
    '',
    '# 2. Complete RTL synthesis & bitstream build:',
    'make generate_verilog generate_boot_files \\',
    '     ip_build arty_build generate_mcs \\',
    '     program_mcs JOBS=4',
    '',
    '# 3. Direct prebuilt .mcs programming without Vivado build:',
    '# Download prebuilt .mcs from: gitlab.com/shaktiproject/sp2020/-/tree/master/mcs',
    'openocd -f ./shakti-arty.cfg'
]
for cmd in cmds_r6:
    p_c = tf_r6.add_paragraph()
    p_c.text = cmd
    p_c.font.size = Pt(9)
    p_c.font.color.rgb = RGBColor(148, 163, 184) if cmd.startswith('#') else RGBColor(56, 189, 248)
add_footer(s6, 6)

# ==================== SLIDE 7: Memory Map ====================
s7 = prs.slides.add_slide(blank_layout)
add_header(s7, 'SoC Memory Map & Peripheral Addressing', 'CHAPTER 4 • SOC ARCHITECTURE', 'Page 20-25 (Sec 4.1)', RGBColor(8, 145, 178))
sub = s7.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Unified Memory-Mapped I/O (MMIO) address layout compliant with RISC-V Privileged Architecture v1.10.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Memory Map Table
rows, cols = 9, 4
left, top, width, height = Inches(0.8), Inches(1.9), Inches(11.7), Inches(4.7)
tbl_s7 = s7.shapes.add_table(rows, cols, left, top, width, height).table
tbl_s7.columns[0].width = Inches(2.2)
tbl_s7.columns[1].width = Inches(3.2)
tbl_s7.columns[2].width = Inches(4.5)
tbl_s7.columns[3].width = Inches(1.8)

h7 = ['Peripheral Block', 'Base Address Range', 'Description & Hardware Registers', 'Target SoCs']
for j, h in enumerate(h7):
    c = tbl_s7.cell(0, j)
    c.fill.solid()
    c.fill.fore_color.rgb = RGBColor(241, 245, 249)
    p = c.text_frame.paragraphs[0]
    p.text = h
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = DARK_SLATE

mmap_data = [
    ('Boot ROM', '0x0000_1000 - 0x0001_0FFF', 'First-stage bootloader, initial stack setup & ASCII boot logo', 'All SoCs'),
    ('UART 0', '0x0001_1300 - 0x0001_1340', 'Primary serial console wired to FTDI Micro-USB (19,200 baud)', 'All SoCs'),
    ('UART 1 & UART 2', '0x0001_1400 / 0x0001_1500', 'Auxiliary serial communication channels routed to header pins', 'All SoCs'),
    ('SPI 0 & SPI 1', '0x0002_0000 / 0x0002_0100', 'Serial Peripheral Interface for Flash memory and external sensors', 'All SoCs'),
    ('PWM 0 to PWM 5', '0x0003_0000 - 0x0003_05FF', '6 independent Pulse Width Modulation channels for motor & LED', 'All SoCs'),
    ('GPIO & PinMux', '0x0004_0100 & 0x0004_1500', '32 General Purpose I/O pins and dynamic pin multiplexing register', 'All SoCs'),
    ('CLINT & PLIC', '0x0200_0000 / 0x0C00_0000', 'Standard RISC-V timer (mtime/mtimecmp) and Platform Interrupts', 'All SoCs'),
    ('Main Memory', '0x8000_0000 - 0x8FFF_FFFF', 'Pinaka: 128KB BRAM | Parashu: 256MB DDR3 | Vajra: 128MB DDR3', 'Specific Target')
]
for i, row in enumerate(mmap_data):
    for j, val in enumerate(row):
        cell = tbl_s7.cell(i+1, j)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(255, 255, 255) if i % 2 == 0 else RGBColor(248, 250, 252)
        p = cell.text_frame.paragraphs[0]
        p.text = val
        p.font.size = Pt(9.5)
        if j == 0:
            p.font.bold = True
            p.font.color.rgb = DARK_SLATE
        elif j == 1:
            p.font.bold = True
            p.font.color.rgb = RGBColor(8, 145, 178)
        else:
            p.font.color.rgb = RGBColor(51, 65, 85)
add_footer(s7, 7)

# ==================== SLIDE 8: SDK Architecture & Setup ====================
s8 = prs.slides.add_slide(blank_layout)
add_header(s8, 'SHAKTI-SDK Architecture & Toolchain Installation', 'CHAPTER 5.1 & 5.2 • SOFTWARE ECOSYSTEM', 'Page 26-33 (Sec 5.1-5.2)', RGBColor(79, 70, 229))
sub = s8.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Modular C/C++ development framework providing Board Support Packages (BSP), drivers, and toolchain setup.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left: Stack
c_l8 = s8.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_l8.fill.solid()
c_l8.fill.fore_color.rgb = CARD_BG
c_l8.line.color.rgb = CARD_BORDER
tf_l8 = c_l8.text_frame
tf_l8.word_wrap = True
p = tf_l8.paragraphs[0]
p.text = 'LAYERED SOFTWARE ARCHITECTURE'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(79, 70, 229)

layers = [
    ('Application Layer', 'User C/C++ programs, sensor demos, algorithmic benchmarks'),
    ('OS / Middleware Layer', 'FreeRTOS kernel, Zephyr RTOS, Picolibc C standard library'),
    ('Board Support Package (BSP)', 'Hardware drivers (UART, I2C, SPI, PWM, GPIO, PinMux, XADC)'),
    ('Low-Level Architecture', 'Startup routines, Trap handlers, Linker scripts, RISC-V CSRs'),
    ('Physical Hardware', 'Pinaka (Artix-7 35T), Parashu (100T), Vajra (100T)')
]
for title, desc in layers:
    p_t = tf_l8.add_paragraph()
    p_t.text = f'\n📦 {title}'
    p_t.font.size = Pt(10)
    p_t.font.bold = True
    p_t.font.color.rgb = DARK_SLATE
    p_d = tf_l8.add_paragraph()
    p_d.text = desc
    p_d.font.size = Pt(9.5)
    p_d.font.color.rgb = RGBColor(71, 85, 105)

# Right: Toolchain Setup
c_r8 = s8.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_r8.fill.solid()
c_r8.fill.fore_color.rgb = DARK_TERM_BG
c_r8.line.color.rgb = DARK_TERM_BORDER
tf_r8 = c_r8.text_frame
tf_r8.word_wrap = True
p = tf_r8.paragraphs[0]
p.text = 'TOOLCHAIN SETUP COMMANDS'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(129, 140, 248)

cmds_r8 = [
    '# 1. Install system prerequisites (Ubuntu 18.04/20.04/22.04):',
    'sudo apt-get install autoconf automake autotools-dev curl \\',
    '     libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev bc \\',
    '     gawk build-essential bison flex texinfo gperf libtool \\',
    '     patchutils zlib1g-dev libftdi1 libftdi1-2 python3-serial',
    '',
    '# 2. Clone SHAKTI-SDK & SHAKTI-TOOLS:',
    'git clone https://gitlab.com/shaktiproject/software/shakti-sdk.git',
    'git clone https://gitlab.com/shaktiproject/software/shakti-tools.git',
    '',
    '# 3. Build RISC-V Cross Compiler & OpenOCD:',
    'cd shakti-tools && ./setup.sh',
    'export PATH=$PWD/bin:$PWD/openocd/bin:$PATH'
]
for cmd in cmds_r8:
    p_c = tf_r8.add_paragraph()
    p_c.text = cmd
    p_c.font.size = Pt(8.5)
    p_c.font.color.rgb = RGBColor(148, 163, 184) if cmd.startswith('#') else RGBColor(56, 189, 248)
add_footer(s8, 8)

# ==================== SLIDE 9: Application Development Flow ====================
s9 = prs.slides.add_slide(blank_layout)
add_header(s9, 'Application Development Flow: Adding & Compiling Code', 'CHAPTER 5.3 • APP DEVELOPMENT', 'Page 33-35 (Sec 5.3)', RGBColor(5, 150, 105))
sub = s9.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Standard process for adding a new user application, linking with BSP drivers, and generating executable ELF.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left: 4 Steps
c_l9 = s9.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_l9.fill.solid()
c_l9.fill.fore_color.rgb = CARD_BG
c_l9.line.color.rgb = CARD_BORDER
tf_l9 = c_l9.text_frame
tf_l9.word_wrap = True
p = tf_l9.paragraphs[0]
p.text = '4 STEPS TO ADD A NEW APPLICATION'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(5, 150, 105)

app_steps = [
    ('1. Choose Peripheral Directory', 'Navigate to ./software/examples/XYZ_applns (e.g. uart_applns, gpio_applns, pwm_applns).'),
    ('2. Create Application Folder & Source', 'Create a subfolder (e.g. hello_uart/) and write hello_uart.c using BSP driver APIs (#include "uart.h").'),
    ('3. Create Local Makefile', 'Define application targets, source file lists, and compilation flags adhering to the SDK structure.'),
    ('4. Register in Master Makefile', 'Add hello_uart to the target list in ./software/examples/Makefile to enable top-level building.')
]
for title, desc in app_steps:
    p_t = tf_l9.add_paragraph()
    p_t.text = f'\n📌 {title}'
    p_t.font.size = Pt(10)
    p_t.font.bold = True
    p_t.font.color.rgb = DARK_SLATE
    p_d = tf_l9.add_paragraph()
    p_d.text = desc
    p_d.font.size = Pt(9.5)
    p_d.font.color.rgb = RGBColor(71, 85, 105)

# Right: Build commands
c_r9 = s9.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_r9.fill.solid()
c_r9.fill.fore_color.rgb = DARK_TERM_BG
c_r9.line.color.rgb = DARK_TERM_BORDER
tf_r9 = c_r9.text_frame
tf_r9.word_wrap = True
p = tf_r9.paragraphs[0]
p.text = 'BUILD COMMANDS & ARTIFACTS'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(52, 211, 153)

cmds_r9 = [
    '# 1. List all registered applications:',
    'make list_applns',
    '',
    '# 2. Build for Pinaka SoC (RV32IMAC):',
    'make software PROGRAM=hello_uart TARGET=pinaka',
    '',
    '# 3. Build for Parashu SoC (RV32IMAC + DDR):',
    'make software PROGRAM=hello_uart TARGET=parashu',
    '',
    '# 4. Build for Vajra SoC (RV64IMAC):',
    'make software PROGRAM=hello_uart TARGET=vajra',
    '',
    '# Output Artifacts in output/ directory:',
    '• app.elf   (Executable and Linkable Format binary)',
    '• app.dump  (Complete RISC-V assembly disassembly)',
    '• app.hex   (Memory initialization hex for simulation)'
]
for cmd in cmds_r9:
    p_c = tf_r9.add_paragraph()
    p_c.text = cmd
    p_c.font.size = Pt(9)
    p_c.font.color.rgb = RGBColor(148, 163, 184) if cmd.startswith('#') else RGBColor(56, 189, 248)
add_footer(s9, 9)

# ==================== SLIDE 10: Interactive Debugging ====================
s10 = prs.slides.add_slide(blank_layout)
add_header(s10, 'Interactive Debugging Mode: 3-Terminal Workflow', 'CHAPTER 5.4 • DEBUGGING WORKFLOW', 'Page 35-37 (Sec 5.4)', RGBColor(2, 132, 199))
sub = s10.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Live non-intrusive debugging using OpenOCD GDB server and RISC-V GNU Debugger over USB JTAG.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# 3 Terminals side by side
t_data = [
    ('TERMINAL 1: UART CONSOLE', RGBColor(245, 158, 11), [
        '# Displays serial printf outputs:',
        'sudo miniterm.py /dev/ttyUSB0 19200',
        '',
        'Settings:',
        '• Baud Rate: 19,200 baud',
        '• Data bits: 8',
        '• Parity: None',
        '• Stop bits: 1 (8N1)'
    ]),
    ('TERMINAL 2: OPENOCD SERVER', RGBColor(6, 182, 212), [
        '# Launch OpenOCD JTAG Server:',
        'cd ./bsp/third_party/artix7_35t',
        'sudo openocd -f ftdi.cfg',
        '',
        'Status:',
        '• Initialises FT2232H MPSSE',
        '• Discovers RISC-V Tap (hart 0)',
        '• Opens GDB Server on :3333',
        '• Opens Telnet on :4444'
    ]),
    ('TERMINAL 3: RISC-V GDB', RGBColor(16, 185, 129), [
        '# Start RISC-V GDB Client:',
        'riscv32-unknown-elf-gdb',
        '',
        '(gdb) target remote localhost:3333',
        '(gdb) file output/hello_uart.elf',
        '(gdb) load',
        '(gdb) b main',
        '(gdb) continue'
    ])
]
for i, (t_title, t_col, t_lines) in enumerate(t_data):
    c = s10.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8 + i*4.0), Inches(1.9), Inches(3.7), Inches(4.7))
    c.fill.solid()
    c.fill.fore_color.rgb = DARK_TERM_BG
    c.line.color.rgb = DARK_TERM_BORDER
    tf = c.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = t_title
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = t_col
    for line in t_lines:
        p_l = tf.add_paragraph()
        p_l.text = line
        p_l.font.size = Pt(8.5)
        p_l.font.color.rgb = RGBColor(148, 163, 184) if line.startswith('#') or line.startswith('Settings:') or line.startswith('Status:') else RGBColor(241, 245, 249)
add_footer(s10, 10)

# ==================== SLIDE 11: Standalone Flash Mode ====================
s11 = prs.slides.add_slide(blank_layout)
add_header(s11, 'Running in Standalone Mode: Autonomous Power-On Boot', 'CHAPTER 5.5 • DEPLOYMENT MODE', 'Page 37-38 (Sec 5.5)', RGBColor(124, 58, 237))
sub = s11.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'The application binary is flashed into SPI Flash memory, enabling independent execution on board power-on.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left: Debug vs Standalone
c_l11 = s11.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_l11.fill.solid()
c_l11.fill.fore_color.rgb = CARD_BG
c_l11.line.color.rgb = CARD_BORDER
tf_l11 = c_l11.text_frame
tf_l11.word_wrap = True
p = tf_l11.paragraphs[0]
p.text = 'DEBUG MODE VS. STANDALONE MODE'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(124, 58, 237)

modes = [
    ('Debug Mode (Development)', 'Requires Host PC running OpenOCD and GDB over JTAG. Binary is temporarily loaded into volatile RAM. Once power is turned off, application is lost. Best for iterative development.'),
    ('Standalone Mode (Production)', 'Binary is permanently burned into non-volatile Quad-SPI Flash memory. On board reset or power-up, the hardware bootloader autonomously copies the code from Flash into RAM and executes. Best for deployed field products.')
]
for title, desc in modes:
    p_t = tf_l11.add_paragraph()
    p_t.text = f'\n📌 {title}'
    p_t.font.size = Pt(10.5)
    p_t.font.bold = True
    p_t.font.color.rgb = DARK_SLATE
    p_d = tf_l11.add_paragraph()
    p_d.text = desc
    p_d.font.size = Pt(9.5)
    p_d.font.color.rgb = RGBColor(71, 85, 105)

# Right: Upload command & Boot sequence
c_r11 = s11.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_r11.fill.solid()
c_r11.fill.fore_color.rgb = DARK_TERM_BG
c_r11.line.color.rgb = DARK_TERM_BORDER
tf_r11 = c_r11.text_frame
tf_r11.word_wrap = True
p = tf_r11.paragraphs[0]
p.text = 'FLASH UPLOAD & HARDWARE BOOT SEQUENCE'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(192, 132, 252)

seq = [
    '# One-Shot Upload Command in SHAKTI-SDK:',
    'cd shakti-sdk',
    'make upload PROGRAM=hello_uart TARGET=pinaka',
    '',
    'Hardware Execution Sequence on Reset:',
    '1. Hardware Reset: CPU resets PC to BootROM address (0x0000_1000).',
    '2. BootROM Execution: Boot code initializes memory controllers.',
    '3. SPI Flash Read: Boot loader reads user binary from SPI Flash.',
    '4. Copy to RAM: Payload copied into main RAM (0x8000_0000).',
    '5. Jump & Run: CPU jumps to RAM entry point and begins user code!'
]
for s in seq:
    p_s = tf_r11.add_paragraph()
    p_s.text = s
    p_s.font.size = Pt(9)
    p_s.font.color.rgb = RGBColor(148, 163, 184) if s.startswith('#') or s.startswith('Hardware') else RGBColor(56, 189, 248)
add_footer(s11, 11)

# ==================== SLIDE 12: Pin Mapping & PinMux ====================
s12 = prs.slides.add_slide(blank_layout)
add_header(s12, 'Arduino Pin Mapping & Dynamic PinMux Architecture', 'APPENDIX A & B • HARDWARE INTERFACING', 'Page 38-46 (Appendix A-B)', RGBColor(13, 148, 136))
sub = s12.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(0.5))
sub.text_frame.paragraphs[0].text = 'Standard Arduino Uno R3 header compatibility with 2-bit dynamic hardware multiplexing registers.'
sub.text_frame.paragraphs[0].font.size = Pt(11)
sub.text_frame.paragraphs[0].font.color.rgb = TEXT_MUTED

# Left: 2-bit mapping
c_l12 = s12.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.9), Inches(5.6), Inches(4.7))
c_l12.fill.solid()
c_l12.fill.fore_color.rgb = CARD_BG
c_l12.line.color.rgb = CARD_BORDER
tf_l12 = c_l12.text_frame
tf_l12.word_wrap = True
p = tf_l12.paragraphs[0]
p.text = 'PINMUX 2-BIT REGISTER LOGIC (0x0004_1500)'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(13, 148, 136)

pinmux_rules = [
    ('Bits = 00 (Default)', 'Configures physical pin as standard General Purpose I/O (GPIO).'),
    ('Bits = 01 (Serial / SPI)', 'Routes pin to serial peripherals: UART1, UART2, or SPI1 (TX/RX/MOSI/MISO).'),
    ('Bits = 10 (PWM Mode)', 'Routes pin to Pulse Width Modulation output (PWM0 to PWM5).'),
    ('Bits = 11 (Reserved)', 'Undefined hardware behavior; reserved for future expansions.')
]
for title, desc in pinmux_rules:
    p_t = tf_l12.add_paragraph()
    p_t.text = f'\n⚡ {title}'
    p_t.font.size = Pt(10)
    p_t.font.bold = True
    p_t.font.color.rgb = DARK_SLATE
    p_d = tf_l12.add_paragraph()
    p_d.text = desc
    p_d.font.size = Pt(9.5)
    p_d.font.color.rgb = RGBColor(71, 85, 105)

# Right: C Code example
c_r12 = s12.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(6.8), Inches(1.9), Inches(5.7), Inches(4.7))
c_r12.fill.solid()
c_r12.fill.fore_color.rgb = DARK_TERM_BG
c_r12.line.color.rgb = DARK_TERM_BORDER
tf_r12 = c_r12.text_frame
tf_r12.word_wrap = True
p = tf_r12.paragraphs[0]
p.text = 'DYNAMIC PINMUX PROGRAMMING IN C'
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = RGBColor(45, 212, 191)

c_code = [
    '#include <stdint.h>',
    '#define PINMUX_REG (*(volatile uint32_t *)0x00041500)',
    '',
    '// Example: Configure Arduino Pin IO3 (CK_IO[3]):',
    '// Bits [7:6] control CK_IO[3] routing:',
    '',
    '// 1. Enable PWM0 output on Pin IO3:',
    'PINMUX_REG &= ~(0b11 << 6);  // Clear bits 7:6',
    'PINMUX_REG |=  (0b10 << 6);  // Set bits 7:6 to 10 (PWM0)',
    '',
    '// 2. Switch Pin IO3 to UART2 TX dynamically:',
    'PINMUX_REG &= ~(0b11 << 6);  // Clear bits 7:6',
    'PINMUX_REG |=  (0b01 << 6);  // Set bits 7:6 to 01 (UART2 TX)',
    '',
    '// 3. Revert Pin IO3 back to standard GPIO:',
    'PINMUX_REG &= ~(0b11 << 6);  // Set bits 7:6 to 00 (GPIO)'
]
for l in c_code:
    p_l = tf_r12.add_paragraph()
    p_l.text = l
    p_l.font.size = Pt(8.5)
    p_l.font.color.rgb = RGBColor(148, 163, 184) if l.startswith('//') else RGBColor(56, 189, 248)
add_footer(s12, 12)

# Save
output_path = 'shakti_pdf/SHAKTI_User_Manual_Slides.pptx'
prs.save(output_path)
print(f'Successfully generated {output_path} with 12 widescreen slides!')
