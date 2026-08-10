# FASE 07 — Migraciones SQLite idempotentes

Lee `AGENTS.md`, `reglas-base.md` y `contexto-06.md`.

## Objetivo único

Preparar el esquema existente para los flujos fiscales que el contrato .NET exige, sin borrar ni reconstruir bases de datos de usuario.

## Acciones obligatorias

1. Compara las tablas y columnas necesarias para alta, corrección o subsanación y anulación con el contrato documentado en fase 01.
2. Implementa migraciones manuales, idempotentes y ordenadas en `database.prg`; cada migración comprueba primero si la tabla o columna existe.
3. No introduzcas columnas o tablas que no estén en la referencia .NET ni elimines datos, restricciones o índices existentes.
4. Añade pruebas que inicialicen una BD desde cero y otra que represente el esquema previo; ambas deben quedar en el esquema objetivo.
5. Documenta en el contexto la lista exacta de migraciones y sus condiciones de reversión, si existen.

## Ficheros permitidos

- `src/database.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-07.md`

## Validación y salida

Ejecuta pruebas de esquema, `./build.sh` y `./build.sh win`. Escribe `contexto-07.md` y termina.
