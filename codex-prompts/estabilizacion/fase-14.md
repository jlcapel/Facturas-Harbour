# FASE 14 — Distribución reproducible Linux y Windows

Lee `AGENTS.md`, `reglas-base.md` y `contexto-13.md`.

## Objetivo único

Preparar los artefactos de distribución definidos en la referencia .NET y documentar todas sus dependencias, sin introducir un formato de instalador que no exista allí.

## Acciones obligatorias

1. Inspecciona exclusivamente las carpetas de publicación e instalador de `/home/jose/programacion/Facturas/` anotadas en el contrato.
2. Implementa o adapta sólo el mecanismo equivalente para Harbour: instalador Windows y paquete Linux, con binario, licencia, recursos y dependencias nativas declaradas.
3. Para Linux, no afirmes que el binario es autónomo si depende de `libharbour`, GTK3, SQLite, cURL o Haru PDF; el paquete debe resolverlas o declararlas.
4. No incluyas certificados, bases de datos de usuario ni configuraciones AEAT en un artefacto.
5. Crea instrucciones de instalación y desinstalación verificables para cada plataforma.

## Ficheros permitidos

- `packaging/**`
- `resources/**`
- `build.sh`
- `README.md`
- `codex-prompts/estabilizacion/contexto-14.md`

## Validación y salida

Ejecuta `./build.sh` y `./build.sh win`; valida que los scripts de empaquetado al menos verifican sus prerequisitos sin publicar ni instalar. Escribe `contexto-14.md` y termina.
