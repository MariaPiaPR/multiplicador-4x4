# Multiplicador 4×4 de arreglo — IEEE Open Silicon Bootcamp 2026

Circuito integrado digital: multiplicador combinacional de 4×4 bits
(8 bits de entrada, 8 bits de salida), descrito en Verilog a nivel estructural,
con registros de flip-flops D en la entrada y la salida (latencia de 2 ciclos).

| Señal          | Función                    |
|----------------|----------------------------|
| `ui_in[3:0]`   | A (multiplicando)          |
| `ui_in[7:4]`   | B (multiplicador)          |
| `uo_out[7:0]`  | P = A × B (2 ciclos después) |
| `clk`          | Reloj de los flip-flops    |
| `rst_n`        | Reset síncrono, activo en bajo |

## Estructura del repositorio

```
src/project.v         Módulo principal tt_um_multiplicador_4x4 (registros + 16 AND + 3 filas)
src/register_8.v      Registro de 8 bits (8 flip-flops D)
src/d_ff.v            Flip-flop D con reset síncrono
src/ripple_carry_4.v  Sumador ripple-carry de 4 bits (una fila)
src/full_adder.v      Sumador completo de 1 bit
test/test.py          Prueba cocotb: reset + 256 combinaciones con reloj
test/tb.v             Envoltura para cocotb
test/tb_simple.v      Testbench Verilog puro (sin Python)
docs/info.md          Documentación del proyecto
info.yaml             Configuración del proyecto (pines, módulo top, archivos)
```

## Simulación

Con Icarus Verilog únicamente:

```bash
iverilog -o sim test/tb_simple.v src/full_adder.v src/ripple_carry_4.v src/d_ff.v src/register_8.v src/project.v
vvp sim
```

Con cocotb:

```bash
cd test && make
```

Ver `docs/info.md` para la descripción detallada del circuito.
