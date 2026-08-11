# Fase 14 — Editor de factura y línea

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-13.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a los dos diálogos de `FacturaEditView.prg`.

## Ficheros permitidos

- `src/views/FacturaEditView.prg`
- `codex-prompts/linea-visual/contexto-14.md`

## Acciones exactas

1. En `FacturaCrearDialog()`, fija sólo `SIZE 780,640`. Mantén todas las coordenadas de cabecera, grupo, browse, totales, columnas y datos. Añade las fuentes del patrón a cada control. Los botones Añadir/Quitar quedan en `x=650`, `y=175/215`, `w=100,h=30`, neutros; Guardar `x=540,y=580,w=100` primario y Cancelar `x=650,y=580,w=110` neutro.
2. En `LineaEditDialog()`, fija sólo `SIZE 540,350`. Recoloca sus cinco filas en y 24,62,100,138,176 con etiquetas `x=24,w=150` y campos `x=184`, conservando anchos, `PICTURE`, `ITEMS` y bloques `ON CHANGE`. Cantidad y Precio se mantienen en segunda columna de la fila 100: etiqueta `x=340,w=70`, campo `x=414`. Aceptar `x=270,y=290,w=100` primario y Cancelar `x=380,y=290,w=110` neutro.
3. No cambies cálculos, total, selección de artículo, tratamiento IVA, arrays, servicios, condiciones ni retornos.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-14.md` con el formato obligatorio. `Siguiente fase permitida: fase-15.md`.
