`timescale 1ns/1ps

module tb_soc_baud_fix;

    reg clk;
    reg rst_n;
    wire uart_tx;
    reg  uart_rx;

    // 50 MHz Clock generation (20ns period)
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // Reset Sequence
    initial begin
        rst_n = 1'b0;
        uart_rx = 1'b1; // UART line idle high
        #200;
        @(posedge clk);
        rst_n = 1'b1;
        $display("[TB] System reset released. Starting Fast-Baud Shakti SP2020 simulation...");
    end

    // Instantiate Top SoC module (mkSoc) with exact Pinaka / SP2020 E32-A35 ports
    mkSoc soc_inst (
        .CLK(clk),
        .RST_N(rst_n),
        .CLK_tck_clk(clk),
        .RST_N_trst(rst_n),

        // JTAG inputs tied off
        .wire_capture_capture_in(1'b0),
        .wire_run_test_run_test_in(1'b0),
        .wire_sel_sel_in(1'b0),
        .wire_shift_shift_in(1'b0),
        .wire_tdi_tdi_in(1'b0),
        .wire_tms_tms_in(1'b0),
        .wire_update_update_in(1'b0),

        // SPI input
        .spi0_io_miso_dat(1'b1),

        // UART0 interface
        .uart0_io_SIN(uart_rx),
        .uart0_io_SOUT(uart_tx),

        // I2C inputs tied high
        .i2c0_out_scl_in_in(1'b1),
        .i2c0_out_sda_in_in(1'b1),
        .i2c1_out_scl_in_in(1'b1),
        .i2c1_out_sda_in_in(1'b1)
    );

    // Fast-Baud UART monitor (32 clocks/bit = 81.5x speedup over 19200 baud)
    uart_rx_monitor #(
        .CLKS_PER_BIT(32)
    ) uart_mon (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_tx)
    );

    // Simulation watchdog (ends cleanly)
    initial begin
        #50_000_000; // 50 ms is plenty for fast baud simulation!
        $display("\n[TB] Fast-Baud simulation complete.");
        $finish;
    end

endmodule
