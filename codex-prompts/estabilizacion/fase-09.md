# FASE 09 — Corrección o subsanación de factura emitida

Lee `AGENTS.md`, `reglas-base.md` y `contexto-08.md`.

## Objetivo único

Sustituir el falso flujo de edición de una factura emitida por el flujo fiscal de corrección o subsanación definido en la referencia .NET.

## Acciones obligatorias

1. Implementa solamente el flujo y datos que la fila de corrección o subsanación del contrato .NET especifica.
2. Una factura emitida nunca se sobrescribe ni se intenta insertar otra vez con su mismo número.
3. Añade pruebas que prueben conservación del original, creación del registro exigido, cálculo fiscal y rollback si falla la persistencia.
4. Actualiza la vista sólo para invocar el servicio correcto y mostrar el resultado ya definido por las claves existentes o por las claves .NET equivalentes en los cinco idiomas.
5. No modifiques anulación, SOAP ni PDF salvo que la referencia de corrección lo exija de forma directa.

## Ficheros permitidos

- `src/database.prg`
- `src/db/FacturaService.prg`
- `src/services/VeriFactuService.prg`
- `src/views/FacturasView.prg`
- `src/views/FacturaEditView.prg`
- `src/i18n/strings_es.prg`
- `src/i18n/strings_en.prg`
- `src/i18n/strings_fr.prg`
- `src/i18n/strings_ca.prg`
- `src/i18n/strings_eu.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-09.md`

## Validación y salida

Ejecuta pruebas, comprueba la paridad de claves i18n, `./build.sh` y `./build.sh win`. Escribe `contexto-09.md` y termina.
