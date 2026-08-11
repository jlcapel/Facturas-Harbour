# Contexto fase 03
Estado: COMPLETA.
Ficheros modificados: `src/utils/DateUtils.prg`, `src/services/VeriFactuService.prg`, `src/services/QRService.prg`, `tests/prueba_humo.prg`, `tests/prueba_hash_qr.prg`, `contexto-03.md`.
Pruebas ejecutadas: vector directo `hbmk2`/`hbtest` de hash y QR; `./scripts/tests/ejecutar_fiscales.sh`; `./build.sh`; `./build.sh win`; `git diff --check`.
Decisiones clonadas de .NET: `CalcularHash` usa F2 invariante, total fiscal sin IRPF y UTC `Z`; `GenerarUrlVerificacion` escapa NIF y número de serie y usa base+IVA F2.
Vectores validados: hash `5CCF8FE789742FE35E5F340B789C38DA7569EC697C7D8AD1FF28250140726457`; URLs QR de preproducción y producción de `QRServiceTests.cs`.
El arnés usa `ErrorLevel()` para devolver código no cero ante una aserción fallida.
Para desglose: `Facturas/Services/VeriFactuService.cs:GenerarDesgloseJson` delega en `CalculoFacturaService.Calcular` y `CrearDesgloseJson`.
Pruebas .NET: `VeriFactuServiceTests.cs:GenerarDesgloseJson_UsaCalificacionDelTipoIva`, `GenerarDesgloseJson_UsaOperacionExentaCongelada`; `CalculoFacturaServiceTests.cs:Calcular_AgrupaVariosTiposIva_YCalculaTotales`, `Calcular_NoAgrupaTiposCeroConDistintaClasificacion`.
Contrato Harbour: `FacturaEditView.prg:LineaEditDialog` devuelve `{FacturaId,ArticuloId,TipoIvaId,Descripcion,Cantidad,PrecioUnitario,IvaPorcentaje,Importe,DescuentoPorcentaje,DescuentoImporte}`.
`src/db/FacturaService.prg:CrearFactura` calcula con importe `[8]` e IVA `[7]`; no cambiar esos índices ni la vista.
Riesgos o pendientes: el desglose actual usa `[7]` como tipo y `[5]/[6]` para base/IVA; debe sustituirse en fase 04 con prueba estructural.
Siguiente paso permitido: ejecutar únicamente `fase-04.md`.
