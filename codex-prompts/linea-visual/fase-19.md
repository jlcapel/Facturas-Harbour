# Fase 19 — Cierre y evidencia visual

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-18.md`.

## Objetivo único

Dejar evidencia verificable de lo implantado y de la revisión humana pendiente, sin declarar éxito visual no observado.

## Ficheros permitidos

- `docs/VALIDACION_UI_PROFESIONAL.md`
- `codex-prompts/linea-visual/contexto-19.md`

## Acciones exactas

1. Crea `docs/VALIDACION_UI_PROFESIONAL.md` con estos cuatro encabezados exactos: `Contrato visual aplicado`, `Vistas modificadas`, `Validación automática`, `Validación manual pendiente`.
2. En validación automática registra exclusivamente los resultados reales de `./build.sh`, `./build.sh win` y `git diff --check` obtenidos en las fases; no inventes resultados.
3. En validación manual pendiente incluye la matriz: Linux GTK3 100 % y 200 %, Windows WinAPI 100 % y 150 %; inicio, menú, todos los mantenimientos, botones sin corte, grid sin fuente serif, modales, Facturas, Gastos, Empresa, NIF, VIES y Modelos AEAT.
4. Declara literalmente que esta cadena no ejecutó la aplicación, no usó la BD del usuario y no llamó a AEAT ni VIES. Ejecuta las tres validaciones obligatorias. No modifiques `.prg`.

## Salida

Escribe `contexto-19.md` con `Estado: COMPLETADA` si las tres comprobaciones pasan; en otro caso `Estado: BLOQUEADA` con el comando y error exacto. `Siguiente fase permitida: ninguna`.
