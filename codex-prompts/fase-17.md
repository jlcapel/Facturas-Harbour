# FASE 17 (OPCIONAL) — D3: High-DPI

Lee antes: `reglas-base.md`, `heredado-16.md`. **Saltar si no se quiere: generar `heredado-17.md` con "FASE 17 SKIPPED".**

## OBJETIVO
Escalar la UI en pantallas HiDPI (4K, Zoom del sistema).

## MINIVIABLE (sin riesbg)
1. Averiguar la densidad en `main.prg` al inicio: leer variable de entorno HWGUI/GTK (`GDK_SCALE`/Win API `GetDpiForWindow`) o usar la función de HWG relacionada si existe (`hwg_GetWorkArea` no; busca `hwg_GetDeviceCaps(LOGPIXELSX)` o similar en fuentes).
2. Definir un `nScaleFactor` (1, 1.25, 1.5, 2.0 según dpi/96) y aplicar en:
   - `Theme` fuentes: `FuenteTitulo(20 * nScale`, `FuenteTexto(18 * nScale)`.
   - Los textos de bienvenida ya centrados (fase 9) se escalan.
3. LAS VISTAS con coordenadas fijas NO se redimensionan en esta fase (documentarlo como limitación; redondear únicamente el título/fuentes de talla principal).
4. NO redimensionar browses ni dialogs (rompería layouts).

## CRITERIOS
- Si alguna API de dpi no está disponible en la plataforma linux/debuild de HWGUI, usar fallback: `nScale := 1` y documenta.
- `./build.sh` OK.

## SALIDA
`heredado-17.md`: método de obtención de dpi usado, factor calculado, qué se escala y qué no (limitaciones explícase).