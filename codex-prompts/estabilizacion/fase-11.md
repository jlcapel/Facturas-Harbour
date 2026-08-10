# FASE 11 — Hora oficial y backup SQLite/WAL

Lee `AGENTS.md`, `reglas-base.md` y `contexto-10.md`.

## Objetivo único

Usar la hora oficial en la generación fiscal y hacer copias de seguridad recuperables de una BD SQLite en modo WAL, replicando el comportamiento de la referencia.

## Acciones obligatorias

1. Contrasta `NtpService` y backup con los métodos y pruebas .NET anotados en el contrato.
2. Haz que la creación de registros use la fuente de hora definida por el contrato, con el fallback permitido por la referencia y trazabilidad en log.
3. Reemplaza la copia de archivo insegura en WAL por el procedimiento equivalente de SQLite o por el procedimiento exacto usado en .NET.
4. Corrige la retención de copias usando el nombre real de cada entrada de `hb_DirScan`.
5. Añade pruebas temporales de hora disponible/no disponible, backup, retención, integridad y restauración; no toques la BD de usuario.

## Ficheros permitidos

- `src/services/NtpService.prg`
- `src/services/BackupService.prg`
- `src/services/VeriFactuService.prg`
- `src/database.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-11.md`

## Validación y salida

Ejecuta pruebas, `./build.sh` y `./build.sh win`. Escribe `contexto-11.md` y termina.
