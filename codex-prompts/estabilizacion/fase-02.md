# FASE 02 — Arnés aislado de pruebas Harbour

Lee `AGENTS.md`, `reglas-base.md` y `contexto-01.md`.

## Objetivo único

Crear el mecanismo mínimo y reproducible para ejecutar pruebas Harbour contra una BD temporal, sin tocar lógica fiscal de producción.

## Acciones obligatorias

1. Estudia el uso local de `hbtest` y las pruebas .NET citadas por el contrato.
2. Crea `tests/` y `scripts/tests/ejecutar_fiscales.sh`; el script crea y elimina únicamente un directorio temporal bajo `/tmp` y devuelve código distinto de cero ante fallo.
3. Añade una prueba de humo sin regla fiscal nueva: inicializa una BD temporal, verifica las tablas mínimas y comprueba una función numérica existente contra un valor de la referencia.
4. El arnés debe compilar y enlazar las fuentes que prueba sin modificar `build.sh` ni usar la BD de usuario.

## Ficheros permitidos

- `tests/**`
- `scripts/tests/ejecutar_fiscales.sh`
- `codex-prompts/estabilizacion/contexto-02.md`

## Validación y salida

Ejecuta el script de pruebas y `./build.sh`. Ambos deben terminar correctamente. Escribe `contexto-02.md` y termina.
