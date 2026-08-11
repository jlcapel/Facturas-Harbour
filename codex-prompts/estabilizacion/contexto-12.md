# Contexto fase 12

Estado: COMPLETADA.
Ficheros modificados: `src/services/AeatClientService.prg`, `src/services/Helpers.prg`, `tests/prueba_soap_aeat.prg`, `codex-prompts/estabilizacion/protocolo-preproduccion-aeat.md` y este contexto.
Pruebas ejecutadas: `prueba_soap_aeat.prg` sin red, con fixtures de `AeatClientServiceTests`: alta, anulación, consulta, escape XML, operación exenta, decimales con punto, CSV, error AEAT con namespace, HTML, respuesta desconocida y certificado ausente; `./build.sh`, `./build.sh win` y `git diff --check`, correctos.
Decisiones clonadas de .NET: `ConstruirSoap` crea los tres namespaces y transforma JSON de destinatarios, desglose, encadenamiento y sistema informático a XML; `OperacionExenta` excluye `CalificacionOperacion`; importes se emiten con dos decimales y punto; la respuesta prioriza HTML, CSV, errores XML y mensaje de respuesta desconocida.
Riesgos o pendientes: el protocolo `protocolo-preproduccion-aeat.md` queda sólo para ejecución manual autorizada; no se invocó AEAT, no hay certificados ni datos reales. La fase 13 no debe tocar SOAP, NTP o backup.
Siguiente paso permitido: fase 13 puede investigar el error HWGUI `No exported method: EVAL` con BD temporal, revisar `Error.log`, `main.prg` y HWGUI, y crear la matriz UI sin llamar a AEAT, NIF ni VIES.
