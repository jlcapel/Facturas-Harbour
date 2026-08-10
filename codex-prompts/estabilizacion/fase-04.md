# FASE 04 — Desglose IVA fiscal

Lee `AGENTS.md`, `reglas-base.md` y `contexto-03.md`.

## Objetivo único

Corregir `GenerarDesgloseJson()` para que use los campos reales de línea y replique exactamente los grupos, bases y cuotas de la referencia .NET.

## Acciones obligatorias

1. Añade pruebas de líneas con uno y varios tipos de IVA, ordenadas y desordenadas, usando los casos .NET del contrato.
2. Verifica el contrato del array de línea en `FacturaEditView` y `FacturaService` antes de cambiar índices.
3. Cambia sólo `GenerarDesgloseJson()` y sus auxiliares imprescindibles; no modifiques el contrato de la vista ni calcules con texto formateado.
4. Compara el JSON estructural y los importes con la referencia, no sólo que sea JSON válido.

## Ficheros permitidos

- `src/services/VeriFactuService.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-04.md`

## Validación y salida

Ejecuta pruebas, `./build.sh` y `./build.sh win`. Escribe `contexto-04.md` y termina.
