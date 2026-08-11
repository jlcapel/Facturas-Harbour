# Fase 09 — Clientes

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-08.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `ClientesView.prg`, incluido su modal.

## Ficheros permitidos

- `src/views/ClientesView.prg`
- `codex-prompts/linea-visual/contexto-09.md`

## Acciones exactas

1. Añade el título `L("ClientesTitle")`. Recoloca Nuevo `nX+20,w=100` primario, Editar `nX+130,w=90` neutro, Eliminar `nX+230,w=100` peligro y PDF `nX+nW-100,w=80` neutro; el browse usa el patrón y mantiene columnas y datos.
2. En `ClienteEditDialog()`, fija `SIZE 600,560`. Nombre, Tipo, País, Tipo identificación, NIF, NIF IVA, Dirección, Población, CP y Teléfono usan filas 24,62,100,138,176,214,252,290,328,366, etiquetas `x=24,w=150`, campos `x=184` y sus anchos actuales. Provincia comparte la fila 290 y Email la 366, con etiqueta `x=360,w=86` y campo `x=456` con el ancho actual.
3. Mantén sin cambios los `GET COMBOBOX`, sus `ITEMS`, bindings y altura desplegable. Guardar `x=360,y=500,w=100` primario; Cancelar `x=470,y=500,w=110` neutro.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-09.md` con el formato obligatorio. `Siguiente fase permitida: fase-10.md`.
