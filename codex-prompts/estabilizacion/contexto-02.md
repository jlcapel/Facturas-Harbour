# Contexto fase 02
Estado: COMPLETA.
Ficheros modificados: `tests/prueba_humo.prg`, `scripts/tests/ejecutar_fiscales.sh`, `contexto-02.md`.
Pruebas ejecutadas: `./scripts/tests/ejecutar_fiscales.sh` (SQLite temporal, cinco aserciones); `./build.sh`.
Decisiones clonadas de .NET: la prueba numérica usa la cuota 21 sobre base 100 de `Facturas.Tests/CalculoFacturaServiceTests.cs:Calcular_AgrupaVariosTiposIva_YCalculaTotales`.
El arnés compila `src/utils/NumericHelper.prg`, usa `hbtest` y `hbsqlit3`, y elimina solo su directorio creado con `mktemp` bajo `/tmp`.
Para hash: `Facturas/Services/VeriFactuService.cs:CalcularHash`; pruebas `VeriFactuServiceTests.cs:CalcularHash_FormatoCorrecto`, `CalcularHash_CadenaOficial_ValorDeterminista`, `CalcularHash_SinIRPF` y `CalcularHash_ConHashAnterior`.
Para QR: `Facturas/Services/QRService.cs:GenerarUrlVerificacion`; pruebas `QRServiceTests.cs:GenerarUrlVerificacion_FormatoCorrecto` y `GenerarUrlVerificacion_Produccion`.
Invariantes: hash y QR usan total fiscal base+IVA, excluyen IRPF, importes F2 con punto sin relleno y hash SHA-256 hexadecimal en mayúsculas.
Riesgos o pendientes: el arnés aún solo cubre humo; los vectores fiscales se añaden en las fases siguientes.
Siguiente paso permitido: ejecutar únicamente `fase-03.md`.
