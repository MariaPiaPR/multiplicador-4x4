`timescale 1ns / 1ps
/*
 * Testbench Verilog independiente (sin cocotb).
 *   iverilog -o sim test/tb_simple.v src/full_adder.v src/ripple_carry_4.v src/project.v
 */
module tb_simple;
  reg  [7:0] ui_in;
  wire [7:0] uo_out, uio_out, uio_oe;
  integer a, b, errores;

  tt_um_multiplicador_4x4 dut (
      .ui_in(ui_in), .uo_out(uo_out), .uio_in(8'b0), .uio_out(uio_out),
      .uio_oe(uio_oe), .ena(1'b1), .clk(1'b0), .rst_n(1'b1));

  initial begin
    errores = 0;
    for (b = 0; b < 16; b = b + 1)
      for (a = 0; a < 16; a = a + 1) begin
        ui_in = {b[3:0], a[3:0]};
        #10;
        if (uo_out !== a * b) begin
          $display("ERROR: %0d x %0d = %0d (esperado %0d)", a, b, uo_out, a * b);
          errores = errores + 1;
        end
      end
    if (errores == 0) $display("OK: las 256 combinaciones son correctas");
    else              $display("FALLO: %0d errores", errores);
    $finish;
  end
endmodule
