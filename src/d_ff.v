/*
 * Flip-flop tipo D con reset síncrono activo en bajo.
 * En cada flanco de subida de clk: q <= d (o 0 si rst_n = 0).
 */
`default_nettype none

module d_ff (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);
  always @(posedge clk) begin
    if (!rst_n) q <= 1'b0;
    else        q <= d;
  end
endmodule
