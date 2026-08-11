# Fase 02 — Estilos HWGUI reutilizables

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-01.md`.

## Objetivo único

Crear una única fuente de colores y fuentes HWGUI, y aplicarla solamente al marco principal.

## Ficheros permitidos

- `src/ui/EstilosUi.prg`
- `src/main.prg`
- `codex-prompts/linea-visual/contexto-02.md`

## Acciones exactas

1. Crea `src/ui/EstilosUi.prg`, con `#include "hwgui.ch"`, sin comentarios y sólo estas funciones públicas:
   - `ColorUiFondo()` → `hwg_ColorRGB2N(241,245,249)`.
   - `ColorUiTarjeta()` → `hwg_ColorRGB2N(255,255,255)`.
   - `ColorUiBorde()` → `hwg_ColorRGB2N(226,232,240)`.
   - `ColorUiTexto()` → `hwg_ColorRGB2N(15,23,42)`.
   - `ColorUiTextoSecundario()` → `hwg_ColorRGB2N(100,116,139)`.
   - `ColorUiPrimario()` → `hwg_ColorRGB2N(37,99,235)`.
   - `ColorUiPeligro()` → `hwg_ColorRGB2N(220,38,38)`.
   - `ColorUiBlanco()` → `hwg_ColorRGB2N(255,255,255)`.
   - `FuenteUiTitulo()`, `FuenteUiSubtitulo()`, `FuenteUiTexto()` y `FuenteUiBoton()`, que creen y devuelvan respectivamente fuentes Arial de altura `-20` peso 700, `-13` peso 400, `-12` peso 400 y `-12` peso 700.
2. En `main.prg`, reemplaza sólo las dos fuentes y colores de bienvenida por `FuenteUiTitulo()`, `FuenteUiSubtitulo()`, `ColorUiTexto()` y `ColorUiTextoSecundario()`.
3. Declara y usa una fuente de título y una de subtítulo; no modifiques el texto, sus coordenadas ni los menús.
4. No apliques colores de fondo a `HMainWindow` ni añadas controles nuevos.
5. Ejecuta las tres validaciones obligatorias.

## Criterios de aceptación

- Ningún color o fuente visual nuevo queda repetido fuera de `EstilosUi.prg`.
- La bienvenida usa Arial y la paleta fijada.
- Linux y Windows compilan correctamente.

## Salida

Escribe `contexto-02.md` con el formato obligatorio, las funciones creadas y los resultados de build. `Siguiente fase permitida: fase-03.md`.
