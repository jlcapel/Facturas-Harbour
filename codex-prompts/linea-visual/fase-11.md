# Fase 11 — Proveedores

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-10.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `ProveedoresView.prg`, incluido su modal.

## Ficheros permitidos

- `src/views/ProveedoresView.prg`
- `codex-prompts/linea-visual/contexto-11.md`

## Acciones exactas

1. Añade el título `L("ProveedoresTitle")`. Recoloca Nuevo `nX+20,w=100` primario, Editar `nX+130,w=90` neutro, Eliminar `nX+230,w=100` peligro y PDF `nX+nW-100,w=80` neutro. El browse ocupa exactamente el rectángulo del patrón y mantiene sus columnas.
2. En `ProvEditDialog()`, fija `SIZE 600,600`. Nombre, NIF, NIF IVA, tipo identificación, país, dirección, población, CP, teléfono e IBAN usan filas 24,62,100,138,176,214,252,290,328,366, etiquetas `x=24,w=150` y campos `x=184` con anchos actuales. Provincia comparte 252 y Email 328 con etiqueta `x=360,w=86` y campo `x=456` con su ancho actual.
3. Conserva de forma literal la función `ProvGuardarConIban`, las listas de combos, los bindings y el bloque Guardar. Recoloca sólo los botones: Guardar `x=360,y=540,w=100` primario; Cancelar `x=470,y=540,w=110` neutro.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-11.md` con el formato obligatorio. `Siguiente fase permitida: fase-12.md`.
