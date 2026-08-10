# FASE 3 — i18n: externalizar strings duros en vistas de maestros (5)

Lee antes: `reglas-base.md`, `heredado-02.md`.

## OBJETIVO
Eliminar todos los strings hardcoded en español de estas 5 vistas, sustituyéndolos por `L("Clave")` (creando las claves necesarias en los 5 archivos de strings):

1. `src/views/PaisesView.prg`
2. `src/views/TiposIvaView.prg`
3. `src/views/TiposIdentificacionView.prg`
4. `src/views/ClientesView.prg`
5. `src/views/ArticulosView.prg`

## CATEGORÍAS A SUSTITUIR
- `TITLE "..."` de diálogos (ej. "Nuevo país", "Editar país", "Editar cliente"...). Usa claves nuevas tipo `<Entidad>TitleNuevo`/`<Entidad>TitleEditar` si no existen.
- `hwg_MsgInfo("...", "Aviso")` / `hwg_MsgYesNo("...", "Confirmar")` → clave nueva tipo `<Entidad>Msg...` + `CommonWarning`/`CommonConfirmar`.
- `SAY "..."` hardcodeado, `GET` con placeholder, `BUTTON "..."` — revisar si la clave existe (`CommonGuardar`, `PaisesNuevo`, `TiposIvaEditar`, etc.), si no crear.
- Cualquier columna dura de BROWSE ya usa claves existentes (revisar).

## REGLAS DE CLAVES NUEVAS
- Nombrarlas en español normalizado: `PaisesTitleNuevo`, `PaisesTitleEditar`, `PaisesMsgSeleccione`, `CommonWarning`, `CommonInfo`, etc.
- MÍNIMO de claves: reutiliza si ya está el mismo texto en strings_es.
- Las claves nuevas se añaden a los 5 idiomas, traducidas.

## PROCEDIMIENTO
1. Por cada vista, revisa con `grep -n 'TITLE "\|MsgInfo("\|MsgYesNo("\|SAY "'` qué hay hardcoded.
2. Sustituye por `L("...")`.
3. Añade las claves nuevas a `strings_*.prg` y a la lista de este heredado.
4. Verifica que no quedaron `"` duras sin `L()` encadenadas: `grep -n 'hwg_MsgInfo("' archivo` → 0 resultados; `grep -n 'TITLE "'` → 0; `grep -n 'BUTTON "'` → 0 (salvo textos de datos reales tipo nombres de clientes, no traducibles).
5. `./build.sh` OK.

## NOTA
- NO modificar la lógica de las vistas (firma, funciones, eventos).
- En `PaisesView.prg` ya existen claves `PaisesNuevo/PaisesEditar/PaisesEliminar/PaisesVolver`; reutilizarlas.
- Cuidado: `CHECKBOX oChkUE CAPTION L(...)` — tradivo el CAPTION con `L()` como ya está.

## SALIDA
`heredado-03.md`: ficheros, claves nuevas por idioma, nº total añadido, cualquier sustitución con traducción dudosa (márcala para revisión).