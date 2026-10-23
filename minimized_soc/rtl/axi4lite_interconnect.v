// =============================================================================
//  axi4lite_interconnect.v — Complete AXI4-Lite Crossbar for Shakti E-Class SoC
//  Targets Lattice iCE40UP5K (VSD Squadron FM)
//  Memory Map:
//    0x0000_0000 - 0x0000_0FFF : 4 KB Boot ROM (Dual-Port EBR with Shakti Logo)
//    0x0001_0000 - 0x0001_FFFF : 64 KB/128 KB User RAM (On-Chip SPRAM Hard Macros)
//    0x0200_0000 - 0x0200_000F : Simple UART @ 9600 Baud
//    0x0300_0000               : RGB LED Register (bits [2:0] = {R, G, B})
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module axi4lite_interconnect (
    input  wire        clk,
    input  wire        rst_n,

    // -------------------------------------------------------------------------
    //  AXI4-Lite Master I (Instruction Fetch from Shakti Core)
    // -------------------------------------------------------------------------
    input  wire        m_i_arvalid,
    input  wire [31:0] m_i_araddr,
    output wire        m_i_arready,
    output reg         m_i_rvalid,
    output wire [31:0] m_i_rdata,
    output wire [ 1:0] m_i_rresp,
    input  wire        m_i_rready,

    // -------------------------------------------------------------------------
    //  AXI4-Lite Master D (Data Load/Store from Shakti Core)
    // -------------------------------------------------------------------------
    input  wire        m_d_arvalid,
    input  wire [31:0] m_d_araddr,
    output wire        m_d_arready,
    output reg         m_d_rvalid,
    output wire [31:0] m_d_rdata,
    output wire [ 1:0] m_d_rresp,
    input  wire        m_d_rready,

    input  wire        m_d_awvalid,
    input  wire [31:0] m_d_awaddr,
    output wire        m_d_awready,
    input  wire        m_d_wvalid,
    input  wire [31:0] m_d_wdata,
    input  wire [ 3:0] m_d_wstrb,
    output wire        m_d_wready,
    output reg         m_d_bvalid,
    output wire [ 1:0] m_d_bresp,
    input  wire        m_d_bready,

    // -------------------------------------------------------------------------
    //  Slave 1: Dual-Port Boot RAM (bram_boot)
    // -------------------------------------------------------------------------
    output wire        bram_i_valid,
    output wire [13:0] bram_i_addr,
    input  wire [31:0] bram_i_rdata,

    output wire        bram_d_valid,
    output wire [13:0] bram_d_addr,
    output wire [31:0] bram_d_wdata,
    output wire [ 3:0] bram_d_wstrb,
    input  wire [31:0] bram_d_rdata,

    // -------------------------------------------------------------------------
    //  Slave 2: SPRAM (128 KB On-Chip User RAM)
    // -------------------------------------------------------------------------
    output wire        spram_ren,
    output wire        spram_wen,
    output wire [16:0] spram_addr,
    output wire [31:0] spram_din,
    output wire [ 3:0] spram_wstrb,
    input  wire [31:0] spram_dout,

    // -------------------------------------------------------------------------
    //  Slave 3: Simple UART
    // -------------------------------------------------------------------------
    output wire        uart_valid,
    output wire [ 1:0] uart_addr,
    output wire [31:0] uart_wdata,
    output wire [ 3:0] uart_wstrb,
    input  wire [31:0] uart_rdata,
    input  wire        uart_ready,

    // -------------------------------------------------------------------------
    //  Slave 4: RGB LED Register Output
    // -------------------------------------------------------------------------
    output reg  [ 2:0] led_reg
);

    assign m_i_rresp = 2'b00; // OKAY
    assign m_d_rresp = 2'b00; // OKAY
    assign m_d_bresp = 2'b00; // OKAY

    // -------------------------------------------------------------------------
    //  Master I (Instruction Fetch FSM)
    // -------------------------------------------------------------------------
    wire i_sel_bram  = (m_i_araddr[31:16] == 16'h0000);
    wire i_sel_spram = (m_i_araddr[31:16] == 16'h0001);

    reg i_busy;
    reg i_sel_spram_q;
    assign m_i_arready = !i_busy && !m_i_rvalid;

    assign bram_i_valid = m_i_arvalid && m_i_arready && i_sel_bram;
    assign bram_i_addr  = m_i_araddr[13:2];

    assign m_i_rdata    = i_sel_spram_q ? spram_dout : bram_i_rdata;

    always @(posedge clk) begin
        if (!rst_n) begin
            i_busy        <= 1'b0;
            m_i_rvalid    <= 1'b0;
            i_sel_spram_q <= 1'b0;
        end else begin
            if (m_i_arvalid && m_i_arready) begin
                i_busy        <= 1'b1;
                i_sel_spram_q <= i_sel_spram;
            end else if (i_busy) begin
                i_busy     <= 1'b0;
                m_i_rvalid <= 1'b1;
            end else if (m_i_rvalid && m_i_rready) begin
                m_i_rvalid <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    //  Master D Read FSM
    // -------------------------------------------------------------------------
    wire d_ar_is_bram  = (m_d_araddr[31:16] == 16'h0000);
    wire d_ar_is_spram = (m_d_araddr[31:16] == 16'h0001);
    wire d_ar_is_uart  = (m_d_araddr[31:24] == 8'h02) || (m_d_araddr[31:16] == 16'h0002);

    reg [1:0] d_read_src_q; // 0: BRAM, 1: SPRAM, 2: UART
    reg       d_read_busy;
    assign m_d_arready = !d_read_busy && !m_d_rvalid && !m_d_bvalid;

    reg [31:0] d_rdata_q;
    assign m_d_rdata = d_rdata_q;

    always @(posedge clk) begin
        if (!rst_n) begin
            d_read_busy  <= 1'b0;
            m_d_rvalid   <= 1'b0;
            d_read_src_q <= 2'd0;
            d_rdata_q    <= 32'd0;
        end else begin
            if (m_d_arvalid && m_d_arready) begin
                d_read_busy  <= 1'b1;
                d_read_src_q <= d_ar_is_uart  ? 2'd2 :
                                d_ar_is_spram ? 2'd1 : 2'd0;
            end else if (d_read_busy) begin
                d_read_busy <= 1'b0;
                m_d_rvalid  <= 1'b1;
                d_rdata_q   <= (d_read_src_q == 2'd2) ? uart_rdata :
                               (d_read_src_q == 2'd1) ? spram_dout :
                                                        bram_d_rdata;
            end else if (m_d_rvalid && m_d_rready) begin
                m_d_rvalid  <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    //  Master D Independent Write Channel Handler (AW & W)
    // -------------------------------------------------------------------------
    reg        aw_done;
    reg        w_done;
    reg [31:0] awaddr_q;
    reg [31:0] wdata_q;
    reg [ 3:0] wstrb_q;

    assign m_d_awready = !aw_done && !m_d_bvalid;
    assign m_d_wready  = !w_done  && !m_d_bvalid;

    wire aw_fire = m_d_awvalid && m_d_awready;
    wire w_fire  = m_d_wvalid  && m_d_wready;

    wire write_complete = (aw_done || aw_fire) && (w_done || w_fire);

    always @(posedge clk) begin
        if (!rst_n) begin
            aw_done    <= 1'b0;
            w_done     <= 1'b0;
            awaddr_q   <= 32'd0;
            wdata_q    <= 32'd0;
            wstrb_q    <= 4'd0;
            m_d_bvalid <= 1'b0;
            led_reg    <= 3'b000;
        end else begin
            if (aw_fire) begin
                aw_done  <= 1'b1;
                awaddr_q <= m_d_awaddr;
            end
            if (w_fire) begin
                w_done  <= 1'b1;
                wdata_q <= m_d_wdata;
                wstrb_q <= m_d_wstrb;
            end

            if (write_complete && !m_d_bvalid) begin
                m_d_bvalid <= 1'b1;
                // Handle LED register write directly
                if (eff_awaddr[31:24] == 8'h03) begin
                    led_reg <= eff_wdata[2:0];
                end
            end else if (m_d_bvalid && m_d_bready) begin
                m_d_bvalid <= 1'b0;
                aw_done    <= 1'b0;
                w_done     <= 1'b0;
            end
        end
    end

    wire [31:0] eff_awaddr = aw_fire ? m_d_awaddr : awaddr_q;
    wire [31:0] eff_wdata  = w_fire  ? m_d_wdata  : wdata_q;
    wire [ 3:0] eff_wstrb  = w_fire  ? m_d_wstrb  : wstrb_q;

    // Address Decode for Data Writes
    wire aw_is_bram  = (eff_awaddr[31:16] == 16'h0000);
    wire aw_is_spram = (eff_awaddr[31:16] == 16'h0001);
    wire aw_is_uart  = (eff_awaddr[31:24] == 8'h02) || (eff_awaddr[31:16] == 16'h0002);

    // 1. Dual-Port BRAM Port B (Data)
    wire d_bram_write = write_complete && !m_d_bvalid && aw_is_bram;
    wire d_bram_read  = m_d_arvalid && m_d_arready && d_ar_is_bram;

    assign bram_d_valid = d_bram_write | d_bram_read;
    assign bram_d_addr  = d_bram_write ? eff_awaddr[13:2] : m_d_araddr[13:2];
    assign bram_d_wdata = eff_wdata;
    assign bram_d_wstrb = d_bram_write ? eff_wstrb : 4'b0000;

    // 2. SPRAM (128 KB)
    wire d_spram_write = write_complete && !m_d_bvalid && aw_is_spram;
    wire d_spram_read  = m_d_arvalid && m_d_arready && d_ar_is_spram;
    wire i_spram_read  = m_i_arvalid && m_i_arready && i_sel_spram;

    assign spram_wen   = d_spram_write;
    assign spram_ren   = d_spram_read | i_spram_read;
    assign spram_addr  = d_spram_write ? eff_awaddr[16:0] :
                         d_spram_read  ? m_d_araddr[16:0] :
                                         m_i_araddr[16:0];
    assign spram_din   = eff_wdata;
    assign spram_wstrb = d_spram_write ? eff_wstrb : 4'b0000;

    // 3. UART Slave
    wire d_uart_write = write_complete && !m_d_bvalid && aw_is_uart;
    wire d_uart_read  = m_d_arvalid && m_d_arready && d_ar_is_uart;

    assign uart_valid = d_uart_write | d_uart_read;
    assign uart_addr  = d_uart_write ? eff_awaddr[3:2] : m_d_araddr[3:2];
    assign uart_wdata = eff_wdata;
    assign uart_wstrb = d_uart_write ? eff_wstrb : 4'b0000;

endmodule
`default_nettype wire
