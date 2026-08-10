# FASE 1 — i18n: claves Menu* (reparar menú principal)

Lee antes: `reglas-base.md` (totalmente), `heredado-00-ESTADO-INICIAL.md` (recuerda: menú roto por 22 claves `Menu*` faltantes).

## OBJETIVO
Añadir a los 5 ficheros `src/i18n/strings_{es,en,fr,ca,eu}.prg` las 22 claves `Menu*` que usa `src/main.prg`, para que el menú deje de mostrar `[[Menu...]]`.

Claves y traducción ES (usa estas; traduce finamente en los otros idiomas a su equivalente natural):

```
MenuMaestros       -> "Maestros"
MenuClientes       -> "Clientes"
MenuArticulos      -> "Artículos"
MenuProveedores    -> "Proveedores"
MenuBienesInversion-> "B. Inversión"
MenuGastos         -> "Gastos"
MenuFacturas       -> "Facturas"
MenuPaises         -> "Países"
MenuTiposIva       -> "Tipos IVA"
MenuTiposIdent     -> "Tipos Identificación"
MenuCategoriasGasto-> "Categorías Gasto"
MenuEmpresa        -> "Empresa"
MenuConfiguracion  -> "Configuración"
MenuValidacion     -> "Validación"
MenuNifAeat        -> "NIF AEAT"
MenuVatVies        -> "VAT VIES"
MenuModelosAeat    -> "Modelos AEAT"
MenuExportar       -> "Exportar"
MenuRegistrosXml   -> "Registros XML"
MenuEventosXml     -> "Eventos XML"
MenuGastosCsv      -> "Gastos CSV"
MenuListado        -> "Listado"
```

## PASOS EXACTOS
1. Abrir `src/main.prg` y verificar cuáles `L("...")` usa el menú (deben ser las 22 de arriba). No cambiar main.prg.
2. En `strings_es.prg`, insertar estas claves dentro del hash `h := {=>}`, ordenadas alfabéticamente con las demás `Menu*`, con guiones de traducción introducidos (español de arriba).
3. Repetir en `strings_en.prg`, `strings_fr.prg`, `strings_ca.prg`, `strings_eu.prg` con traducción correcta a cada idioma (busca patrones de otras claves para traducir fielmente; si dudas sobre un término, usa la raíz Latina equivalente / consulta en strings_en la equivalencia de "Clientes"/"Gastos").
4. NO ELIMINAR ninguna clave existente. Asegúrate de que `h["Menu..."]` se añade en los 4 archivos (max limit), Y en strings_es.
5. Verificación textual (sin compilar todavía): para cada fichero, `grep -c 'h\["Menu.*"'` debe dar ≥ 22.

## CRITERIOS DE ACEPTACIÓN
- Las 22 claves existen en los 5 idiomas (puedes verificarlo con un pequeño comando grep: `for f in es en fr ca eu; do echo $f:; grep -c 'h\["Menu"' src/i18n/strings_$f.prg; done` → cada uno ≥ 22).
- No más `[[Menu...]]` en la app: el menú usa exactamente esas claves.
- Sin eliminar/duplicar claves (revisa con `sort | uniq` si hay duplicados).
- Compila: `./build.sh` termina con `OK: ./Facturas`.

## SALIDA
Escribir `codex-prompts/heredado-01.md` con:
- Ficheros modificados
- Nº de claves añadidas por archivo (es/en/fr/ca/eu)
- Advertencias si alguna clave ya existía (y con qué texto)