# Fase 17 — Validación NIF y VIES

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-16.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `ValidacionView.prg` y `ViesView.prg`.

## Ficheros permitidos

- `src/views/ValidacionView.prg`
- `src/views/ViesView.prg`
- `codex-prompts/linea-visual/contexto-17.md`

## Acciones exactas

1. No añadas título de página: no existe una clave de título específica y no se permite crear textos. Conserva cada etiqueta y campo. Aplica `FuenteUiTexto()` y `ColorUiTexto()` según `patron-ui.md`.
2. En ambas vistas, Sitúa Consultar en `x=nX+20,y=nY+104,w=100,h=30`, primario. No cambies su bloque `ON CLICK`, que es la única llamada de red.
3. No cambies el formato, coordenadas ni construcción de las respuestas; aplícales sólo `FuenteUiTexto()` y `ColorUiTextoSecundario()` si se muestran mediante `SAY` ya existente. No ejecutes consultas.
4. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-17.md` con el formato obligatorio. `Siguiente fase permitida: fase-18.md`.
