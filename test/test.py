# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

LATENCIA = 2  # registro de entrada + registro de salida


@cocotb.test()
async def test_reset(dut):
    """Con rst_n = 0 los registros deben quedar en cero."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0xFF
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)
    await FallingEdge(dut.clk)
    assert int(dut.uo_out.value) == 0, "La salida no es 0 durante el reset"


@cocotb.test()
async def test_multiplicador_exhaustivo(dut):
    """Prueba las 256 combinaciones; el producto sale 2 ciclos después."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # Un dato nuevo en cada ciclo: se comprueba que los datos se
    # desplazan correctamente por los registros (modo pipeline).
    entradas = [(a, b) for b in range(16) for a in range(16)]
    historial = []
    for ciclo in range(len(entradas) + LATENCIA):
        await FallingEdge(dut.clk)
        if ciclo >= LATENCIA:
            a, b = historial[ciclo - LATENCIA]
            p = int(dut.uo_out.value)
            assert p == a * b, f"{a} x {b}: esperado {a*b}, obtenido {p}"
        if ciclo < len(entradas):
            a, b = entradas[ciclo]
            dut.ui_in.value = (b << 4) | a
            historial.append((a, b))

    dut._log.info("Las 256 combinaciones son correctas (latencia 2 ciclos)")
