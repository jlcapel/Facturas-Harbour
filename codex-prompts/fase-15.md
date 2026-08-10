# FASE 15 (OPCIONAL) — D1: Iconos en botones

Lee antes: `reglas-base.md`, `heredado-14.md`. **Si quieres saltártela, genera `heredado-15.md` con "SKIPPED — SALTADA" y pasa a la fase 16.**

## OBJETIVO
Añadir iconos PNG a los botones principales con el mecanismo de HWGUI (`BUTTON ... BITMAP "ruta.png"` o `HB_BITMAP`):

- Botones NUEVO/EDITAR/ELIMINAR/PDF en: PaisesView, ClientesView, ArticulosView, FacturasView, GastosView, ProveedoresView, CategoriasGastoView, BienesInversionView, TiposIvaView, TiposIdentificacionView (16pt, 24x24, .png).
  - Ruta de iconos: crea `resources/icons/` con iconos de 24px (puedes generarlos con `ImageMagick` si está instalado; sino usa SVG simple o props existentes del sistema — p. ej. `/usr/share/icons/`).
  - Si no se pueden cargar en la plataforma, el botón conserva el texto: SOLO añadir icono si la prueba con `hwg_bmp` funciona (un botón de prueba en una vista).
1. Elegir UN botón piloto (PANES NUEVO) y comprobar que aparece el icono al compilar (visualmente no se puede; verifica por comportamiento).

## CRITERIOS
- Si el mecanismo no compila/falla el diseño, REVERTIR (no dejas código roto) y documenta en heredado-15.
- `./build.sh` OK.

## SALIDA
`fiec-15.md`: decisiones (icono o no), patrón usado, botones con icono, si no se pudo (y por qué).