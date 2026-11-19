# Multiplicador 4×4 de arreglo — IEEE Open Silicon Bootcamp 2026

Circuito integrado digital: multiplicador combinacional de 4×4 bits
(8 bits de entrada, 8 bits de salida), descrito en Verilog a nivel estructural.

| Señal          | Función                    |
|----------------|----------------------------|
| `ui_in[3:0]`   | A (multiplicando)          |
| `ui_in[7:4]`   | B (multiplicador)          |
| `uo_out[7:0]`  | P = A × B                  |

## Estructura del repositorio

```
src/project.v         Módulo principal tt_um_multiplicador_4x4 (16 AND + 3 filas)
src/ripple_carry_4.v  Sumador ripple-carry de 4 bits (una fila)
src/full_adder.v      Sumador completo de 1 bit
test/test.py          Prueba cocotb exhaustiva (256 combinaciones)
test/tb.v             Envoltura para cocotb
test/tb_simple.v      Testbench Verilog puro (sin Python)
docs/info.md          Documentación del proyecto
info.yaml             Configuración del proyecto (pines, módulo top, archivos)
```

## Simulación

Con Icarus Verilog únicamente:

```bash
iverilog -o sim test/tb_simple.v src/full_adder.v src/ripple_carry_4.v src/project.v
vvp sim
```

Con cocotb:

```bash
cd test && make
```

Ver `docs/info.md` para la descripción detallada del circuito.
