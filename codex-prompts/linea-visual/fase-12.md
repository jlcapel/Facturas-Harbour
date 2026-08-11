# Fase 12 — Listado de facturas

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-11.md`.

## Objetivo único

Aplicar el patrón cerrado sólo al listado de `FacturasView.prg`.

## Ficheros permitidos

- `src/views/FacturasView.prg`
- `codex-prompts/linea-visual/contexto-12.md`

## Acciones exactas

1. Añade el título `L("FacturasTitle")` y el browse del patrón. No cambies sus columnas, datos, selección ni callbacks.
2. Recoloca las cuatro acciones existentes en la barra superior: Nueva `x=nX+20,w=100` primario; Subsanar `nX+130,w=100` neutro; Imprimir `nX+240,w=100` neutro; Anular `nX+350,w=100` peligro. Todas tienen altura 30 y el mismo bloque `ON CLICK` que ya existe.
3. Aplica únicamente recursos de `patron-ui.md`. No añadas ver, rectificar, reenviar, filtros, columnas, exportaciones ni acciones del proyecto .NET que no existan en Harbour.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-12.md` con el formato obligatorio. `Siguiente fase permitida: fase-13.md`.
