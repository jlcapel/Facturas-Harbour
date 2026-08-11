# Fase 18 — Modelos AEAT

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-17.md`.

## Objetivo único

Aplicar el patrón cerrado sólo a `ModelosAeatView.prg`.

## Ficheros permitidos

- `src/views/ModelosAeatView.prg`
- `codex-prompts/linea-visual/contexto-18.md`

## Acciones exactas

1. Añade el título `L("ModelosAeatTitle")` en el rectángulo de título del patrón. Mueve el subtítulo actual a `nX+20,nY+56`, con fuente de texto y color secundario.
2. Los siete botones de modelo forman exactamente dos columnas: izquierda `x=nX+20`, derecha `x=nX+250`, ancho 220, alto 30; filas y `nY+90`, `+130`, `+170`, `+210`. La séptima queda izquierda en `+210`. Son neutros y conservan literal el `ON CLICK` de selección.
3. Año y trimestre quedan en y `nY+260`; Generar, Abrir carpeta y Verificar cadena quedan en y `nY+310`, `x=nX+20/140/260`, anchos 100/100/120, alto 30. Generar es primario; las otras dos acciones neutras.
4. No cambies los siete modelos, selección, año, trimestre, generación, apertura, verificación ni ejecutes ningún botón. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-18.md` con el formato obligatorio. `Siguiente fase permitida: fase-19.md`.
