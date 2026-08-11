# Fase 05 — Países

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-04.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `PaisesView.prg`, incluido sus dos modales.

## Ficheros permitidos

- `src/views/PaisesView.prg`
- `codex-prompts/linea-visual/contexto-05.md`

## Acciones exactas

1. Añade el título `L("PaisesTitlePage")` con el patrón de listado. Recoloca las acciones existentes: Nuevo `x=nX+20,w=100` primario; Editar `nX+130,w=90` neutro; Eliminar `nX+230,w=100` peligro; PDF `nX+nW-190,w=80` neutro; Volver `nX+nW-100,w=80` neutro. Todas usan `y=nY+58`; el browse ocupa el rectángulo del patrón.
2. En `PaisNuevo()` y `PaisEditar()`, fija `SIZE 540,280`; Código, Nombre y Nacionalidad usan las filas 24, 62 y 100, etiquetas `x=24,w=150`, campos `x=184` con sus anchos actuales. El checkbox permanece en `x=184,y=138`. Guardar queda `x=270,y=220,w=100` primario y Cancelar `x=380,y=220,w=110` neutro.
3. Añade únicamente fuentes y colores definidos por `patron-ui.md`. Conserva literal todos los bloques de guardado, cancelación, PDF, eliminación y `ACTIVATE`.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-05.md` con el formato obligatorio. `Siguiente fase permitida: fase-06.md`.
