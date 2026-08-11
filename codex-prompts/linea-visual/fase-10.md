# Fase 10 — Artículos

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-09.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `ArticulosView.prg`, incluido su modal.

## Ficheros permitidos

- `src/views/ArticulosView.prg`
- `codex-prompts/linea-visual/contexto-10.md`

## Acciones exactas

1. Añade el título `L("ArticulosTitle")`. Recoloca Nuevo `nX+20,w=100` primario, Editar `nX+130,w=90` neutro, Eliminar `nX+230,w=100` peligro y PDF `nX+nW-100,w=80` neutro. El browse usa el patrón y no altera sus columnas.
2. En `ArticuloEditDialog()`, fija `SIZE 560,340`. Código, Descripción, Precio, Unidad y Tipo IVA ocupan filas 24,62,100,138,176; etiquetas `x=24,w=150`, campos `x=184` y sus anchos actuales. Mantén `PICTURE`, combo y binding literalmente.
3. Guardar queda `x=320,y=280,w=100` primario y Cancelar `x=430,y=280,w=110` neutro. No modifiques ninguna llamada ni validación.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-10.md` con el formato obligatorio. `Siguiente fase permitida: fase-11.md`.
