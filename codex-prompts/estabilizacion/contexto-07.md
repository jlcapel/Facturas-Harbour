# Contexto fase 07

Estado: COMPLETADA con autorización expresa para reconstruir `RegistrosFacturacion`.
Ficheros modificados: `src/database.prg`, `tests/prueba_migraciones_esquema.prg` y este contexto.
Pruebas ejecutadas: prueba temporal de esquema vacío y previo, con conservación de fila, cadena e índice, inserción de subsanación e integridad FK; `./build.sh`; `./build.sh win`; todas correctas.
Decisiones clonadas de .NET: `SchemaCompatibilityService.Asegurar` hace no único `RegistrosFacturacion.FacturaId`, añade `FacturaVersionFiscalId`, crea `FacturasVersionesFiscales`, ambos desgloses IVA y sus índices; alta, subsanación y anulación enlazan un registro con una versión fiscal.
Riesgos o pendientes: la reconstrucción se limita a la unicidad inline de `FacturaId`, copia todas las columnas y restaura índices y triggers explícitos. Antes del `COMMIT` cualquier error ejecuta `ROLLBACK`; no hay reversión automática tras confirmar, por lo que una restauración posterior exige backup.
Siguiente paso permitido: fase 08 puede implementar el bloque transaccional local de alta en `FacturaService.prg` y `VeriFactuService.prg`, sin SOAP dentro de él.
