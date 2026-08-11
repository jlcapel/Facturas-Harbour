# FASE 04A — Campos y tratamientos fiscales de IVA

La autorización expresa del usuario permite ejecutar esta fase para resolver `contexto-04.md` bloqueado. Lee `AGENTS.md`, `reglas-base.md` y `contexto-04.md`.

## Objetivo único

Clonar de .NET los campos fiscales de `TipoIva` y `LineaFactura`, su persistencia compatible y la selección de tratamiento que los congela en cada línea.

## Acciones obligatorias

1. Usa exclusivamente `Models/TipoIva.cs`, `Models/LineaFactura.cs`, `Models/TratamientoIvaOperacion.cs`, `SchemaCompatibilityService.cs`, `TiposIvaViewModel.cs` y `FacturaEditViewModel.cs` de la referencia.
2. Añade a `TiposIva`: `Impuesto`, `ClaveRegimen`, `CalificacionOperacion`, `DescripcionFiscal`; y a `LineasFactura`: esos campos más `OperacionExenta`, con los defaults .NET.
3. Implementa migración idempotente y clasificación mínima de tipos existentes; no uses la BD del usuario en pruebas.
4. Clona todo el catálogo `TratamientoIvaOperacion.Todos`, persiste sus valores en la línea y aplica la regla `Codigo != S1` exige IVA cero antes de guardar.
5. Expón en Tipos IVA los campos de catálogo y en la edición de línea el tratamiento; conserva los índices existentes y añade los nuevos al final del array.
6. Añade pruebas temporales de migración, roundtrip de servicio y tratamientos S1, S2, N2 y E5.

## Ficheros permitidos

- `src/database.prg`
- `src/db/TipoIvaService.prg`
- `src/db/FacturaService.prg`
- `src/services/AeatConstants.prg`
- `src/views/TiposIvaView.prg`
- `src/views/FacturaEditView.prg`
- `src/i18n/strings_*.prg`
- `tests/**`
- `codex-prompts/estabilizacion/contexto-04a.md`

## Validación y salida

Ejecuta las pruebas, `./build.sh` y `./build.sh win`. Escribe `contexto-04a.md` y termina.
