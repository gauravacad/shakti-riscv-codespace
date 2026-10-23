`timescale 1ns / 1ps
`default_nettype none

module RegFile (
    input  wire        CLK,
    input  wire [4:0]  ADDR_IN,
    input  wire [31:0] D_IN,
    input  wire        WE,

    input  wire [4:0]  ADDR_1,
    output wire [31:0] D_OUT_1,

    input  wire [4:0]  ADDR_2,
    output wire [31:0] D_OUT_2,

    input  wire [4:0]  ADDR_3,
    output wire [31:0] D_OUT_3,

    input  wire [4:0]  ADDR_4,
    output wire [31:0] D_OUT_4,

    input  wire [4:0]  ADDR_5,
    output wire [31:0] D_OUT_5
);
    parameter addr_width = 5;
    parameter data_width = 32;
    parameter lo = 0;
    parameter hi = 31;

    assign D_OUT_3 = 32'b0;
    assign D_OUT_4 = 32'b0;
    assign D_OUT_5 = 32'b0;

`ifndef SYNTHESIS
    // =========================================================================
    // Simulation: Asynchronous Dual-Port Model for cycle-exact execution
    // =========================================================================
    reg [31:0] arr [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            arr[i] = 32'd0;
    end

    always @(posedge CLK) begin
        if (WE && ADDR_IN != 5'd0)
            arr[ADDR_IN] <= D_IN;
    end

    assign D_OUT_1 = (ADDR_1 == 5'd0) ? 32'd0 : (WE && ADDR_1 == ADDR_IN) ? D_IN : arr[ADDR_1];
    assign D_OUT_2 = (ADDR_2 == 5'd0) ? 32'd0 : (WE && ADDR_2 == ADDR_IN) ? D_IN : arr[ADDR_2];

`else
    // =========================================================================
    // Synthesis: Hardware Dual-BRAM Mapping for Lattice iCE40UP5K
    // =========================================================================
    reg [31:0] ram1 [0:31];
    reg [31:0] ram2 [0:31];
    reg [31:0] dout1;
    reg [31:0] dout2;

    always @(posedge CLK) begin
        if (WE && ADDR_IN != 5'd0) begin
            ram1[ADDR_IN] <= D_IN;
            ram2[ADDR_IN] <= D_IN;
        end
    end

    always @(negedge CLK) begin
        dout1 <= ram1[ADDR_1];
        dout2 <= ram2[ADDR_2];
    end

    assign D_OUT_1 = (ADDR_1 == 5'd0) ? 32'b0 : (WE && ADDR_1 == ADDR_IN) ? D_IN : dout1;
    assign D_OUT_2 = (ADDR_2 == 5'd0) ? 32'b0 : (WE && ADDR_2 == ADDR_IN) ? D_IN : dout2;

`endif

endmodule
`default_nettype wire
