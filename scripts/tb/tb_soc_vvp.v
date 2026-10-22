`timescale 1ns/1ps

module tb_soc_vvp;

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
        $display("[TB] System reset released. Starting Shakti E-Class simulation on VVP...");
    end

    // Instantiate Top SoC module (mkSoc)
    mkSoc soc_inst (
        .CLK(clk),
        .RST_N(rst_n),
        .io_uart_SIN(uart_rx),
        .io_uart_SOUT(uart_tx)
    );

    // Instantiate UART Receiver to print characters to terminal
    uart_rx_monitor #(
        .CLK_FREQ(50_000_000),
        .BAUD(115200)
    ) uart_mon (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_tx)
    );

    // Simulation timeout watchdog (stops runaway simulation)
    initial begin
        #500_000_000; // 500 ms simulation time limit
        $display("\n[TB] Simulation timeout reached.");
        $finish;
    end

endmodule
