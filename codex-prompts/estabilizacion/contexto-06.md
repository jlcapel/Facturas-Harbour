# Contexto fase 06

Estado: COMPLETADA.
Ficheros modificados: `src/services/AeatClientService.prg`, `tests/prueba_aeat_tls.prg` y este contexto.
Pruebas ejecutadas: `prueba_aeat_tls.prg` sin red, `./build.sh`, `./build.sh win` y búsqueda de opciones TLS, todas correctas.
Decisiones clonadas de .NET: antes del envío se exige entorno reconocido y fichero de certificado existente; la contraseña vacía no bloquea la preparación del certificado P12.
Decisiones clonadas de .NET: los fallos de certificado o transporte devuelven un resultado controlado, se registran en el log y generan `ErrorEnvioAEAT`.
Decisiones clonadas de .NET: producción y preproducción usan exclusivamente los endpoints oficiales de la referencia.
Riesgos o pendientes: no se carga ni valida criptográficamente un P12 durante pruebas locales; esa validación queda en libcurl al enviar con un certificado real, sin desactivar TLS.
Siguiente paso permitido: fase 07 puede corregir la asignación de CSV y estado de envío a partir de respuestas SOAP locales.
