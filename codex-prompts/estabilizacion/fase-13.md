# FASE 13 — Validación runtime y UI multiplataforma

Lee `AGENTS.md`, `reglas-base.md` y `contexto-12.md`.

## Objetivo único

Convertir la validación UI y el error histórico HWGUI en un protocolo reproducible, sin declarar resuelto nada que no pueda ejecutarse de forma segura.

## Acciones obligatorias

1. Examina `Error.log`, `src/main.prg` y las fuentes HWGUI locales para identificar la ruta concreta del error `No exported method: EVAL`.
2. Si puedes reproducirlo con una BD temporal y sin usar datos de usuario, corrígelo únicamente en `main.prg` o en el control responsable y deja una prueba o procedimiento de reproducción.
3. Si no puedes reproducirlo de forma segura, no cambies código especulativamente: documenta el bloqueo y los pasos exactos que debe ejecutar un operador en Linux y Windows.
4. Crea `codex-prompts/estabilizacion/matriz-ui.md` con los flujos: arranque, cada menú, CRUD maestro, alta/corrección/anulación, gastos, PDF, cambio de idioma, NIF/VIES y modelos AEAT; exige resultado en GTK3 y WinAPI.
5. No ejecutes AEAT, NIF ni VIES reales.

## Ficheros permitidos

- `src/main.prg`
- `src/views/**`
- `tests/**`
- `codex-prompts/estabilizacion/matriz-ui.md`
- `codex-prompts/estabilizacion/contexto-13.md`

## Validación y salida

Ejecuta pruebas disponibles, `./build.sh` y `./build.sh win`. Escribe `contexto-13.md` indicando de forma explícita `EVAL: RESUELTO`, `EVAL: NO REPRODUCIDO` o `EVAL: BLOQUEADO`. Termina.
