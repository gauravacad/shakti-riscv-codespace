`timescale 1ns/1ps

module uart_rx_monitor #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD     = 115200
)(
    input wire clk,
    input wire rst_n,
    input wire rx
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD;

    reg [3:0]  bit_idx;
    reg [7:0]  rx_byte;
    reg [31:0] clk_cnt;
    reg [1:0]  state;

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            clk_cnt  <= 0;
            bit_idx  <= 0;
            rx_byte  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx == 1'b0)
                        state <= START;
                end
                START: begin
                    if (clk_cnt == (CLKS_PER_BIT / 2)) begin
                        if (rx == 1'b0) begin
                            clk_cnt <= 0;
                            state   <= DATA;
                        end else begin
                            state   <= IDLE;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end
                DATA: begin
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        rx_byte[bit_idx] <= rx;
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end
                    end
                end
                STOP: begin
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        $write("%c", rx_byte);
                        $fflush();
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
