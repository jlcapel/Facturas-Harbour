# FASE 08 — Alta de factura atómica

Lee `AGENTS.md`, `reglas-base.md` y `contexto-07.md`.

## Objetivo único

Hacer atómica la creación de factura, líneas, snapshot o registro fiscal exigido por el contrato y evento local, dejando el envío AEAT fuera de la transacción como en la referencia.

## Acciones obligatorias

1. Relee el método de alta .NET documentado en el contrato y reproduce su orden de persistencia.
2. Añade pruebas que provoquen fallo en cada paso persistente y demuestren rollback total, incluida la numeración duplicada.
3. Implementa una única transacción SQLite para el bloque local; comprueba cada resultado y propaga un error interno controlado a la UI.
4. No envíes SOAP dentro de la transacción ni uses datos del usuario para probar.
5. No implementes corrección ni anulación en esta fase.

## Ficheros permitidos

- `src/db/FacturaService.prg`
- `src/services/VeriFactuService.prg`
- `src/database.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-08.md`

## Validación y salida

Ejecuta las pruebas de rollback y alta, `./build.sh` y `./build.sh win`. Escribe `contexto-08.md` y termina.
