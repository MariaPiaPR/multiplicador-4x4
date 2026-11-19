`timescale 1ns / 1ps
/*
 * Testbench Verilog independiente (sin cocotb).
 *   iverilog -o sim test/tb_simple.v src/full_adder.v src/ripple_carry_4.v src/d_ff.v src/register_8.v src/project.v
 *
 * Coloca A y B, espera 2 flancos de reloj (registro de entrada y de
 * salida) y compara uo_out con A*B.
 */
module tb_simple;
  reg        clk = 0, rst_n = 0;
  reg  [7:0] ui_in = 0;
  wire [7:0] uo_out, uio_out, uio_oe;
  integer a, b, errores;

  always #5 clk = ~clk;  // reloj de 100 MHz en simulación

  tt_um_multiplicador_4x4 dut (
      .ui_in(ui_in), .uo_out(uo_out), .uio_in(8'b0), .uio_out(uio_out),
      .uio_oe(uio_oe), .ena(1'b1), .clk(clk), .rst_n(rst_n));

  initial begin
    $dumpfile("tb_simple.vcd");
    $dumpvars(0, tb_simple);
    errores = 0;
    ui_in = 8'hFF;
    repeat (3) @(posedge clk);
    #1 if (uo_out !== 8'd0) begin
      $display("ERROR: la salida no es 0 durante el reset");
      errores = errores + 1;
    end
    rst_n = 1;

    for (b = 0; b < 16; b = b + 1)
      for (a = 0; a < 16; a = a + 1) begin
        ui_in = {b[3:0], a[3:0]};
        repeat (2) @(posedge clk);
        #1;
        if (uo_out !== a * b) begin
          $display("ERROR: %0d x %0d = %0d (esperado %0d)", a, b, uo_out, a * b);
          errores = errores + 1;
        end
      end
    if (errores == 0) $display("OK: reset y las 256 combinaciones son correctas");
    else              $display("FALLO: %0d errores", errores);
    $finish;
  end
endmodule
