# Contexto fase 04A

Estado: COMPLETADA.
Referencia .NET: `TipoIva.cs`, `LineaFactura.cs`, `TratamientoIvaOperacion.cs`, `SchemaCompatibilityService.cs`, `TiposIvaViewModel.cs` y `FacturaEditViewModel.cs` del commit `f611291b3ea5bea8c1ba5a3261b7a9cc5c17`.
Se añadió migración idempotente de los cuatro campos fiscales en `TiposIva` y cinco en `LineasFactura`, incluidos sus defaults .NET y la reparación de `IVA Inversión` a S2.
Contrato `TipoIva`: los seis índices previos no cambian; 7=`Impuesto`, 8=`ClaveRegimen`, 9=`CalificacionOperacion`, 10=`DescripcionFiscal`.
Contrato `LineaFactura`: los trece índices previos no cambian; 14=`Impuesto`, 15=`ClaveRegimen`, 16=`CalificacionOperacion`, 17=`OperacionExenta`, 18=`DescripcionFiscal`.
`AeatConstants.prg` clona los diez tratamientos de .NET con índices: 1 código, 2 nombre, 3 impuesto, 4 clave, 5 calificación, 6 exenta, 7 descripción.
La selección se congela en la línea antes de persistir; un tratamiento distinto de S1 exige IVA 0 tanto en UI como en servicio.
`TiposIvaView` permite editar los campos de catálogo y `FacturaEditView` seleccionar el tratamiento por línea.
Prueba nueva: `tests/prueba_campos_fiscales.prg`, sobre SQLite temporal, valida migración, round-trip y S1/S2/N2/E5.
Validaciones correctas: prueba fiscal aislada, `scripts/tests/ejecutar_fiscales.sh`, `tests/prueba_hash_qr.prg`, `./build.sh`, `./build.sh win` y `git diff --check`.
No se usó la BD, certificados ni servicios AEAT del usuario.
Siguiente fase: 04 debe usar exclusivamente el contrato anterior para corregir el agrupamiento de `GenerarDesgloseJson`; su salida sustituirá `contexto-04.md`.
