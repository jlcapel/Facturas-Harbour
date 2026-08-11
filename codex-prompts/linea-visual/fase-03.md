# Fase 03 — Tipos de IVA: listado patrón

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-02.md`.

## Objetivo único

Convertir el listado de Tipos de IVA en el patrón visual obligatorio para todos los mantenimientos, sin cambiar sus datos ni comportamiento.

## Ficheros permitidos

- `src/views/TiposIvaView.prg`
- `codex-prompts/linea-visual/contexto-03.md`

## Acciones exactas

1. Dentro de `TiposIvaView()`, crea fuentes locales mediante `FuenteUiTitulo()`, `FuenteUiTexto()` y `FuenteUiBoton()`.
2. Sustituye la disposición actual por estas posiciones relativas a `nX,nY,nW,nH`:
   - título `L("TiposIvaTitlePage")`: `nX+20, nY+18`, tamaño `nW-40, 28`, fuente título, color texto;
   - botones: y `nY+58`, alto 30; Nuevo x `nX+20` ancho 100 primario/blanco, Editar x `nX+130` ancho 90 neutro texto, Eliminar x `nX+230` ancho 100 peligro/blanco, PDF x `nX+nW-100` ancho 80 neutro texto;
   - browse: `nX+20, nY+104`, tamaño `nW-40, nH-124`, fuente texto.
3. Conserva exactamente `aData`, las cinco columnas, sus bloques de datos, las acciones existentes y todos los callbacks. Sólo cambia longitudes de columna a: Nombre 36, porcentaje 10, calificación 10, activo 8 y fecha 14.
4. No añadas botón Volver, CSV, filtros, iconos, información adicional ni campos.
5. No dejes botones en la parte inferior de la vista.
6. Ejecuta las tres validaciones obligatorias.

## Criterios de aceptación

- El listado tiene título, barra superior de acciones y tabla con margen uniforme.
- No se alteran consultas, columnas lógicas, altas, edición, eliminación ni PDF.
- El patrón no contiene coordenadas de botones calculadas desde `nH-55`.

## Salida

Escribe `contexto-03.md` con el formato obligatorio, posiciones, anchos de columna y resultados de build. `Siguiente fase permitida: fase-04.md`.
