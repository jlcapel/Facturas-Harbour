# Contexto fase 10

Estado: COMPLETADA.
Ficheros modificados: `src/db/FacturaService.prg`, `src/services/VeriFactuService.prg`, `src/views/FacturasView.prg`, `tests/prueba_alta_atomica.prg`, `tests/prueba_cadenas_timestamps.prg` y este contexto.
Pruebas ejecutadas: `prueba_alta_atomica.prg` con BD temporal y doble AEAT, cubriendo documento R5, original inmutable, doble anulación, fallo de registro y rollback; `prueba_cadenas_timestamps.prg`; `./build.sh`; `./build.sh win`; todas correctas.
Decisiones clonadas de .NET: la original conserva `Estado=Emitida`; `AnularFactura` crea otra `Factura` con `TipoFactura=Anulacion`, `AeatTipoFactura=R5`, relación `FacturaRectificadaId`, líneas e importes negativos, snapshot tipo 1 y registro de anulación enlazado a esa nueva factura y versión; AEAT y evento se ejecutan tras `COMMIT`.
Riesgos o pendientes: .NET genera el hash R5 con IVA/total fiscales originales, pero persiste base/IVA negativos en el registro; su verificador genérico tampoco revalida ese caso. La prueba comprueba los enlaces `HashAnterior` e `IdRegistroAnterior` sin cambiar ese contrato. La fase 11 no debe modificar este flujo.
Siguiente paso permitido: fase 11 puede tocar exclusivamente NTP, backup/WAL, `VeriFactuService`, `database.prg` y pruebas; debe consultar los métodos .NET de hora/backup y usar sólo rutas temporales.
