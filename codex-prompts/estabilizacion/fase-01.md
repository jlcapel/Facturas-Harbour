# FASE 01 — Contrato exacto con Facturas .NET

Lee `AGENTS.md`, `reglas-base.md` y `contexto-00.md`.

## Objetivo único

Fijar documentalmente la referencia .NET que regirá las fases 02–15. No modifiques código Harbour.

## Acciones obligatorias

1. Ejecuta en `/home/jose/programacion/Facturas/` `git rev-parse HEAD` y `git status --short`; no modifiques ese repositorio.
2. Crea `codex-prompts/estabilizacion/contrato-dotnet.md` con el commit, el estado limpio o sucio y una tabla de una fila por: alta, corrección o subsanación, anulación, hash, QR, desglose, cadenas, SOAP, NTP, backup, PDF y esquema.
3. Cada fila cita únicamente fichero, método y prueba .NET exactos. No copies código ni resumas funcionalidades fuera de esos objetivos.
4. Confirma que el contrato distingue explícitamente factura emitida, corrección o subsanación y anulación.

## Ficheros permitidos

- `codex-prompts/estabilizacion/contrato-dotnet.md`
- `codex-prompts/estabilizacion/contexto-01.md`

## Validación y salida

Comprueba que cada fila tiene ruta, método y prueba o marca `SIN PRUEBA`. Escribe `contexto-01.md` y termina.
