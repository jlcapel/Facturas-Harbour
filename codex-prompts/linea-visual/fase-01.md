# Fase 01 — Marco principal estable

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-00.md`.

## Objetivo único

Hacer que la ventana principal ofrezca una superficie de trabajo amplia y consistente con la referencia .NET, sin cambiar el menú ni la navegación.

## Ficheros permitidos

- `src/main.prg`
- `codex-prompts/linea-visual/contexto-01.md`

## Acciones exactas

1. Conserva `HMainWindow`, el título, los menús existentes y la ausencia de sidebar.
2. Cambia sólo el tamaño inicial a `1200, 750` y activa la ventana con `MAXIMIZED`. No añadas `WS_POPUP`, `WS_SIZEBOX` ni `HStatus`.
3. En `AbrirVista()`, sustituye el rectángulo de contenido fijo por `nX := 16`, `nY := 72`, `nW := 1168`, `nH := 640`. No alteres los `CASE`, las vistas llamadas ni sus parámetros salvo esos valores.
4. No cambies fuentes, colores, textos, botones ni lógica en esta fase.
5. Ejecuta las tres validaciones obligatorias de `reglas-base.md`.

## Criterios de aceptación

- La ventana inicial coincide con la referencia .NET en tamaño de diseño `1200×750` y se maximiza.
- Las vistas embebidas reciben una zona de trabajo de `1168×640` con márgenes regulares.
- Menú, navegación y acciones permanecen idénticos.

## Salida

Escribe `contexto-01.md` con el formato obligatorio y el resultado de ambos builds. `Siguiente fase permitida: fase-02.md`.
