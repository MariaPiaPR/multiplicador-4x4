# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

LATENCY = 2  # input register + output register


@cocotb.test()
async def test_reset(dut):
    """While rst_n = 0 the registers must be cleared."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0xFF
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)
    await FallingEdge(dut.clk)
    assert int(dut.uo_out.value) == 0, "Output is not 0 during reset"


@cocotb.test()
async def test_multiplier_exhaustive(dut):
    """Check all 256 combinations; the product appears 2 cycles later."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # A new input every cycle: checks that data shifts correctly
    # through the registers (pipelined operation).
    inputs = [(a, b) for b in range(16) for a in range(16)]
    history = []
    for cycle in range(len(inputs) + LATENCY):
        await FallingEdge(dut.clk)
        if cycle >= LATENCY:
            a, b = history[cycle - LATENCY]
            p = int(dut.uo_out.value)
            assert p == a * b, f"{a} x {b}: expected {a*b}, got {p}"
        if cycle < len(inputs):
            a, b = inputs[cycle]
            dut.ui_in.value = (b << 4) | a
            history.append((a, b))

    dut._log.info("All 256 combinations are correct (2-cycle latency)")
