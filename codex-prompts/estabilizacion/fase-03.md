# FASE 03 — Hash y QR canónicos

Lee `AGENTS.md`, `reglas-base.md` y `contexto-02.md`.

## Objetivo único

Clonar los formatos exactos de hash y QR de la referencia .NET, sin espacios de relleno, con punto decimal, total fiscal y URL correctamente formada.

## Acciones obligatorias

1. Añade primero vectores de `VeriFactuServiceTests` y `QRServiceTests` citados en el contrato.
2. Corrige exclusivamente el formateo necesario en `DateUtils`, `VeriFactuService` y `QRService`; separa formato fiscal de formato de presentación si la referencia lo hace.
3. Conserva el IRPF fuera del total fiscal de hash y QR.
4. No alteres SOAP, esquema, UI ni generación PDF en esta fase.

## Ficheros permitidos

- `src/utils/DateUtils.prg`
- `src/services/VeriFactuService.prg`
- `src/services/QRService.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-03.md`

## Validación y salida

Todos los vectores Harbour deben coincidir exactamente con la referencia; ejecuta pruebas, `./build.sh` y `./build.sh win`. Escribe `contexto-03.md` y termina.
