`timescale 1ns / 1ps
/*
 * Standalone Verilog testbench (no cocotb).
 *   iverilog -o sim test/tb_simple.v src/full_adder.v src/ripple_carry_4.v src/d_ff.v src/register_8.v src/project.v
 *   vvp sim
 *
 * Applies A and B, waits 2 clock edges (input and output registers)
 * and compares uo_out with A*B.
 */
module tb_simple;
  reg        clk = 0, rst_n = 0;
  reg  [7:0] ui_in = 0;
  wire [7:0] uo_out, uio_out, uio_oe;
  integer a, b, errors;

  always #5 clk = ~clk;  // 100 MHz clock in simulation

  tt_um_multiplier_4x4 dut (
      .ui_in(ui_in), .uo_out(uo_out), .uio_in(8'b0), .uio_out(uio_out),
      .uio_oe(uio_oe), .ena(1'b1), .clk(clk), .rst_n(rst_n));

  initial begin
    $dumpfile("tb_simple.vcd");
    $dumpvars(0, tb_simple);
    errors = 0;
    ui_in = 8'hFF;
    repeat (3) @(posedge clk);
    #1 if (uo_out !== 8'd0) begin
      $display("ERROR: output is not 0 during reset");
      errors = errors + 1;
    end
    rst_n = 1;

    for (b = 0; b < 16; b = b + 1)
      for (a = 0; a < 16; a = a + 1) begin
        ui_in = {b[3:0], a[3:0]};
        repeat (2) @(posedge clk);
        #1;
        if (uo_out !== a * b) begin
          $display("ERROR: %0d x %0d = %0d (expected %0d)", a, b, uo_out, a * b);
          errors = errors + 1;
        end
      end
    if (errors == 0) $display("PASS: reset and all 256 combinations are correct");
    else             $display("FAIL: %0d errors", errors);
    $finish;
  end
endmodule
