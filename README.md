# 4×4 Array Multiplier — IEEE Open Silicon Bootcamp 2026

Digital integrated circuit: 4×4-bit multiplier (8 input bits, 8 output bits),
described in structural Verilog, with D flip-flop registers at the input and
the output (2-cycle latency).

| Signal         | Function                         |
|----------------|----------------------------------|
| `ui_in[3:0]`   | A (multiplicand)                 |
| `ui_in[7:4]`   | B (multiplier)                   |
| `uo_out[7:0]`  | P = A × B (2 cycles later)       |
| `clk`          | Flip-flop clock                  |
| `rst_n`        | Synchronous reset, active low    |

## Repository layout

```
src/project.v         Top module tt_um_multiplier_4x4 (registers + 16 AND + 3 rows)
src/register_8.v      8-bit register (8 D flip-flops)
src/d_ff.v            D flip-flop with synchronous reset
src/ripple_carry_4.v  4-bit ripple-carry adder (one row)
src/full_adder.v      1-bit full adder
test/test.py          cocotb test: reset + all 256 combinations with clock
test/tb.v             cocotb wrapper
test/tb_simple.v      Plain Verilog testbench (no Python)
docs/info.md          Project documentation
info.yaml             Project configuration (pins, top module, source files)
```

## Simulation

With Icarus Verilog only:

```bash
iverilog -o sim test/tb_simple.v src/full_adder.v src/ripple_carry_4.v src/d_ff.v src/register_8.v src/project.v
vvp sim
```

With cocotb:

```bash
cd test && make
```

See `docs/info.md` for a detailed description of the circuit.
