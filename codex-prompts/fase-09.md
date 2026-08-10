# FASE 9 — main.prg: bienvenida centrada + redimensionable + tema

Lee antes: `reglas-base.md`, `heredado-08.md`.

## OBJETIVO
Modernizar `src/main.prg` la ventana principal:

1. Hacer la ventana REDIMENSIONABLE: `STYLE WS_DLGFRAME + WS_SYSMENU + WS_SIZEBOX + DS_CENTER`; `SIZE 900, 560`.
2. Usar el tema de fase 8 (`ColorAcento()`, `ColorSubtexto()`, `FuenteTitulo(20)`, `FuenteTexto(18)`) en la zona de bienvenida.
3. CENTRAR los textos de bienvenida reales al ancho de la ventana (no coordenadas fijas X=190/130):
   - Usa la función `hwg_TextWidth(oFont, cText)` si existe (busca en código del repo o en HWGUI) para calcular centrado: `nX := (nW - hwg_TextWidth(...)) / 2`.
   - Si no hay tal función, calcula aproximado con `(nW - Len(cText) * nCaracterWidth) / 2` (ancho estimado por carácter ≈ 8.2 px para texto normal; busca patrón ya usado en el repo o `hwg_GETTEXTWIDTH`).
   - El título "Facturas - VERI*FACTU" con `FuenteTitulo` y centrado; el subtítulo ("Seleccione una opción...") con `FuenteTexto` y centrado, a unos 30px debajo del título.
4. Posición de bienvenida: centro alto de la ventana (X centrado de X, Y ≈ 40% de nH).
5. No cambiar el menú ni `AbrirVista` (ya están bien; solo tenían las claves arregladas en fase 1 - no romper).

## DETALLES
- `PREPARE FONT` global del título actual puede eliminarse o sustituirse por el helper del tema.
- El `ADD STATUS TO oDlg PARTS 400, 200` se mantiene (se implementará en fase 14).
- Mantener `Termida`: al cerrar set `s_Db := NIL`.

## VALIDACIÓN
- `./build.sh` OK.
- Inspecciona visualmente con `grep`: los 2 SAY de bienvenida deben usar centrado con cálculo.

## SALIDA
`heredado-09.md`: funciones del tema usadas, método de centrado elegido (con la fórmula), coordenadas resultantes, comparación antes/después.