## Cómo funciona

Multiplicador combinacional de 4×4 bits tipo **arreglo (array multiplier)**.

- **A** = `ui_in[3:0]` (multiplicando), **B** = `ui_in[7:4]` (multiplicador)
- **P** = `uo_out[7:0]` = A × B (0 a 225)

Estructura a nivel compuerta:

1. **16 compuertas AND** generan los productos parciales `a[i] AND b[j]`.
2. **3 sumadores ripple-carry de 4 bits** (`u_fila1`, `u_fila2`, `u_fila3`), cada uno con
   4 sumadores completos (`fa0`–`fa3`), suman los productos parciales fila por fila.
   - Fila 1: suma `{0, a3b0, a2b0, a1b0}` + `{a3b1, a2b1, a1b1, a0b1}`
   - Fila 2: suma `{c4, s3, s2, s1}` de la fila 1 + productos con `b2`
   - Fila 3: suma `{c4, s3, s2, s1}` de la fila 2 + productos con `b3`
3. Salidas: `p0 = a0b0`, `p1` = s0 de fila 1, `p2` = s0 de fila 2,
   `p3..p6` = s0..s3 de fila 3 y `p7` = acarreo final de fila 3.

No usa reloj ni reset.

## Cómo probarlo

Coloca A en los interruptores `ui_in[3:0]` y B en `ui_in[7:4]`; el producto aparece en `uo_out[7:0]`.

| A (ui_in[3:0]) | B (ui_in[7:4]) | ui_in      | uo_out (P)       |
|----------------|----------------|------------|------------------|
| 3              | 5              | `01010011` | `00001111` (15)  |
| 15             | 15             | `11111111` | `11100001` (225) |
| 7              | 2              | `00100111` | `00001110` (14)  |

## Hardware externo

Ninguno. Solo interruptores (DIP) para las entradas y LEDs para observar las salidas.
