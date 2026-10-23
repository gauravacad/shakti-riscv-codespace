// =============================================================================
//  bram_boot.v — Dual-Port Block RAM boot memory (4 KB = 1024 words)
//  Port A: Dedicated Instruction Fetch (Master I)
//  Port B: Dedicated Data Read/Write (Master D)
//  Synthesizes directly to Lattice iCE40 Embedded Block RAM (EBR)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module bram_boot #(
    parameter integer WORDS = 1024
) (
    input  wire        clk,

    // Port A: Instruction Fetch (Read-only)
    input  wire        i_valid,
    input  wire [13:0] i_addr,
    output reg  [31:0] i_rdata,

    // Port B: Data Access (Read / Write)
    input  wire        d_valid,
    input  wire [13:0] d_addr,
    input  wire [31:0] d_wdata,
    input  wire [ 3:0] d_wstrb,
    output reg  [31:0] d_rdata
);

    reg [31:0] mem [0:WORDS-1];

    initial begin
        $readmemh("firmware.hex", mem);
    end

    // Port A: Synchronous Instruction Read
    always @(posedge clk) begin
        if (i_valid) begin
            i_rdata <= (i_addr < WORDS) ? mem[i_addr] : 32'h00000013; // NOP if out-of-range
        end
    end

    // Port B: Synchronous Data Read & Byte-Masked Write
    always @(posedge clk) begin
        if (d_valid) begin
            if (d_addr < WORDS) begin
                if (d_wstrb[0]) mem[d_addr][ 7: 0] <= d_wdata[ 7: 0];
                if (d_wstrb[1]) mem[d_addr][15: 8] <= d_wdata[15: 8];
                if (d_wstrb[2]) mem[d_addr][23:16] <= d_wdata[23:16];
                if (d_wstrb[3]) mem[d_addr][31:24] <= d_wdata[31:24];
                d_rdata <= mem[d_addr];
            end else begin
                d_rdata <= 32'h00000000;
            end
        end
    end

endmodule
`default_nettype wire
