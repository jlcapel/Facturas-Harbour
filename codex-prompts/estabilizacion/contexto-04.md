# Contexto fase 04

Estado: COMPLETADA.
Ficheros modificados: `src/services/VeriFactuService.prg`, `tests/prueba_desglose_iva.prg` y este contexto.
Pruebas ejecutadas: `prueba_desglose_iva.prg`, `scripts/tests/ejecutar_fiscales.sh`, `./build.sh`, `./build.sh win` y `git diff --check`, todas correctas.
Decisiones clonadas de .NET: `CalculoFacturaService.Calcular` agrupa por TipoIvaId, porcentaje, impuesto, clave, calificación y exenta; suma importes, suma IVA redondeado por línea, redondea el grupo y ordena por esos campos.
Decisiones clonadas de .NET: `CrearDesgloseJson` emite siempre TipoIvaId, TipoIvaNombre, Impuesto, ClaveRegimen, CalificacionOperacion, OperacionExenta, TipoImpositivo, BaseImponibleOimporteNoSujeto y CuotaRepercutida.
Riesgos o pendientes: en una línea nueva `TipoIvaNombre` puede ser NIL porque el contrato Harbour no lo rellena antes de persistir; no afecta a los campos fiscales ni se modificó fuera del alcance de la fase.
Siguiente paso permitido: fase 05 puede corregir las cadenas y timestamps; debe mantener el hash y el desglose ya validados.
