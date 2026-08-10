# FASE 06 — TLS y certificado cliente AEAT

Lee `AGENTS.md`, `reglas-base.md` y `contexto-05.md`.

## Objetivo único

Eliminar toda aceptación insegura de TLS del cliente AEAT y reproducir la política de certificado de la referencia .NET sin realizar llamadas externas.

## Acciones obligatorias

1. Localiza en la referencia el tratamiento de endpoint, certificado, contraseña y errores de transporte.
2. Añade pruebas locales que inspeccionen la configuración preparada para cURL y cubran: certificado inexistente, contraseña vacía, endpoint inválido y verificación TLS activa.
3. Elimina los valores que desactiven `SSL_VERIFYPEER` o `SSL_VERIFYHOST` y configura únicamente opciones respaldadas por hbcurl instalado.
4. Si falta certificado o entorno válido, devuelve un error controlado y registra el evento equivalente a .NET; no intentes enviar.
5. No cambies XML, hash, esquema ni UI.

## Ficheros permitidos

- `src/services/AeatClientService.prg`
- `src/services/Logger.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-06.md`

## Validación y salida

Ejecuta pruebas sin red, `./build.sh` y `./build.sh win`. Escribe `contexto-06.md` y termina.
