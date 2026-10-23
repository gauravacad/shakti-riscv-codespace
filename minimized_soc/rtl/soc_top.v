// =============================================================================
//  soc_top.v — Authentic IIT Madras Shakti E-Class SoC for VSD Squadron FM
//  Target FPGA: Lattice iCE40UP5K-SG48
//
//  Design Highlights:
//    1. Core: IIT Madras Trimmed Shakti E-Class (RV32IAC)
//    2. Clock: SB_HFOSC Hard Macro @ 12 MHz (Matches working vsd_FPGA/hello)
//    3. Boot Memory: Dual-Port 4KB EBR BRAM initialized with Shakti Flame Logo
//    4. User Memory: 128KB Zero-LUT On-Chip SPRAM (4x SB_SPRAM256KA Hard Blocks)
//    5. UART: 9600 Baud Simple UART (Pin 14 TX, Pin 15 RX, CLKDIV = 1250)
//    6. LED: SB_RGBA_DRV Hard Macro Driving RGB LED with Hardware Heartbeat
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module soc_top (
    input  wire hw_clk,      // Mapped to Pin 20 in PCF (SB_HFOSC internal clock used)
    input  wire uart_rx_pin, // Pin 15
    output wire uart_tx_pin, // Pin 14
    output wire led_red,     // Pin 39 (SB_RGBA_DRV RGB2)
    output wire led_green,   // Pin 40 (SB_RGBA_DRV RGB0)
    output wire led_blue     // Pin 41 (SB_RGBA_DRV RGB1)
);

    // =========================================================================
    //  1. Clock: 12.000 MHz Hardware Crystal Oscillator on Pin 20
    //     Provides 0% drift, exact timing for 9600 Baud UART
    // =========================================================================
    wire clk = hw_clk;

    // =========================================================================
    //  2. Power-on Reset Generator (Holds core in reset for first 1024 cycles)
    // =========================================================================
    reg [9:0] por_cnt = 10'd0;
    wire      rst_n   = &por_cnt;

    always @(posedge clk) begin
        if (!rst_n)
            por_cnt <= por_cnt + 10'd1;
    end

    // =========================================================================
    //  3. Heartbeat Counter for Visual Live Status
    // =========================================================================
    reg [23:0] heartbeat = 24'd0;
    always @(posedge clk) begin
        heartbeat <= heartbeat + 24'd1;
    end

    // =========================================================================
    //  4. Core Bus Signals (AXI4-Lite)
    // =========================================================================
    wire        m_i_arvalid, m_i_arready, m_i_rvalid, m_i_rready;
    wire [31:0] m_i_araddr, m_i_rdata;
    wire [ 1:0] m_i_rresp;
    wire [ 2:0] m_i_arprot;
    wire [ 1:0] m_i_arsize;
    wire        m_i_awvalid, m_i_wvalid, m_i_bready;
    wire [31:0] m_i_awaddr, m_i_wdata;
    wire [ 3:0] m_i_wstrb;

    wire        m_d_arvalid, m_d_arready, m_d_rvalid, m_d_rready;
    wire [31:0] m_d_araddr, m_d_rdata;
    wire [ 1:0] m_d_rresp;
    wire [ 2:0] m_d_arprot;
    wire [ 1:0] m_d_arsize;

    wire        m_d_awvalid, m_d_awready, m_d_wvalid, m_d_wready;
    wire [31:0] m_d_awaddr, m_d_wdata;
    wire [ 3:0] m_d_wstrb;
    wire [ 2:0] m_d_awprot;
    wire [ 1:0] m_d_awsize;
    wire        m_d_bvalid, m_d_bready;
    wire [ 1:0] m_d_bresp;

    // =========================================================================
    //  5. Instantiate Genuine IIT Madras Trimmed Shakti E-Class Core
    // =========================================================================
    mkeclass_axi4lite shakti_cpu (
        .CLK          (clk),
        .RST_N        (rst_n),
        .resetpc      (32'h0000_0000), // Boot starts from 0x0000_0000 in BRAM

        // Master I (Instruction Fetch)
        .master_i_arvalid (m_i_arvalid),
        .master_i_araddr  (m_i_araddr),
        .master_i_arprot  (m_i_arprot),
        .master_i_arsize  (m_i_arsize),
        .master_i_rready  (m_i_rready),
        .master_i_m_arready_arready (m_i_arready),
        .master_i_m_rvalid_rvalid   (m_i_rvalid),
        .master_i_m_rvalid_rdata    (m_i_rdata),
        .master_i_m_rvalid_rresp    (m_i_rresp),
        .master_i_awvalid (m_i_awvalid),
        .master_i_awaddr  (m_i_awaddr),
        .master_i_awprot  (),
        .master_i_awsize  (),
        .master_i_wvalid  (m_i_wvalid),
        .master_i_wdata   (m_i_wdata),
        .master_i_wstrb   (m_i_wstrb),
        .master_i_bready  (m_i_bready),
        .master_i_m_awready_awready (1'b1),
        .master_i_m_wready_wready   (1'b1),
        .master_i_m_bvalid_bvalid   (1'b0),
        .master_i_m_bvalid_bresp    (2'b00),

        // Master D (Data Load/Store)
        .master_d_arvalid (m_d_arvalid),
        .master_d_araddr  (m_d_araddr),
        .master_d_arprot  (m_d_arprot),
        .master_d_arsize  (m_d_arsize),
        .master_d_rready  (m_d_rready),
        .master_d_m_arready_arready (m_d_arready),
        .master_d_m_rvalid_rvalid   (m_d_rvalid),
        .master_d_m_rvalid_rdata    (m_d_rdata),
        .master_d_m_rvalid_rresp    (m_d_rresp),
        .master_d_awvalid (m_d_awvalid),
        .master_d_awaddr  (m_d_awaddr),
        .master_d_awprot  (m_d_awprot),
        .master_d_awsize  (m_d_awsize),
        .master_d_wvalid  (m_d_wvalid),
        .master_d_wdata   (m_d_wdata),
        .master_d_wstrb   (m_d_wstrb),
        .master_d_bready  (m_d_bready),
        .master_d_m_awready_awready (m_d_awready),
        .master_d_m_wready_wready   (m_d_wready),
        .master_d_m_bvalid_bvalid   (m_d_bvalid),
        .master_d_m_bvalid_bresp    (m_d_bresp),

        // Sideband interrupt tie-offs
        .sb_clint_msip_put          (1'b0),
        .sb_clint_mtip_put          (1'b0),
        .sb_clint_mtime_put         (64'd0),
        .sb_ext_interrupt_put       (1'b0),
        .EN_sb_clint_msip_put       (1'b0),
        .EN_sb_clint_mtip_put       (1'b0),
        .EN_sb_clint_mtime_put      (1'b0),
        .EN_sb_ext_interrupt_put    (1'b0),
        .RDY_sb_clint_msip_put      (),
        .RDY_sb_clint_mtip_put      (),
        .RDY_sb_clint_mtime_put     (),
        .RDY_sb_ext_interrupt_put   ()
    );

    // =========================================================================
    //  6. Subsystem Wires
    // =========================================================================
    // Dual-Port BRAM
    wire        bram_i_valid;
    wire [13:0] bram_i_addr;
    wire [31:0] bram_i_rdata;
    wire        bram_d_valid;
    wire [13:0] bram_d_addr;
    wire [31:0] bram_d_wdata, bram_d_rdata;
    wire [ 3:0] bram_d_wstrb;

    // SPRAM
    wire        spram_ren, spram_wen;
    wire [16:0] spram_addr;
    wire [31:0] spram_din, spram_dout;
    wire [ 3:0] spram_wstrb;

    // UART
    wire        uart_valid, uart_ready;
    wire [ 1:0] uart_addr;
    wire [31:0] uart_wdata, uart_rdata;
    wire [ 3:0] uart_wstrb;

    // LED
    wire [ 2:0] led_ctrl;

    // =========================================================================
    //  7. AXI4-Lite Interconnect
    // =========================================================================
    axi4lite_interconnect xbar (
        .clk        (clk),
        .rst_n      (rst_n),

        .m_i_arvalid(m_i_arvalid),
        .m_i_araddr (m_i_araddr),
        .m_i_arready(m_i_arready),
        .m_i_rvalid (m_i_rvalid),
        .m_i_rdata  (m_i_rdata),
        .m_i_rresp  (m_i_rresp),
        .m_i_rready (m_i_rready),

        .m_d_arvalid(m_d_arvalid),
        .m_d_araddr (m_d_araddr),
        .m_d_arready(m_d_arready),
        .m_d_rvalid (m_d_rvalid),
        .m_d_rdata  (m_d_rdata),
        .m_d_rresp  (m_d_rresp),
        .m_d_rready (m_d_rready),

        .m_d_awvalid(m_d_awvalid),
        .m_d_awaddr (m_d_awaddr),
        .m_d_awready(m_d_awready),
        .m_d_wvalid (m_d_wvalid),
        .m_d_wdata  (m_d_wdata),
        .m_d_wstrb  (m_d_wstrb),
        .m_d_wready (m_d_wready),
        .m_d_bvalid (m_d_bvalid),
        .m_d_bresp  (m_d_bresp),
        .m_d_bready (m_d_bready),

        // Dual-Port BRAM
        .bram_i_valid(bram_i_valid),
        .bram_i_addr (bram_i_addr),
        .bram_i_rdata(bram_i_rdata),
        .bram_d_valid(bram_d_valid),
        .bram_d_addr (bram_d_addr),
        .bram_d_wdata(bram_d_wdata),
        .bram_d_wstrb(bram_d_wstrb),
        .bram_d_rdata(bram_d_rdata),

        // SPRAM
        .spram_ren   (spram_ren),
        .spram_wen   (spram_wen),
        .spram_addr  (spram_addr),
        .spram_din   (spram_din),
        .spram_wstrb (spram_wstrb),
        .spram_dout  (spram_dout),

        // UART
        .uart_valid (uart_valid),
        .uart_addr  (uart_addr),
        .uart_wdata (uart_wdata),
        .uart_wstrb (uart_wstrb),
        .uart_rdata (uart_rdata),
        .uart_ready (uart_ready),

        // LED
        .led_reg    (led_ctrl)
    );

    // =========================================================================
    //  8. Dual-Port Boot RAM (Bitstream Pre-loaded with Shakti Flame Logo)
    // =========================================================================
    bram_boot #(.WORDS(1024)) boot_rom (
        .clk     (clk),
        .i_valid (bram_i_valid),
        .i_addr  (bram_i_addr),
        .i_rdata (bram_i_rdata),
        .d_valid (bram_d_valid),
        .d_addr  (bram_d_addr),
        .d_wdata (bram_d_wdata),
        .d_wstrb (bram_d_wstrb),
        .d_rdata (bram_d_rdata)
    );

    // =========================================================================
    //  9. 128 KB On-Chip SPRAM (4x Hard Blocks, Zero LUT Cost)
    // =========================================================================
    spram_128kb user_ram (
        .clk   (clk),
        .rst_n (rst_n),
        .addr  (spram_addr),
        .din   (spram_din),
        .wstrb (spram_wstrb),
        .wen   (spram_wen),
        .ren   (spram_ren),
        .dout  (spram_dout)
    );

    // =========================================================================
    //  10. Simple UART (115200 Baud: CLKDIV = 12,000,000 / 115,200 = 104)
    // =========================================================================
    simpleuart #(.CLKDIV(104)) u_uart (
        .clk      (clk),
        .resetn   (rst_n),
        .tx       (uart_tx_pin),
        .rx       (uart_rx_pin),
        .mem_valid(uart_valid),
        .mem_addr (uart_addr),
        .mem_wdata(uart_wdata),
        .mem_wstrb(uart_wstrb),
        .mem_rdata(uart_rdata),
        .mem_ready(uart_ready)
    );

    // =========================================================================
    //  11. Hardware RGB LED Driver (Hard Macro SB_RGBA_DRV, Zero LUTs)
    //  RGB0 = Green (Pin 40), RGB1 = Blue (Pin 41), RGB2 = Red (Pin 39)
    // =========================================================================
`ifdef SYNTHESIS
    SB_RGBA_DRV #(
        .CURRENT_MODE ("0b1"),
        .RGB0_CURRENT ("0b000001"),
        .RGB1_CURRENT ("0b000001"),
        .RGB2_CURRENT ("0b000001")
    ) RGB_DRIVER (
        .RGBLEDEN(1'b1),
        .CURREN  (1'b1),
        .RGB0PWM (heartbeat[23] | led_ctrl[1]), // Green LED (Blinks as Heartbeat)
        .RGB1PWM (led_ctrl[0]),                 // Blue LED (Active during TX)
        .RGB2PWM (led_ctrl[2]),                 // Red LED (Error indicator)
        .RGB0    (led_green),
        .RGB1    (led_blue),
        .RGB2    (led_red)
    );
`else
    assign led_green = heartbeat[23] | led_ctrl[1];
    assign led_blue  = led_ctrl[0];
    assign led_red   = led_ctrl[2];
`endif

endmodule
`default_nettype wire
