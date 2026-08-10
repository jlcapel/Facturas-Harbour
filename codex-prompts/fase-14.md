# FASE 14 — C4: Statusbar operativa + build final Linux y Windows

Lee antes: `reglas-base.md`, `heredado-13.md`.

## OBJETIVO
1. Hacer que la STATUS BAR de `src/main.prg` muestre información real:
   - Parte 1: texto de estado: "Listo" / "Vista: <nombre>" al abrir una vista (en `AbrirVista`), y "Base de datos: ~/Facturas/facturas.db" al iniciar.
   - Parte 2: versión o idioma activo ("es"" / código idioma) con `L("MainVersion")` y/o `LocalizationGetLang`.
2. Para ello añade en `main.prg` la variable a `s_oStatusBar` (o el handle del control) y `AddStatusMessage(text)` en `AbrirVista`; comodín CON claves i18n donde haya texto (`L("AppStatusReady")`, `L("AppStatusVista")`, etc. — crear claves nuevas si no existen en los 5 idiomas).

## LOGRO TÉCNICO
- Averigua cómo actualizar el texto de un estado en HWGUI (propiedad del objeto statusbar, p. ej. `oStatus:SetMessage(...)`; busca en el repo ejemplos o en la doc HWGUI **en código** del proyecto .NET (Avalonia) si existe StatusBar; en su defecto usa el método que HWGUI exponga).
- Si HWGUI no permite texto dinámico fácilmente, déjalo: documenta la limitación en el heredado y skip este retable (pero PRIMERO investiga 10min).

## DESPUÉS (build final)
1. `./build.sh` (Linux) → debe terminar en `OK: ./Fact`.
2. `./build.sh win` → debe producir `Facturas.exe` (no ejecutarlo).
3. Cualquier error de compilación de las fases previas → corregir.

## SALIDA FINAL (IMPORTANTE — último heredado)
Escribe `herenado-14.md` con:
- Resumen de TODO el proyecto tras las 14 fases (estado i18n: nº claves/es, paridad 5 idiomas confirmada por verificar_i18n.sh)
- Resultado builds Linux/Windows
- Statusbar: implementada o bloqueada (y por qué), claves nuevas
- Lista de archivos modificados EN TODO el proceso (resumen, no detalle exhaustivo)