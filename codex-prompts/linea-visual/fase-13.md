# Fase 13 — Listado de gastos

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-12.md`.

## Objetivo único

Aplicar el patrón cerrado sólo al listado de `GastosView.prg`.

## Ficheros permitidos

- `src/views/GastosView.prg`
- `codex-prompts/linea-visual/contexto-13.md`

## Acciones exactas

1. Añade el título `L("GastosTitle")` y el browse del patrón. Mantén las columnas, datos, selección, pago y callbacks literales.
2. Recoloca las acciones: Nuevo `x=nX+20,w=100` primario; Editar `nX+130,w=90` neutro; Eliminar `nX+230,w=100` peligro; Pagado/No `nX+340,w=120` neutro; PDF `nX+nW-100,w=80` neutro. Todas quedan en `y=nY+58`, alto 30.
3. Aplica sólo recursos de `patron-ui.md`. No añadas filtros, años, exportación CSV ni acciones nuevas.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-13.md` con el formato obligatorio. `Siguiente fase permitida: fase-14.md`.
