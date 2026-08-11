# Fase 15 — Editor de gasto

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-14.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `GastoEditView.prg`.

## Ficheros permitidos

- `src/views/GastoEditView.prg`
- `codex-prompts/linea-visual/contexto-15.md`

## Acciones exactas

1. Conserva `SIZE 720,520`, todos los controles y sus coordenadas. Añade fuentes y colores de `patron-ui.md` a cada etiqueta, campo, combo, checkbox, groupbox y botón; el browse no existe en esta vista.
2. Conserva los importes, `PICTURE`, combos, `lPagado`, IVA deducible y todos los bindings literalmente. No añadas ni muestres la fecha de operación: su ausencia actual no se corrige en esta fase visual.
3. Cambia sólo acciones: Guardar `x=510,y=460,w=100,h=30` primario; Cancelar `x=620,y=460,w=90,h=30` neutro. Mantén los bloques `ON CLICK` completos sin tocar.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-15.md` con el formato obligatorio. `Siguiente fase permitida: fase-16.md`.
