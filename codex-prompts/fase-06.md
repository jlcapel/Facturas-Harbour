# FASE 6 — i18n: ModelosAeatView, EmpresaView, ValidacionView, ViesView

Lee antes: `reglas-base.md`, `heredado-05.md`.

## OBJETIVO
Externalizar textos duros en:

1. `src/views/ModelosAeatView.prg`
2. `src/views/EmpresaView.prg`
3. `src/views/ValidacionView.prg`
4. `src/views/ViesView.prg`

## PUNTOS ESPECIALES

### ModelosAeatView
- Botones de modelos: `BUTTON "Modelo 390 - IVA Resumen Anual"` → claves `Modelo390Title` ya existen; reutilizar TODOS los títulos de modelos (`Modelo303Title`, `Modelo390Title`, `Modelo130Title`, `Modelo347Title`, `Modelo111Title`, `Modelo115Title`, `Modelo349Title`) en los botones.
- `SAY "Modelos AEAT - Seleccione modelo:"` → `ModeloAeatSubtitle` (existe).
- `BUTTON "Abrir Carpeta"` → `CommonAbrirCarpeta` (existe).
- `BUTTON "Verificar Cadena"` → crear `ModelosAeatVerificarCadena`.
- `hwg_MsgInfo` en `VerificarCadenaUI` y `GenerarModeloAeat` (crear claves `ModelosAeatRegistros`, `ModelosAeatEventos`, `ModelosAeatIntegro`, `ModelosAeatCorrupto`, `ModelosAeatMsgNoDatos`, `ModelosAeatResultado`).

### EmpresaView
- Combos con items duros: `{"Producción", "Pruebas"}` → claves `EmpresaEntornoPre`/`EmpresaEntornoPro` (existen).
- `BUTTON "Aplicar"` → `CommonAplicar` (crear).
- Cualquier título de GROUPBOX: ya usa `L(...)` correctamente (verificar).
- `hwg_MsgInfo(L("CommonGuardado"), L(...))` ya OK; revisar que no queden `"Aviso"` o `"Error"` duros.

### ValidacionView / ViesView
- Textos de botones (Comprobar NIF, Consultar, etc.) — buscar claves existentes en `Validation*`.
- Los mensajes de resultado ya usan `L("ValidationVies...")` en la mayoría; revisar.
- `hwg_MsgInfo(...)` con títulos duros.

## REGLAS
- Reutilizar claves ya existentes SIEMPRE antes de crear nuevas.
- Solo reemplazo de texto; no cambiar tamaño ni posición de controles.
- Añadir claves nuevas a los 5 idiomas.

## VALIDACIÓN
- `./build.sh` OK.
- `grep -nE 'BUTTON "|SAY "|MsgInfo\("|MsgYesNo\("|TITLE "'` en `ModelosAeatView.prg`, `EmpresaView.prg`, `ValidacionView.prg`, `ViesView.prg` → vacío de textos literales al traducir (los objetos `ITEMS {1,2,3,4}` son valid).
- Comprobar en EmpresaView que el combo de idioma no quede hardcoded: `aIdiomas := {L("LangEspanol"), L("LangEnglish"), ...}` (ya lo está).

## SALIDA
`heredado-06.md`: claves nuevas/reutilizadas por vista, cualquier desvío, resultados grep del paso anterior.