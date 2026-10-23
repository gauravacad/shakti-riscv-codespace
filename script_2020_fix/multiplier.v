`timescale 1ns/1ps

module multiplier #(
    parameter WIDTH = 32,
    parameter STAGES = 4
)(
    input  wire                 CLK,
    input  wire [WIDTH-1:0]     A,
    input  wire [WIDTH-1:0]     B,
    output wire [(2*WIDTH)-1:0] P
);
    // Pipelined multiplier model (matches MULSTAGES=4 in core_config.inc)
    reg [(2*WIDTH)-1:0] pipe [0:STAGES-1];
    integer i;

    always @(posedge CLK) begin
        pipe[0] <= A * B;
        for (i = 1; i < STAGES; i = i + 1) begin
            pipe[i] <= pipe[i-1];
        end
    end

    assign P = pipe[STAGES-1];

endmodule
