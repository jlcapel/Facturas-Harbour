# Fase 08 — Bienes de inversión

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-07.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `BienesInversionView.prg`, incluido su modal.

## Ficheros permitidos

- `src/views/BienesInversionView.prg`
- `codex-prompts/linea-visual/contexto-08.md`

## Acciones exactas

1. Añade el título `L("BienesTitle")`. Recoloca Nuevo `nX+20,w=100` primario, Editar `nX+130,w=90` neutro, Eliminar `nX+230,w=100` peligro y PDF `nX+nW-100,w=80` neutro. Aplica el browse del patrón sin tocar columnas.
2. En `BienEditDialog()`, fija `SIZE 620,480`. Nombre usa fila 24 y campo `x=184,w=390`. Fecha, Valor, Porcentaje, Categoría, Amortización anual, Valor neto y Fecha inicio ocupan filas 62,100,138,176,214,252,290 con etiqueta `x=24,w=150` y sus anchos actuales. Valor amortizado y Fecha baja permanecen como segunda columna: etiqueta `x=340,w=120`, campo `x=470`, en filas 214 y 290.
3. Sitúa Guardar `x=400,y=420,w=100` primario y Cancelar `x=510,y=420,w=110` neutro. No alteres imágenes, importes, formatos, campos ni guardado.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-08.md` con el formato obligatorio. `Siguiente fase permitida: fase-09.md`.
