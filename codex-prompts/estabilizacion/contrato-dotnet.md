# Contrato de referencia .NET

- Commit: `f611291b3ea5bea8c1ba5a3261b7a9cc5c17`.
- Estado: sucio en `Facturas/Services/Licencias/LicenciaClavePublicaProvider.cs`; `licencias_1/` y `licencias_2/` sin seguimiento. Ninguno pertenece a los objetivos de esta cadena.

| Objetivo | Fichero .NET | Método .NET | Prueba .NET |
|---|---|---|---|
| Alta | `Facturas/Services/FacturaService.cs` | `CrearFactura`; `VeriFactuService.CrearRegistroAlta` | `Facturas.Tests/FacturaServiceLey11Tests.cs`: `CrearFactura_PersisteDesgloseIvaOperativoYFiscal` |
| Corrección o subsanación | `Facturas/Services/FacturaService.cs` | `SubsanarFactura`; `VeriFactuService.CrearRegistroSustitutivo` | `Facturas.Tests/FacturaServiceLey11Tests.cs`: `SubsanarFactura_NoCambiaLineasNiImportesOriginales_YCreaVersionFiscal` |
| Anulación | `Facturas/Services/FacturaService.cs` | `AnularFactura`; `VeriFactuService.CrearRegistroAnulacion` | `Facturas.Tests/FacturaServiceLey11Tests.cs`: `AnularFactura_ConservaFacturaOriginal_YCreaRegistroAnulacion` |
| Hash | `Facturas/Services/VeriFactuService.cs` | `CalcularHash` | `Facturas.Tests/VeriFactuServiceTests.cs`: `CalcularHash_CadenaOficial_ValorDeterminista` |
| QR | `Facturas/Services/QRService.cs` | `GenerarUrlVerificacion` | `Facturas.Tests/QRServiceTests.cs`: `GenerarUrlVerificacion_FormatoCorrecto`; `GenerarUrlVerificacion_Produccion` |
| Desglose | `Facturas/Services/VeriFactuService.cs` | `GenerarDesgloseJson` | `Facturas.Tests/VeriFactuServiceTests.cs`: `GenerarDesgloseJson_UsaCalificacionDelTipoIva`; `GenerarDesgloseJson_UsaOperacionExentaCongelada` |
| Cadenas | `Facturas/Services/VeriFactuService.cs`; `Facturas/Services/EventoService.cs` | `VerificarCadena`; `VerificarCadenaEventos` | `Facturas.Tests/VeriFactuServiceTests.cs`: `VerificarCadena_SqliteRoundtripFechaUtcSinKind_Valida`; `Facturas.Tests/EventoServiceTests.cs`: `VerificarCadenaEventos_DetectaEventoModificado` |
| SOAP | `Facturas/Services/AeatClientService.cs` | `ConfigurarCertificado`; `EnviarRegistroAlta`; `ConstruirSoap` | `Facturas.Tests/AeatClientServiceTests.cs`: `ConstruirSoap_AltaIncluyeEnvelopeRegistroYSistemaInformatico`; `ProcesarRespuesta_ConCsvMarcaRegistroComoEnviado` |
| NTP | `Facturas/Services/NtpService.cs` | `ObtenerFechaHoraOficial` | SIN PRUEBA |
| Backup | `Facturas/Services/Utils.cs`; `Facturas/Data/AppDbContext.cs` | `HacerBackupDb`; `RestaurarBackup`; `CrearBackupSqlite`; `SuspenderBackupAutomatico` | `Facturas.Tests/BackupConservacionTests.cs`: `HacerBackupDb_CreaManifestConHashValido`; `RestaurarBackup_CopiaBackupValidoYVerificaIntegridad` |
| PDF | `Facturas/Services/InvoicePdfService.cs` | `GenerarPdf` | `Facturas.Tests/FacturaPdfPlantillaTests.cs`: `InvoicePdfService_FormatoFijo_IgnoraPlantillaActiva` |
| Esquema | `Facturas/Services/SchemaCompatibilityService.cs`; `Facturas/Data/AppDbContext.cs` | `Asegurar`; `OnModelCreating` | `Facturas.Tests/SchemaCompatibilityServiceTests.cs`: `Asegurar_RecreaConfiguracionSiFaltaEnBdExistente`; `TiposIvaSchemaTests.cs`: `AsegurarEsquemaManual_CreaTablasDesgloseIva` |

Estados fiscales diferenciados: alta genera factura emitida; subsanación conserva original y crea versión fiscal; anulación conserva original y crea registro de anulación.
