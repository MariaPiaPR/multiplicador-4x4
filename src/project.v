/*
 * Multiplicador 4x4 de arreglo (array multiplier) - nivel compuerta
 *
 *   A = ui_in[3:0]   (multiplicando, 4 bits)
 *   B = ui_in[7:4]   (multiplicador, 4 bits)
 *   P = uo_out[7:0]  (producto A*B, 8 bits)
 *
 * 16 compuertas AND (productos parciales) + 12 sumadores completos
 * organizados en 3 sumadores ripple-carry de 4 bits (u_fila1..u_fila3).
 *
 * Registros con flip-flops D (16 FF en total), los datos se desplazan
 * una etapa en cada flanco de subida de clk:
 *
 *   ui_in --> [u_reg_in: 8 FF] --> multiplicador --> [u_reg_out: 8 FF] --> uo_out
 *
 * Latencia: el producto aparece en uo_out 2 ciclos de reloj después de
 * colocar A y B en ui_in. rst_n = 0 pone ambos registros en cero.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_multiplicador_4x4 (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // IOs bidireccionales: entrada (no usadas)
    output wire [7:0] uio_out,  // IOs bidireccionales: salida (no usadas)
    output wire [7:0] uio_oe,   // IOs bidireccionales: habilitación (0 = entrada)
    input  wire       ena,      // siempre 1 cuando el diseño está activo
    input  wire       clk,      // reloj
    input  wire       rst_n     // reset síncrono activo en bajo
);

  // ---------------- Registro de entrada (8 FF) ----------------
  wire [7:0] ui_reg;
  register_8 u_reg_in (
      .clk  (clk),
      .rst_n(rst_n),
      .d    (ui_in),
      .q    (ui_reg)
  );

  wire [3:0] a = ui_reg[3:0];
  wire [3:0] b = ui_reg[7:4];

  // ---------------- Productos parciales (16 AND) ----------------
  // ppK[i] = a[i] AND b[K]
  wire [3:0] pp0 = a & {4{b[0]}};
  wire [3:0] pp1 = a & {4{b[1]}};
  wire [3:0] pp2 = a & {4{b[2]}};
  wire [3:0] pp3 = a & {4{b[3]}};

  // ---------------- Fila 1 ----------------
  // a = {0, a3b0, a2b0, a1b0}   b = {a3b1, a2b1, a1b1, a0b1}
  wire [3:0] s1;
  wire       c4_1;
  ripple_carry_4 u_fila1 (
      .a ({1'b0, pp0[3:1]}),
      .b (pp1),
      .ci(1'b0),
      .s (s1),
      .co(c4_1)
  );

  // ---------------- Fila 2 ----------------
  // a = {c4 de fila 1, s1[3:1]}  b = {a3b2, a2b2, a1b2, a0b2}
  wire [3:0] s2;
  wire       c4_2;
  ripple_carry_4 u_fila2 (
      .a ({c4_1, s1[3:1]}),
      .b (pp2),
      .ci(1'b0),
      .s (s2),
      .co(c4_2)
  );

  // ---------------- Fila 3 ----------------
  // a = {c4 de fila 2, s2[3:1]}  b = {a3b3, a2b3, a1b3, a0b3}
  wire [3:0] s3;
  wire       c4_3;
  ripple_carry_4 u_fila3 (
      .a ({c4_2, s2[3:1]}),
      .b (pp3),
      .ci(1'b0),
      .s (s3),
      .co(c4_3)
  );

  // ---------------- Producto ----------------
  wire [7:0] p;
  assign p[0]   = pp0[0];  // p0 = a0b0
  assign p[1]   = s1[0];   // p1
  assign p[2]   = s2[0];   // p2
  assign p[6:3] = s3;      // p3..p6
  assign p[7]   = c4_3;    // p7

  // ---------------- Registro de salida (8 FF) ----------------
  register_8 u_reg_out (
      .clk  (clk),
      .rst_n(rst_n),
      .d    (p),
      .q    (uo_out)
  );

  // ---------------- IOs no usadas ----------------
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  // Evita advertencias por entradas sin uso
  wire _unused = &{ena, uio_in, 1'b0};

endmodule
