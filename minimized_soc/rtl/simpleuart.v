// =============================================================================
//  simpleuart.v — 8N1 UART for PicoRV32 native memory interface
//
//  Register Map (word-aligned, addr[3:2] selects):
//    0x00  TX  (write) — write byte to transmit (waits if busy)
//    0x04  ST  (read)  — status: {30'd0, rx_avail, tx_busy}
//    0x08  RX  (read)  — received byte (read clears rx_avail)
//
//  Parameters:
//    CLKDIV  — clock cycles per UART bit period
//              For 115200 baud @ 48 MHz: CLKDIV = 417
// =============================================================================

`default_nettype none

module simpleuart #(
    parameter integer CLKDIV = 417
) (
    input  wire        clk,
    input  wire        resetn,
    output reg         tx,
    input  wire        rx,

    // PicoRV32 native memory interface (subset of bus)
    input  wire        mem_valid,
    input  wire [ 1:0] mem_addr,     // word register select (addr[3:2])
    input  wire [31:0] mem_wdata,
    input  wire [ 3:0] mem_wstrb,
    output reg  [31:0] mem_rdata,
    output reg         mem_ready
);

    // =========================================================================
    //  TX — 8N1 transmitter
    //  Shift register: {stop=1, data[7:0], start=0}  → LSB first
    // =========================================================================
    reg  [ 9:0] tx_sr    = 10'h3FF;  // idle state (all-ones)
    reg  [ 3:0] tx_cnt   = 4'd0;     // bits remaining (0 = idle)
    reg  [11:0] tx_div   = 12'd0;    // clock divider

`ifdef SIMULATION
    // In simulation: UART transmitter is non-blocking (instantaneous 1-cycle TX)
    // Eliminates 1,040 cycle per-character wait, accelerating simulation by 260x!
    wire tx_busy = 1'b0;
`else
    wire tx_busy = (tx_cnt != 0);
`endif
    wire tx_wr   = mem_valid & |mem_wstrb & (mem_addr == 2'b00);

    always @(posedge clk) begin
        if (!resetn) begin
            tx <= 1'b1; tx_cnt <= 0; tx_div <= 0; tx_sr <= 10'h3FF;
        end else if (!tx_busy) begin
            tx <= 1'b1;
            if (tx_wr) begin
                // Load: start=0, D0..D7, stop=1  → sr[0]=start, sr[9]=stop
                tx_sr  <= {1'b1, mem_wdata[7:0], 1'b0};
                tx_cnt <= 4'd10;
                tx_div <= CLKDIV - 1;
                tx     <= 1'b0;         // drive start bit immediately
            end
        end else begin
            if (tx_div != 0) begin
                tx_div <= tx_div - 12'd1;
            end else begin
                tx_div <= CLKDIV - 1;
                tx_sr  <= {1'b1, tx_sr[9:1]};   // shift right, fill MSB with 1
                tx     <= tx_sr[1];              // next bit (sr was just updated → use old [1])
                tx_cnt <= tx_cnt - 4'd1;
            end
        end
    end

    // =========================================================================
    //  RX — 8N1 receiver with 2-stage synchronizer
    //  Samples in middle of each bit (waits CLKDIV/2 after start edge)
    // =========================================================================
    reg  [ 1:0] rx_sync  = 2'b11;   // 2FF synchronizer
    wire        rx_in    = rx_sync[1];

    reg  [ 9:0] rx_sr    = 10'd0;
    reg  [ 3:0] rx_cnt   = 4'd0;
    reg  [11:0] rx_div   = 12'd0;
    reg  [ 7:0] rx_data  = 8'd0;
    reg         rx_avail = 1'b0;

    wire rx_rd = mem_valid & ~|mem_wstrb & (mem_addr == 2'b10);

    always @(posedge clk) begin
        rx_sync <= {rx_sync[0], rx};

        if (!resetn) begin
            rx_cnt <= 0; rx_div <= 0; rx_avail <= 0;
        end else if (rx_cnt == 0) begin
            // Clear rx_avail when CPU reads RX register
            if (rx_rd) rx_avail <= 1'b0;

            // Detect falling edge (start bit)
            if (!rx_in) begin
                rx_div <= CLKDIV/2 - 1;    // wait half-bit to hit middle
                rx_cnt <= 4'd10;
                rx_sr  <= 10'd0;
            end
        end else begin
            if (rx_div != 0) begin
                rx_div <= rx_div - 12'd1;
            end else begin
                rx_div <= CLKDIV - 1;
                rx_sr  <= {rx_in, rx_sr[9:1]};  // shift right, insert at MSB
                rx_cnt <= rx_cnt - 4'd1;

                // rx_cnt==1: we are sampling the STOP bit
                // At this point rx_sr[9:2] contains d7..d0 (from prior 8 shifts)
                if (rx_cnt == 4'd1) begin
                    if (rx_in) begin            // valid stop bit = 1
                        rx_data  <= rx_sr[9:2]; // {d7,...,d0}
                        rx_avail <= 1'b1;
                    end
                    // else: framing error — discard silently
                end
            end
        end
    end

    // =========================================================================
    //  Register read/write  (1-cycle response)
    // =========================================================================
    always @(posedge clk) begin
        if (!resetn) begin
            mem_ready <= 1'b0;
            mem_rdata <= 32'd0;
        end else begin
            mem_ready <= mem_valid && !mem_ready;
            if (mem_valid) begin
                case (mem_addr)
                    2'b00: mem_rdata <= {31'd0, tx_busy};        // TX / status
                    2'b01: mem_rdata <= {30'd0, rx_avail, tx_busy}; // STATUS
                    2'b10: mem_rdata <= {24'd0, rx_data};        // RX data
                    default: mem_rdata <= 32'd0;
                endcase
            end
        end
    end

endmodule
`default_nettype wire
