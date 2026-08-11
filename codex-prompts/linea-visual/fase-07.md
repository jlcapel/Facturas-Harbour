# Fase 07 — Categorías de gasto

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-06.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `CategoriasGastoView.prg`, incluido su modal.

## Ficheros permitidos

- `src/views/CategoriasGastoView.prg`
- `codex-prompts/linea-visual/contexto-07.md`

## Acciones exactas

1. Añade el título `L("CategoriasTitle")`. Recoloca Nuevo `nX+20,w=100` primario, Editar `nX+130,w=90` neutro, Eliminar `nX+230,w=100` peligro y PDF `nX+nW-100,w=80` neutro. Aplica el browse del patrón.
2. En `CatEditDialog()`, fija `SIZE 540,260`: Nombre en fila 24 con campo de ancho 320; Deducible en fila 62 con su ancho de campo; checkbox de IVA en `x=184,y=100`. Etiquetas `x=24,w=150`. Guardar `x=270,y=200,w=100` primario y Cancelar `x=380,y=200,w=110` neutro.
3. Conserva el uso compartido del diálogo de nuevo/editar, sus campos, cálculos, guardado y cancelación literalmente.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-07.md` con el formato obligatorio. `Siguiente fase permitida: fase-08.md`.
