# FASE 4 — i18n: FacturasView + FacturaEditView

Lee antes: `reglas-base.md`, `heredado-03.md`.

## OBJETIVO
Externalizar textos duros en:

1. `src/views/FacturasView.prg`
2. `src/views/FacturaEditView.prg`

## CATEGORÍAS (ya detectadas)
- `FacturasView.prg`: `BUTTON "Nueva"` (existe `FacturasNueva`), `hwg_MsgInfo("Seleccione una factura","Aviso")`, `hwg_MsgInfo("PDF generado: " + ...)`, `hwg_MsgYesNo("¿Anular " + ... + "?","Confirmar")`, columna estado `"Emitida"/"Anulada"` (crear `FacturasEstadoEmitida`/`FacturasEstadoAnulada`).
- `FacturaEditView.prg`: `TITLE "Editar Factura"`, `SAY "Cliente:"` (existe `FacturasCliente`), `SAY "Tipo:"` (existe `FacturasTipoFactura`), `GROUPBOX "Líneas"` (crear `FacturaEditLineas`), botones `"Añadir"/"Quitar"` (crear `FacturaEditAnadirLinea`/`FacturaEditQuitarLinea` o reusar `FacturasAnadirLinea`), columnas BROWSE `"Cant."/`"IVA%"` (crear `FacturaEditCantHead`/`FacturaEditIvaPctHead`), `SAY "IRPF (...%)"` (clave con formato, ver `PdfRetIrpf` — reutilizar), strings `hwg_MsgInfo(...)`.

## REGLAS
- Reutilizar claves ya existentes (revisa `strings_es.prg` primero: `FacturasNumFactura`, `FacturasFecha`, `FacturasCliente`, `FacturasTipoFactura`, `FacturasLineasFactura` ya existen).
- Los mensajes con concatenación de datos (`"¿Anular " + cNum + "?"`) → definir claves con placeholder `{1}` estilo `.NET` (`FacturasMsgAnular := "¿Anular {1}?"` y usar `StrTran(StrTran(clave,"{1}",cNum),...` ), o sustituir manualmente. El proyecto ya usa `{0}` en varias (`FacturasCsvPrefix`). Mantén ese estilo.
- NO cambiar lógica ni estructura de diálogos (coordenadas, tamaños, handlers).
- Las claves nuevas van a los 5 idiomas.

## VALIDACIÓN
- `grep -n 'hwg_'` en las dos vistas → solo llamadas con `L()` (salvo llamadas de conformidad técnica como `Close`).
- `grep -nE 'TITLE "|SAY "|BUTTON "|GET "|MsgInfo\("|MsgYesNo\("'` → 0 resultados en ambas vistas.
- `./build.sh` OK.

## SALIDA
`heredado-04.md`: claves nuevas y reutilizadas, modificadas, estados (`Facturas/FiguraEdit`), pendientes.