# Protocolo manual AEAT en preproducción

No ejecutar este protocolo desde pruebas automáticas ni con datos productivos.

1. Preparar una copia de la BD y configurar el ambiente `Preproduccion`.
2. Indicar un certificado de pruebas autorizado, sin registrar su ruta, contraseña ni contenido como evidencia.
3. Crear un cliente y una factura de importe mínimo con datos ficticios permitidos por AEAT.
4. Enviar el alta desde la aplicación y anotar fecha/hora, número de factura de pruebas, resultado y CSV devuelto.
5. Verificar que el registro conserva el XML/resultado, `EnviadoAEAT=1`, CSV y la fecha de envío; conservar captura o exportación redactada.
6. Ejecutar la consulta de estado para el mismo registro y conservar el resultado redactado.
7. Crear la anulación correspondiente, enviarla y conservar su CSV y respuesta redactada.
8. Ante rechazo, conservar código y descripción sin NIF, certificado ni respuesta completa; no reintentar hasta clasificar el error.

Resultado esperado: altas y anulaciones válidas devuelven CSV, se marcan como enviadas y mantienen la cadena fiscal. La evidencia mínima es versión ejecutable, fecha/hora, ambiente, identificador de prueba anonimizado, CSV anonimizado, resultado y operador.
