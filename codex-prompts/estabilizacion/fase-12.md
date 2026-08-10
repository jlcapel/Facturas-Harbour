# FASE 12 — Contrato SOAP/XML sin red

Lee `AGENTS.md`, `reglas-base.md` y `contexto-11.md`.

## Objetivo único

Comprobar que los XML SOAP de alta, anulación y consulta, y el tratamiento de CSV/errores, coinciden con la referencia sin invocar servicios externos.

## Acciones obligatorias

1. Extrae de `AeatClientServiceTests` los fixtures y aserciones aplicables al contrato Harbour.
2. Añade pruebas locales para XML de alta, anulación y consulta, escape XML, certificado ausente, CSV correcto, error AEAT y respuesta desconocida.
3. Separa, si es imprescindible, la construcción y el parseo puros de la llamada cURL para poder probarlos sin red; no cambies el contrato SOAP ni añadas endpoints.
4. Crea `codex-prompts/estabilizacion/protocolo-preproduccion-aeat.md` con pasos manuales, entradas no sensibles, resultado esperado y evidencia a conservar. No ejecutes ese protocolo.

## Ficheros permitidos

- `src/services/AeatClientService.prg`
- `src/services/Helpers.prg`
- `tests/**`
- `codex-prompts/estabilizacion/protocolo-preproduccion-aeat.md`
- `codex-prompts/estabilizacion/contexto-12.md`

## Validación y salida

Ejecuta pruebas sin red, `./build.sh` y `./build.sh win`. Escribe `contexto-12.md` y termina.
