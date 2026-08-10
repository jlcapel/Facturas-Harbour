# FASE 13 — C3: ModelosAeatView: grid uniforme de tarjetas

Lee antes: `reglas-base.md`, `heredado-12.md`.

## CONTEXTO
`src/views/ModelosAeatView.prg` (embebida en panel 848x430) tiene:
- 7 botones de modelo en 4 filas, X=20 y X=250 alternando, 220px cada uno, alturas 28.
- Algunos con `L(...)` y otros con texto hardcoded (ya resuelto en fase 6), labels de año/trimestre y 3 botones de acción.
- Fisuras visuales: títulos de botón largos cortados ("Modelo 390 - IVA Restructura Anual" no cabe en 220).

## OBJETIVO (solo layout de la vista)
1. Botones de modelo en GRID uniforme de 2 columnas × 3-4 filas, SAME size 280x32 (más ancho para los rótulos largos), inicio X=30, Y=50, gap X=30, gap Y=34.
2. El bloque de controles añio/trimestre pasa a Y=170 (por debajo de la 4ª fila), alineados en la misma fila (SAY + COMBOBOX).
3. Los 3 botones de acción (Generar / Abrir Carpeta / Verificar Cadena) en una fila final Y=240, espaciado uniforme (X=30/170/310, W=120/110/130 o repartir).
4. El título de la vista ("Modelo AEAT - Seleccione modelo:") mantener con `L()` y con `FuenteTexto()` del tema (no obligatorio: si el tema no gusta, mantener el estándar).

## REGLAS
- NO cambiar handlers ON CLICK, ni funciones `GenerarModeloAeat`/`AbrirCarpetaModelo`/`VerificarCadenaUI`.
- Mantener el panel completo dentro de 850x430 (la vista recibe nW/nH; usa esas variables relativas, no números duros extremos).
- Todos los botones usan `L(...)` a esta altura (verify).

## VALIDACIÓN
- `./build.sh` OK.
- `grep -nE "BUTTON.*SIZE 220, 28" src/views/ModelosAeatView.prg` → eliminado (ahora 220x32).
- Inspección visual (si posible): sin cortar textos.

## SALIDA
`heredado-13.md`: nueva tabla de posiciones (botones modelo, controles, acción), tamaños, decisión sobre fuente del título.