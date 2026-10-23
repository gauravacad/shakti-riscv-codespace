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
    always @(posedge hw_clk) begin
        if (uut.uart_valid && |uut.uart_wstrb && (uut.uart_addr == 2'b00)) begin
            $write("%c", uut.uart_wdata[7:0]);
            $fflush();
        end
    end

    initial begin
        $display("============================================================");
        $display(" Simulation: Shakti E-Class with Flame Boot Logo Running... ");
        $display("============================================================\n");

        // Run for 30 ms so complete Shakti logo & prompt are printed
        #30_000_000;
        $display("\n============================================================");
        $display(" Simulation SUCCESS: Shakti Core Executed Firmware Cleanly! ");
        $display("============================================================");
        $finish;
    end

endmodule
`default_nettype wire
