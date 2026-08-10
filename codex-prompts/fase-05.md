# FASE 5 — i18n: GastosView, GastoEditView, ProveedoresView, CategoriasGastoView, BienesInversionView

Lee antes: `reglas-base.md`, `heredado-04.md`.

## OBJETIVO
Externalizar textos duros en:

1. `src/views/GastosView.prg`
2. `src/views/GastoEditView.prg`
3. `src/views/ProveedoresView.prg`
4. `src/views/CategoriasGastoView.prg`
5. `src/views/BienesInversionView.prg`

## PATRÓN DE TRABAJO (igual a fase 3/4)
- Buscar: `TITLE "`, `SAY "`, `BUTTON "`, `GET "`, `hwg_MsgInfo("`, `hwg_MsgYesNo("`.
- Reutilizar claves existentes de `strings_es.prg` cuando el texto encaje (revisar `Gastos*`, `GastoEdit*`, `Proveedores*`, `Categorias*`, `Bienes*`, `Common*`).
- Crear claves nuevas con el estándar: `<Entidad><Sufijo>` (ej. `GastosMsgSeleccione`, `GastoEditMsgGuardarError`).
- Especial atención:
  - `GastosView`: botones `MsgInfo`, estados `Pagado/No pagado` (crear `GastosPagadoSi/No` o reutilizar `CommonSi/No`), exportación CSV.
  - `GastoEditView`: edades/formulario completo; la vista tiene un CHECKBOX `oChkPagado` (usa `CAPTION L(...)`), etiquetas de totales.
  - `ProveedoresView`: igual patrón que Clientes (reutilizar claves de Clientes si coinciden: `ClientesNombre`, `ClientesNif`… mejor crear alias `ProveedoresNombre` etc. si no existen; no romper claves de clientes).**Decisión**: si ya existe `ClientesNombre` y el texto es idéntico, reutilízala SOLO si la vista Proveedores no va a heredar cambios; lo más limpio: crear duplicados `Proveedores*` aunque el texto coincida (mañana pueden divergir). Elige duplicar para independencia.
  - `BienesInversionView`: col gaps y estado `EnUso/DeBaja` (crear `BienesEnUso`/`BienesDeBaja`).

## REGLAS
- Las 5 vistas no tocan lógica de negocios: SOLO reemplazos de cadena.
- Añadir todas las claves nuevas a los 5 archivos de idioma, traducidas.
- `./build.sh` OK al final.

## SALIDA
`heredado-05.md`: lista de claves nuevas por vista, claves reutilizadas, cualquier duda de traducción.