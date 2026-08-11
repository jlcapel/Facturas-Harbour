# Contexto fase 09

Estado: COMPLETADA.
Ficheros modificados: `src/db/FacturaService.prg`, `src/services/VeriFactuService.prg`, `src/views/FacturasView.prg`, `src/views/FacturaEditView.prg`, `tests/prueba_alta_atomica.prg` y este contexto.
Pruebas ejecutadas: `prueba_alta_atomica.prg` con BD temporal y doble AEAT, cubriendo subsanación, inmutabilidad de factura/líneas, versión y registro sustitutivos, cadena y rollback; `./build.sh`; `./build.sh win`; todas correctas.
Decisiones clonadas de .NET: `SubsanarFactura` mantiene `Facturas` y `LineasFactura`, crea versión y registro con `TipoRegistro=2`, `TipoRectificativa='S'`, `Subsanacion='S'` e `ImporteRectificacion` originales, y envía AEAT tras `COMMIT`; `FacturasSubsanar` abre el diálogo de snapshot, rechaza edición normal y las consultas usan sólo el alta (`TipoRegistro=0`) para no duplicar filas.
Riesgos o pendientes: la anulación actual sigue siendo el flujo anterior y no se ha tocado. `CrearRegistroAnulacion` aún no enlaza una versión fiscal ni garantiza transacción; debe sustituirse en fase 10.
Siguiente paso permitido: fase 10 debe clonar `FacturaService.AnularFactura` y `VeriFactuService.CrearRegistroAnulacion` de .NET, crear documento/registro R5 atómicos sin reutilizar un `FacturaId` prohibido y no modificar `SubsanarFactura`.
