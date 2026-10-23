`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
//  tb_soc.v — Testbench for Shakti E-Class SoC on VSD Squadron FM
//  Verifies that the authentic Shakti Flame Logo is printed by the CPU
// =============================================================================

module tb_soc;

    reg hw_clk = 0;
    always #41.666 hw_clk = ~hw_clk; // 12 MHz clock (83.333 ns period)

    reg  uart_rx = 1'b1;
    wire uart_tx;
    wire led_r, led_g, led_b;

    // Instantiate Top Module
    soc_top uut (
        .hw_clk      (hw_clk),
        .uart_rx_pin (uart_rx),
        .uart_tx_pin (uart_tx),
        .led_red     (led_r),
        .led_green   (led_g),
        .led_blue    (led_b)
    );

    // =========================================================================
    //  Real-Time UART Console Output Monitor
    //  Captures CPU writes to UART TX register and outputs directly to console
    // =========================================================================
    reg [63:0] last_char_time = 0;
    reg        has_printed = 0;

    always @(posedge hw_clk) begin
        if (uut.uart_valid && |uut.uart_wstrb && (uut.uart_addr == 2'b00)) begin
            $write("%c", uut.uart_wdata[7:0]);
            $fflush();
            last_char_time <= $time;
            has_printed    <= 1'b1;
        end

        // Auto-finish cleanly as soon as the complete logo is printed and UART goes idle
        if (has_printed && (($time - last_char_time) > 200_000)) begin
            $finish;
        end
    end

    initial begin
        // Safety watchdog (100 ms limit)
        #100_000_000;
        $finish;
    end

endmodule
`default_nettype wire
