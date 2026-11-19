# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_multiplicador_exhaustivo(dut):
    """Prueba las 256 combinaciones de A (ui_in[3:0]) y B (ui_in[7:4])."""
    dut._log.info("Inicio de la prueba")
    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 1
    dut.uio_in.value = 0

    for b in range(16):
        for a in range(16):
            dut.ui_in.value = (b << 4) | a
            await Timer(10, unit="ns")
            p = int(dut.uo_out.value)
            assert p == a * b, f"{a} x {b}: esperado {a*b}, obtenido {p}"

    dut._log.info("Las 256 combinaciones son correctas")
