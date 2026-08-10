# FASE 12 — C2: FacturaEditView: alineación de labels y totales

Lee antes: `reglas-base.md`, `heredado-11.md`.

## CONTEXTO
`src/views/FacturaEditView.prg` (modal 780x600, formulario de factura) tiene:
- Labels a X=20 con textos cortos, GETs que empiezan a X=110 (método actual: SAY en X, GET en X+90 o X+130 — desigual).
- Fila de totales a X=500/630 mal alineados con las tarjetas de la linea90 (BROWSE en X=30..660 y botones a X=650).
- Botones Guardar/Cancelar a Y=570 (fijos), centrados a medias.

## OBJETIVO (solo layout)
1. Alinear los pares SAY/GET de la CABECERA a una rejilla uniforme: etiquetas ancho 80 a X=20; campos a X=110 (los actuales a 110/140/340/341 unificar a 130 ó al valor estándar de los demás formularios — check: otros modales usan X=20 labels + X=110 gets, o X=30/120 según `EmpresaView`). Elige la rejilla de EmpresaView (X=30 label, X=120 get) y aplícala a las filas de cabecera.
2. El GROUPBOX "Líneas" (X=20, W=730) y el BROWSE (X=30 W=600) → alinea el BROWSE para que ocupe hasta X=670 (contiguo a los botones Añadir/Quitar a X=650). Ajusta ancho a nW=780 → BROWSE X=30 W=610 y botones column de 70 a X=650/660/680 (o columna vertical 610/690: elige la más coherente).
3. Totales a la derecha dentro de su columna: etiquetas (X=500→590 o alineados a la derecho), valores alineados a la derecha (X=680 W=90). ASOCIADO: unificómo con letras x = 500, 590, 680.
4. Fila de botones Guardar/Cancelar: centrarla al total de la modal: `nBtnW := 90`, `nGap := 30`, `xTotal := (nW - nBtnW*2 - nGap)/2` → `@ xTotal, 570 BUTTON Guardar`, `@ xTotal+nBtnW+nGap, 570 ...`.
5. La columna `Cant.`/`IVA%` pasa a `L()` (de la fase 4 debe estar listo; no repetir).

## REGLAS
- NO cambiar handlers, lógica, cálculos ni la lista de columnas (solo geom ía).
- NO mover el BROWSE fuera del panel.
- `./build.sh` OK si hay sintaxis cambiada.

## VALIDACIÓN
- Comparar coffee/as coordinates vs antes (documenta en salida).
- Comprobar con `grep -cE "@ [0-9]+, " src/views/FacturaEditView.prg` el nº de controles por fila (solo informativo).

## SALIDA
`heredado-12.md`: nueva rejilla (tabla X/Y), totales Y, centrado de botones con fórmula, comprobaciones.