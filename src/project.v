/*
 * 4x4 array multiplier - gate level
 *
 *   A = ui_in[3:0]   (multiplicand, 4 bits)
 *   B = ui_in[7:4]   (multiplier, 4 bits)
 *   P = uo_out[7:0]  (product A*B, 8 bits)
 *
 * 16 AND gates (partial products) + 12 full adders arranged as
 * 3 4-bit ripple-carry adders (u_row1..u_row3).
 *
 * D flip-flop registers (16 FFs in total); data shifts one stage
 * on every rising edge of clk:
 *
 *   ui_in --> [u_reg_in: 8 FF] --> multiplier --> [u_reg_out: 8 FF] --> uo_out
 *
 * Latency: the product appears on uo_out 2 clock cycles after A and B
 * are applied to ui_in. rst_n = 0 clears both registers.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_multiplier_4x4 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // Bidirectional IOs: input (unused)
    output wire [7:0] uio_out,  // Bidirectional IOs: output (unused)
    output wire [7:0] uio_oe,   // Bidirectional IOs: enable (0 = input)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // active-low synchronous reset
);

  // ---------------- Input register (8 FF) ----------------
  wire [7:0] ui_reg;
  register_8 u_reg_in (
      .clk  (clk),
      .rst_n(rst_n),
      .d    (ui_in),
      .q    (ui_reg)
  );

  wire [3:0] a = ui_reg[3:0];
  wire [3:0] b = ui_reg[7:4];

  // ---------------- Partial products (16 AND) ----------------
  // ppK[i] = a[i] AND b[K]
  wire [3:0] pp0 = a & {4{b[0]}};
  wire [3:0] pp1 = a & {4{b[1]}};
  wire [3:0] pp2 = a & {4{b[2]}};
  wire [3:0] pp3 = a & {4{b[3]}};

  // ---------------- Row 1 ----------------
  // a = {0, a3b0, a2b0, a1b0}   b = {a3b1, a2b1, a1b1, a0b1}
  wire [3:0] s1;
  wire       c4_1;
  ripple_carry_4 u_row1 (
      .a ({1'b0, pp0[3:1]}),
      .b (pp1),
      .ci(1'b0),
      .s (s1),
      .co(c4_1)
  );

  // ---------------- Row 2 ----------------
  // a = {c4 from row 1, s1[3:1]}  b = {a3b2, a2b2, a1b2, a0b2}
  wire [3:0] s2;
  wire       c4_2;
  ripple_carry_4 u_row2 (
      .a ({c4_1, s1[3:1]}),
      .b (pp2),
      .ci(1'b0),
      .s (s2),
      .co(c4_2)
  );

  // ---------------- Row 3 ----------------
  // a = {c4 from row 2, s2[3:1]}  b = {a3b3, a2b3, a1b3, a0b3}
  wire [3:0] s3;
  wire       c4_3;
  ripple_carry_4 u_row3 (
      .a ({c4_2, s2[3:1]}),
      .b (pp3),
      .ci(1'b0),
      .s (s3),
      .co(c4_3)
  );

  // ---------------- Product ----------------
  wire [7:0] p;
  assign p[0]   = pp0[0];  // p0 = a0b0
  assign p[1]   = s1[0];   // p1
  assign p[2]   = s2[0];   // p2
  assign p[6:3] = s3;      // p3..p6
  assign p[7]   = c4_3;    // p7

  // ---------------- Output register (8 FF) ----------------
  register_8 u_reg_out (
      .clk  (clk),
      .rst_n(rst_n),
      .d    (p),
      .q    (uo_out)
  );

  // ---------------- Unused IOs ----------------
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  // Avoid unused-input warnings
  wire _unused = &{ena, uio_in, 1'b0};

endmodule
