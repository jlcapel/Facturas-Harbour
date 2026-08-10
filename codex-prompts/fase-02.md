# FASE 2 — i18n: completar 36 claves ausentes en en/fr/ca/eu + seed Language

Lee antes: `reglas-base.md`, `heredado-01.md`.

## OBJETIVO
1. Las 36 claves que existen en `strings_es.prg` pero faltan en `en/fr/ca/eu` deben añadirse traducidas a esos 4 idiomas.
2. Añadir al seed de config en `src/database.prg` la clave `"Language"` con valor `"es"` (en `SembrarConfiguracion`), para que la clave exista en la BD nueva.

## PASOS EXACTOS

### A. Identificar las claves que faltan (¡NO usar este output como definitivo!):
```
comm -23 <(grep -oE 'h\["[^"]+"\]' src/i18n/strings_es.prg | sort -u) <(grep -oE 'h\["[^"]+"\]' src/i18n/strings_en.prg | sort -u)
```
Debe dar exactamente 36 claves: `CommonConfigurar CommonConsultar CommonGestionar CommonListado CommonNueva CommonNuevo2 CommonXML GastoCsvHeader ValidationVatFmtAT ... ValidationVatFmtSK ValidationVatPrefijoNoReconocido`.

### B. Traducir y añadir
- En `strings_en.prg`: añade las 36 con traducción inglesa coherente. Usa contexto: `ValidationVatFmtXX` son mensajes de formato ("Formato: XX + ..." → "Format: XX + ..."). `CommonConfigurar`→"Configure", `CommonConsultar`→"Query", `CommonGestionar`→"Manage", `CommonListado`→"Listing", `CommonNueva`→"New", `CommonNuevo2`→"New", `CommonXML`→"XML", `GastoCsvHeader` es una cabecera CSV (traduce los campos; los separadores `;` se mantienen).
- En `strings_fr.prg`, `strings_ca.prg`, `strings_eu.prg`: haz lo mismo en cada idioma (francés, catalán, euskera). Fidelidad al sentido, no traducción literal forzada.
- Inserta las claves en orden alfabético junto a sus vecinas (la tabla hash no exige orden, pero mantenlo coherente).
- NO eliminar nada. NO duplicar.

### C. Seed de idioma
- En `src/database.prg`, dentro de `SembrarConfiguracion`, añadir `{ "Language", "es" }` (revisa el array `aConfig` y añádelo en un lugar lógico).

## CRITERIOS DE ACEPTACIÓN
- `comm` contra es vs en/fr/ca/eu → 0 claves faltantes (exacto).
- Las 4 idiomas tienen ahora 750 claves (igual que es): `grep -cE '^\s*h\["' src/i18n/strings_*.prg`.
- `./build.sh` OK.
- No modificar `strings_es.prg` en esta fase.

## SALIDA
`codex-prompts/heredado-02.md`: ficheros modificados, nº claves por idioma tras el cambio, confirmación del seed, cualquier desviación.