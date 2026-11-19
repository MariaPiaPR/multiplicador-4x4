/*
 * D flip-flop with active-low synchronous reset.
 * On every rising edge of clk: q <= d (or 0 when rst_n = 0).
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
