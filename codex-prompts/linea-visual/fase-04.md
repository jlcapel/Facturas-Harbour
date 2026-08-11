# Fase 04 — Tipos de IVA: formularios patrón

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-03.md`.

## Objetivo único

Normalizar los dos diálogos de Tipos de IVA con la misma tipografía, retícula y acciones que el patrón visual.

## Ficheros permitidos

- `src/views/TiposIvaView.prg`
- `codex-prompts/linea-visual/contexto-04.md`

## Acciones exactas

1. Aplica el mismo diseño a `TipoIvaNuevo()` y `TipoIvaEditar()`; no extraigas ni reescribas su lógica.
2. Cada diálogo mantiene sus mismos seis campos, valores iniciales, validaciones y botones Guardar/Cancelar. Aumenta sólo el tamaño del diálogo a `540, 360`.
3. Usa `FuenteUiTexto()` en etiquetas y campos, y `FuenteUiBoton()` en botones. Usa `ColorUiTexto()` en etiquetas.
4. Fija la retícula: etiquetas x 24 ancho 150; campos x 184; filas y 24, 62, 100, 138, 176 y 214; los campos de texto largo conservan su contenido pero usan ancho 320. Los botones quedan a la derecha, y 300: Guardar x 270 ancho 100 primario/blanco y Cancelar x 380 ancho 110 neutro/texto.
5. No modifiques el tipo de modal, `ACTIVATE DIALOG`, operaciones de guardado, condiciones de cancelación ni claves i18n.
6. Ejecuta las tres validaciones obligatorias.

## Criterios de aceptación

- Ambos modales tienen la misma geometría y no solapan controles.
- Guardar y Cancelar conservan exactamente el comportamiento previo.
- No hay cambio de datos ni de reglas fiscales.

## Salida

Escribe `contexto-04.md` con el formato obligatorio, los formularios afectados y resultados de build. `Siguiente fase permitida: fase-05.md`.
