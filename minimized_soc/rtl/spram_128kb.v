// 128 KByte On-Chip SPRAM using 4x SB_SPRAM256KA hard blocks on Lattice iCE40UP5K
// Word-addressable, 32-bit data bus with byte-write enables.
// Zero LUT overhead (pure hard macro instantiation).

module spram_128kb (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [16:0] addr,       // Byte address (128 KB range: 0x00000 - 0x1FFFF)
    input  wire [31:0] din,
    input  wire [3:0]  wstrb,
    input  wire        wen,        // Write enable
    input  wire        ren,        // Read enable
    output wire [31:0] dout
);

    wire [13:0] s_addr = addr[15:2];
    wire bank_sel = addr[16];      // 0: lower 64KB, 1: upper 64KB

    wire [15:0] dout_low_0, dout_high_0;
    wire [15:0] dout_low_1, dout_high_1;

    // Bank 0 (Lower 64KB: 0x00000 - 0x0FFFF)
    SB_SPRAM256KA spram_b0_lo (
        .ADDRESS(s_addr),
        .DATAIN(din[15:0]),
        .MASKWREN({wstrb[1], wstrb[1], wstrb[0], wstrb[0]}),
        .WREN(wen && !bank_sel),
        .CHIPSELECT(!bank_sel && (ren || wen)),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(dout_low_0)
    );

    SB_SPRAM256KA spram_b0_hi (
        .ADDRESS(s_addr),
        .DATAIN(din[31:16]),
        .MASKWREN({wstrb[3], wstrb[3], wstrb[2], wstrb[2]}),
        .WREN(wen && !bank_sel),
        .CHIPSELECT(!bank_sel && (ren || wen)),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(dout_high_0)
    );

    // Bank 1 (Upper 64KB: 0x10000 - 0x1FFFF)
    SB_SPRAM256KA spram_b1_lo (
        .ADDRESS(s_addr),
        .DATAIN(din[15:0]),
        .MASKWREN({wstrb[1], wstrb[1], wstrb[0], wstrb[0]}),
        .WREN(wen && bank_sel),
        .CHIPSELECT(bank_sel && (ren || wen)),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(dout_low_1)
    );

    SB_SPRAM256KA spram_b1_hi (
        .ADDRESS(s_addr),
        .DATAIN(din[31:16]),
        .MASKWREN({wstrb[3], wstrb[3], wstrb[2], wstrb[2]}),
        .WREN(wen && bank_sel),
        .CHIPSELECT(bank_sel && (ren || wen)),
        .CLOCK(clk),
        .STANDBY(1'b0),
        .SLEEP(1'b0),
        .POWEROFF(1'b1),
        .DATAOUT(dout_high_1)
    );

    // Register bank_sel to align with 1-cycle SPRAM read latency
    reg bank_sel_q;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bank_sel_q <= 1'b0;
        else if (ren)
            bank_sel_q <= bank_sel;
    end

    assign dout = bank_sel_q ? {dout_high_1, dout_low_1} : {dout_high_0, dout_low_0};

endmodule

`ifndef SYNTHESIS
module SB_SPRAM256KA (
    input  wire [13:0] ADDRESS,
    input  wire [15:0] DATAIN,
    input  wire [3:0]  MASKWREN,
    input  wire        WREN,
    input  wire        CHIPSELECT,
    input  wire        CLOCK,
    input  wire        STANDBY,
    input  wire        SLEEP,
    input  wire        POWEROFF,
    output reg  [15:0] DATAOUT
);
    reg [15:0] mem [0:16383];
    always @(posedge CLOCK) begin
        if (CHIPSELECT) begin
            if (WREN) begin
                if (MASKWREN[0]) mem[ADDRESS][3:0]   <= DATAIN[3:0];
                if (MASKWREN[1]) mem[ADDRESS][7:4]   <= DATAIN[7:4];
                if (MASKWREN[2]) mem[ADDRESS][11:8]  <= DATAIN[11:8];
                if (MASKWREN[3]) mem[ADDRESS][15:12] <= DATAIN[15:12];
            end
            DATAOUT <= mem[ADDRESS];
        end
    end
endmodule
`endif

