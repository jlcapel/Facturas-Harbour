# REGLAS GLOBALES (obligatorias en TODAS las fases)

No repitas estas reglas: cada fase las referencia. No preguntes nada: ejecuta.

## Técnicas
1. Sin comentarios en el código (salvo AGENTS.md / ficheros .md).
2. Nombres de variables/funciones/clases en español (dominio del problema).
3. NO inventar funcionalidad: todo se clona del proyecto .NET `~/programacion/Facturas/`. Si no está allí la lógica, no la añadas (esto solo afecta a lógica de negocio; los cambios visuales/i18n sí se pueden realizar).
4. Compilar siempre tras cada cambio: `cd /home/jose/programacion/Facturas-Harbour && ./build.sh` → debe acabar en `OK: ./Facturas`.
5. NO commits, NO push.
6. Modificar SOLO los ficheros listados en la fase.

## HBSQLIT3 (crítico — NO tocar)
- los índices de columna en `sqlite3_column_*` son 1-BASED (nunca usar 0).
- los índices en `sqlite3_bind_*` también 1-based.
- `#include "hbsqlit3.ch"` en todo .prg que use SQLITE_ROW/SQLITE_DONE.

## i18n
- Mecanismo: `L("Clave")` busca en el hash del idioma actual; fallback a español; si no existe devuelve `[[Clave]]`.
- Los ficheros de strings: `src/i18n/strings_{es,en,fr,ca,eu}.prg`, cada uno con `FUNCTION LoadStrings_xxx()` que devuelve `h := {=>}`.
- Las claves DEBEN ser consistentes en los 5 idiomas (misma clave, distinto texto). Mantener orden aproximado de es.
- NUNCA eliminar claves existentes: solo añadir.

## CONVENCIONES DE LA INTERFAZ (HWGUI)
- `@ x, y` con coordenadas absolutas por control; no separar múltiples `@` en la misma línea.
- CHECKBOX: `.CHECKBOX oChk CAPTION "..."` y leer `oChk:Value()` ANTES de `oDlg:Close()`.
- COMBOBOX binding: `@ x,y GET COMBOBOX nVar ITEMS ...` para variar numérica (no `@ x,y COMBOBOX ...` simple).
- Botones estándar: alto 28.
- No inventar claves nuevas sin necesidad: revisar si ya existe una clave equivalente (ej. `CommonGuardar`, `CommonCancelar`, `CommonCerrar`, `PaisesNuevo`, etc.).
- Para mensajes: `hwg_MsgInfo("texto", "Título")` → SIEMPRE por `L()` cuando exista clave, o añadir la clave nueva en TODOS los idiomas.

## FORMATO DEL heredado-N.md (al terminar cada fase)
```
# Heredado fase N
Ficheros modificados: ...
Claves i18n añadidas: ...
Decisiones: ...
Pendiente: ...
Build: OK/ERROR
```
Máximo 25 líneas.