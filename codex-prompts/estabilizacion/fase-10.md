# FASE 10 — Anulación fiscal consistente

Lee `AGENTS.md`, `reglas-base.md` y `contexto-09.md`.

## Objetivo único

Clonar el flujo de anulación de la referencia .NET: documento de anulación, registro R5, encadenamiento, persistencia atómica y actualización visible sólo tras éxito local.

## Acciones obligatorias

1. Elimina el patrón que marca la original como anulada antes de conseguir su registro fiscal.
2. Crea los datos de anulación y relaciones exactamente como el contrato .NET indica; no reutilices un `FacturaId` si el esquema lo impide.
3. Añade pruebas de anulación correcta, doble anulación, fallo de registro y rollback total.
4. Mantén el envío AEAT fuera de la transacción local y registra errores como la referencia.
5. No cambies el flujo de corrección ya validado en fase 09.

## Ficheros permitidos

- `src/database.prg`
- `src/db/FacturaService.prg`
- `src/services/VeriFactuService.prg`
- `src/views/FacturasView.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-10.md`

## Validación y salida

Ejecuta pruebas de anulación, `./build.sh` y `./build.sh win`. Escribe `contexto-10.md` y termina.
