# Contexto fase 08

Estado: COMPLETADA.
Ficheros modificados: `src/db/FacturaService.prg`, `src/services/VeriFactuService.prg`, `tests/prueba_alta_atomica.prg` y este contexto.
Pruebas ejecutadas: `prueba_alta_atomica.prg` con BD temporal y doble AEAT, cubriendo éxito, número duplicado y fallo de línea, snapshot, registro y evento; `./build.sh`; `./build.sh win`; todas correctas.
Decisiones clonadas de .NET: la alta persiste factura y líneas, snapshot `FacturasVersionesFiscales`, desgloses operativos/fiscales y registro enlazado antes de confirmar; el envío AEAT ocurre después del `COMMIT`.
Riesgos o pendientes: el evento local se mantiene dentro de la transacción por el objetivo de esta fase; las operaciones AEAT posteriores no revierten la factura ya confirmada, como en la referencia. La corrección no se implementó.
Siguiente paso permitido: fase 09 puede usar `CrearVersionFiscalAlta`, `CrearRegistroAlta` y el esquema de versiones para crear un registro sustitutivo sin modificar la factura emitida.
