# Fase 06 — Tipos de identificación

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-05.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `TiposIdentificacionView.prg`, incluido sus dos modales.

## Ficheros permitidos

- `src/views/TiposIdentificacionView.prg`
- `codex-prompts/linea-visual/contexto-06.md`

## Acciones exactas

1. Añade el título `L("IdentifTitle")`. Recoloca Nuevo `nX+20,w=100` primario, Editar `nX+130,w=90` neutro, Eliminar `nX+230,w=100` peligro y PDF `nX+nW-100,w=80` neutro en la barra del patrón; el browse ocupa el rectángulo del patrón.
2. En `TipoIdentNuevo()` y `TipoIdentEditar()`, fija `SIZE 540,220`; Código usa fila 24 y Nombre fila 62 con etiqueta `x=24,w=150` y campo `x=184` conservando sus anchos. Guardar `x=270,y=160,w=100` primario; Cancelar `x=380,y=160,w=110` neutro.
3. Aplica sólo los recursos de `patron-ui.md`; no cambies columnas, bloques, validaciones, modales, servicios ni claves.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-06.md` con el formato obligatorio. `Siguiente fase permitida: fase-07.md`.
