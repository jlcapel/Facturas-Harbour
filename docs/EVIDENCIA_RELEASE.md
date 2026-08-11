# Evidencia de release 1.0.15

`VERIFICADO` requiere una ejecución o inspección registrada. `NO VERIFICADO` significa que falta la prueba indicada. `BLOQUEADO` requiere una condición externa antes de continuar.

| Área | Estado | Evidencia disponible | Evidencia ausente |
|---|---|---|---|
| Contrato .NET | VERIFICADO | `codex-prompts/estabilizacion/contrato-dotnet.md` fija el commit `f611291b3ea5bea8c1ba5a3261b7a9cc5c17` y los métodos/pruebas de referencia. | Ninguna para identificar el contrato. |
| Migraciones SQLite | VERIFICADO | `prueba_migraciones_esquema.prg` se ejecutó con BD temporal vacía y previa, incluyendo conservación de cadena, índice y FK. | Ejecución sobre una copia de una BD real representativa. |
| Prueba fiscal aislada | VERIFICADO | `scripts/tests/ejecutar_fiscales.sh` pasó en `/tmp`: apertura SQLite, esquema mínimo y cálculo de IVA. | Suite completa en instalación limpia. |
| Reglas fiscales críticas | VERIFICADO | Se ejecutaron pruebas temporales de hash/QR, campos fiscales, cadenas, alta/subsanación/anulación atómicas, TLS local y migraciones. | Validación independiente de resultados fiscales en entorno de producción. |
| Build Linux GTK3 | VERIFICADO | `./build.sh` generó `./Facturas`. | Arranque y recorrido manual en un equipo Linux limpio. |
| Build Windows x64 | VERIFICADO | `./build.sh win` generó `./Facturas.exe`. | Ejecución del binario en Windows. |
| SOAP AEAT sin red | VERIFICADO | `prueba_soap_aeat.prg` cubrió alta, anulación, consulta, XML, CSV, errores y certificado ausente con dobles locales. | Intercambio con preproducción usando certificado de prueba. |
| UI GTK3/Linux | NO VERIFICADO | Existe `codex-prompts/estabilizacion/matriz-ui.md`. | Ejecución completa de la matriz en GTK3/Linux. |
| UI WinAPI/Windows | NO VERIFICADO | Existe `codex-prompts/estabilizacion/matriz-ui.md`. | Ejecución completa de la matriz en WinAPI/Windows. |
| Backup y NTP | VERIFICADO | `prueba_backup_ntp.prg` registró respuesta NTP sintética, WAL abierto, integridad, retención y restauración en `/tmp`. | Restauración y apertura de carpetas en ambos sistemas operativos. |
| PDF | NO VERIFICADO | El binario compila con `hbhpdf`. | Generación, apertura y revisión visual de PDF en Linux y Windows. |
| Paquete Debian x86_64 | VERIFICADO | Se generó y extrajo `Facturas-Harbour_1.0.15_amd64.deb`; contiene binario, licencia, README y `libharbour.so.3.2`, resuelta mediante RUNPATH. | Instalación y desinstalación en equipo limpio. |
| Instalador NSIS Windows x64 | NO VERIFICADO | Script y comprobación de prerrequisitos disponibles. | Instalar `makensis`, generar instalador y validar instalación/desinstalación en Windows. |
| Preproducción AEAT | NO VERIFICADO | Protocolo manual sin red en `protocolo-preproduccion-aeat.md`. | Envío y consulta con certificado de prueba, CSV y evidencia conservada. |
| Release de producción | BLOQUEADO | No hay activación AEAT ni aprobación de release. | Todas las filas pendientes, decisión del responsable y evidencia de preproducción. |

No se debe activar AEAT en producción con esta evidencia. Los paquetes no incluyen certificados, configuraciones AEAT ni bases de datos de usuario; las desinstalaciones deben conservar los datos de la aplicación.
