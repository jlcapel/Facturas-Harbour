# FASE 7 — i18n: script de verificación de paridad

Lee antes: `reglas-base.md`, `heredado-06.md`.

## OBJETIVO
Crear un script que garantice la integridad del i18n:
1. Todas las claves de `strings_*.prg` son las mismas en los 5 idiomas (sin faltantes ni extra).
2. Detectar cualquier `L("Clave")` usada en el código que NO exista en `strings_es.prg`.

## ENTREGABLE
Crea `tools/verificar_i18n.sh` (script bash) en el repo que:

- Extrae las claves de cada `src/i18n/strings_*.prg` con `grep -oE 'h\["[^"]+"\]'` → `sort -u`.
- Compara las de `es` contra `en/fr/ca/eu` y reporta:
  - Faltantes en cada idioma (deben ser 0)
  - Sobrantes en cada idioma (extrañas; deben ser 0 o justificadas)
- Escanea `src/**/*.prg` buscando `L("...")` y reporta cuáles no existen en `strings_es.prg` (deben ser 0).
- Exit code 0 si todo ok, 1 si hay diferencias (para CI).
- Salida legible con la lista exacta de claves problemáticas.

## PASOS
1. Crea `tools/` si no existe.
2. Escribe el script (solo grep/sort/comm, sin dependencias externas).
3. Ejecútalo: `bash tools/verificar_i18n.sh`.
4. Si reporta problemas, corrígelos (añade claves o arregla el `L()`). NO eliminar claves de `es`.
5. Vuelve a ejecutar hasta `exit 0`.

## CRITERIOS
- El script es idempotente.
- `./build.sh` OK después de cualquier corrección.

## SALIDA
`heredado-07.md`: ruta del script, resultado de la última ejecución (0 problemas), correcciones hechas.