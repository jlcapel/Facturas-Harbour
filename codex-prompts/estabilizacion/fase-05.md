# FASE 05 — Cadenas y timestamps persistidos

Lee `AGENTS.md`, `reglas-base.md` y `contexto-04.md`.

## Objetivo único

Hacer verificables las cadenas de registros y eventos con exactamente el timestamp persistido que se usó para calcular cada hash.

## Acciones obligatorias

1. Añade pruebas para cadena válida, hash modificado, hash anterior modificado y timestamp modificado, basadas en `VeriFactuServiceTests` y `EventoServiceTests`.
2. Conserva y recupera fecha, hora y zona en los formatos de fecha usados por hash y verificación; no uses una conversión que descarte la hora.
3. Haz que `RegistrarEvento` calcule y persista con un único instante.
4. No cambies NTP, TLS, alta de factura ni esquema en esta fase salvo una migración indispensable ya descrita por el contrato.

## Ficheros permitidos

- `src/utils/DateUtils.prg`
- `src/services/VeriFactuService.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-05.md`

## Validación y salida

Ejecuta pruebas, `./build.sh` y `./build.sh win`. Escribe `contexto-05.md` y termina.
