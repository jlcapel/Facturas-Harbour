# heredado-02 — Fase 2 completada: 36 claves faltantes + seed Language

## Ficheros modificados
- src/i18n/strings_en.prg (+7 Common* + 1 GastoCsvHeader + 29 ValidationVatFmt* + 1 HR)
- src/i18n/strings_fr.prg (+7 Common* + 1 GastoCsvHeader + 29 ValidationVatFmt* + 1 HR)
- src/i18n/strings_ca.prg (+7 Common* + 1 GastoCsvHeader + 29 ValidationVatFmt* + 1 HR)
- src/i18n/strings_eu.prg (+7 Common* + 1 GastoCsvHeader + 29 ValidationVatFmt* + 1 HR)
- src/database.prg (seed "Language" → "es")

## Claves añadidas a en/fr/ca/eu (36 + 1 HR = 37 por idioma)
- CommonConfigurar, CommonConsultar, CommonGestionar, CommonListado, CommonNueva, CommonNuevo2, CommonXML
- GastoCsvHeader
- ValidationVatFmtAT..SK (28 países EU) + ValidationVatFmtHR (Croacia) + ValidationVatPrefijoNoReconocido (29 total)
- Seed: "Language" → "es" en database.prg:397

## Total claves por idioma: 766 (igual en los 5 idiomas)
## Build: OK
## Verificación: comm entre es y en/fr/ca/eu → sin diferencias (excepto duplicados preexistentes en 4 idiomas no-español)
## Nota: Nombres de claves unificados en los 5 idiomas (fix en fase 2: euskera/francés/catalán usaban claves distintas)