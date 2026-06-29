<!--
Facturas-Harbour — App de facturación VERI*FACTU (España)
Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
Licensed under GPLv3. Commercial license available.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
-->

# Facturas — App de facturación VERI*FACTU (Harbour + HWGUI)

NO inventar nada. Toda la funcionalidad se clona del proyecto Facturas .NET (Avalonia) en `/home/jose/programacion/Facturas/`. Lo que no esté en esos fuentes no existe.

## Stack

- Harbour (core) desde fuente — https://github.com/harbour/core
- HWGUI para GUI — svn://svn.code.sf.net/p/hwgui/code/trunk (WinAPI en Windows, GTK2 en Linux)
- MinGW-w64 para cross-compilación a Windows desde Linux
- SQLite3 via contrib `hbsqlit3`
- PDF via contrib `hbhpdf` (Haru PDF)
- HTTP/SOAP via contrib `hbcurl` (libcurl)
- XML via contrib `hbmxml` (Mini-XML)
- JSON via contrib `hbjson`
- SHA-256 via `hb_sha256()` built-in
- QR via contrib `hbzebra`
- ZIP via contrib `hbziparc`

## Ejecutar

```bash
cd Facturas-Harbour
./build.sh
```

## Toolchain instalada

| Componente | Versión | Ruta |
|---|---|---|
| Harbour | 3.2.0dev (r2605141250) | `/usr/local/bin/harbour` |
| hbmk2 | 3.2.0dev | `/usr/local/bin/hbmk2` |
| HWGUI (Linux GTK3) | r3824 | `/usr/local/lib/harbour/libhwgui.a` |
| MinGW-w64 | 13-win32 | `/usr/bin/x86_64-w64-mingw32-gcc` |

Dependencias del sistema instaladas: cmake, libsqlite3-dev, libcurl4-openssl-dev, libgtk-3-dev, libqrencode-dev, libhpdf-dev, libpng-dev, libssl-dev, subversion.

**Nota:** hbmk2 filtra `-lm` de ldflags. El script `build.sh` compila .prg → .c → .o manualmente y enlaza con `-lm` dentro de `--start-group`.

## Base de datos

- Ruta: `~/Facturas/facturas.db` (el proyecto .NET usa `~/.local/share/Facturas/facturas.db`)
- Esquema SQLite idéntico al proyecto .NET (modelos, columnas, tipos)
- Seed de paises (~27), tipos de identificación (6), tipos de IVA (6), configuración básica
- Si se añaden columnas: ALTER TABLE manual con sqlite3
- SQLite almacena decimal como TEXT — usar CAST en consultas SQL directas
- Excepción típica: decimal en ORDER BY → castear a REAL

## Modelos (11 + 4 secundarios)

Extraídos literalmente de `Facturas/Models/`:

### Core VERI*FACTU (8)
| Modelo | Propiedades clave |
|---|---|
| `Cliente` | Nombre, Nif, NifIva, TipoCliente, Pais, TipoIdentificacion |
| `Articulo` | Codigo (único), Descripcion, PrecioUnitario, TipoIva |
| `Factura` | NumeroFactura, FechaEmision, Cliente, BaseImponible, IvaImporte, IrpfPorcentaje, IrpfImporte, Total, Lineas, RegistroFacturacion |
| `LineaFactura` | Factura, Articulo, Descripcion, Cantidad, PrecioUnitario, IvaPorcentaje, Importe, TipoIva |
| `RegistroFacturacion` | Hash (SHA-256), HashAnterior, NifEmisor, NumeroFactura, BaseImponible, IvaImporte, Total |
| `RegistroEvento` | TipoEvento, Descripcion, Hash, HashAnterior |
| `Configuracion` | Clave (única), Valor |
| `TipoIva` | Nombre, Porcentaje, FechaInicio, FechaFin |
| `Pais` | Codigo (único, 2 letras), Nombre, Nacionalidad, EsUE |
| `TipoIdentificacion` | CodigoAEAT (único), Nombre |

### Secundarios (4)
| Modelo | Propiedades clave |
|---|---|
| `Proveedor` | Nombre, Nif, NifIva, Pais, TipoIdentificacion, IBAN |
| `Gasto` | NumeroFactura, FechaEmision, Proveedor, CategoriaGasto, BaseImponible, IvaPorcentaje, IvaImporte, RetencionPorcentaje, RetencionImporte, Total |
| `CategoriaGasto` | Nombre, PorcentajeDeducibleIRPF, IvaDeducible |
| `BienInversion` | Nombre, FechaAdquisicion, ValorAdquisicion, PorcentajeUsoActividad, AmortizacionAnual |

### Enumeraciones
- `TipoCliente`: Nacional, Intracomunitario, Extracomunitario
- `TipoFactura`: Normal, Rectificativa, Anulacion
- `EstadoFactura`: Emitida, Anulada
- `TipoRegistro`: Alta, Anulacion, Sustitutivo
- `TipoEvento`: Login, CreacionFactura, AnulacionFactura, ModificacionDatos, Exportacion, EnvioAEAT, Error, ErrorEnvioAEAT, RecepcionCSV, Subsanacion, ReintentoEnvioAEAT
- `MedioPago`: Efectivo, Transferencia, Tarjeta, Domiciliacion, Otro
- `TipoGastoDocumento`: Factura, TicketSimplificada, Recibo, DUA, Otro

## Servicios (clonar de Facturas/Services/)

| Servicio | Rol |
|---|---|
| `ConfiguracionService` | Obtener/Establecer clave-valor en BD |
| `VeriFactuService` | Hash oficial AEAT, creación registros alta/anulación, desglose TipoIva, cadena bloques |
| `EventoService` | Registro de eventos con hash chain |
| `QRService` | Generación código QR |
| `NifValService` | Validación NIF contra censo AEAT vía VNifV2 |
| `ValidacionIdentificacionService` | Validación DNI/NIE/CIF + 27 UE VAT |
| `FacturaService` | CRUD facturas: crear (con hash AEAT + envío SOAP), anular, obtener |
| `ClienteService` | CRUD clientes |
| `ArticuloService` | CRUD artículos |
| `TipoIvaService` | CRUD tipos IVA |
| `PaisService` | CRUD paises |
| `TipoIdentificacionService` | CRUD tipos identificación |
| `ProveedorService` | CRUD proveedores |
| `CategoriaGastoService` | CRUD categorías de gasto |
| `BienInversionService` | CRUD bienes de inversión |
| `GastoService` | CRUD gastos con cálculo IVA/retención, marcar pagado |
| `AeatClientService` | Cliente SOAP XML a AEAT (pre/producción), parseo respuesta CSV |
| `InvoicePdfService` | Generación PDF A4 con cabecera, cliente, líneas, totales, IRPF |
| `ExportacionService` | Exportación XML de registros |
| `ExportacionCsvService` | Exportación CSV de gastos |
| `Logger` | Log a archivo en `~/.local/share/Facturas/logs/` |

## VERI*FACTU (extraído de AeatConstants.cs y VeriFactuService.cs)

### Hash oficial AEAT
Formato: `IDEmisorFactura={NIF}&NumSerieFactura={NumSerie}&FechaExpedicionFactura={DD-MM-YYYY}&TipoFactura={TipoFactura}&CuotaTotal={Cuota:F2}&ImporteTotal={Total:F2}&Huella={HashAnterior}&FechaHoraHusoGenRegistro={yyyy-MM-ddTHH:mm:ssK}`

SHA-256 → HEX uppercase. El Total del hash es el total FISCAL (Base + IVA), SIN incluir retención IRPF. Usar punto decimal siempre (no coma).

### Cadena de bloques
Cada registro de facturación se encadena: el hash incluye el hash del registro anterior. `ObtenerUltimoHash()` busca el último registro por Id. `VerificarCadena()` recorre todos los registros y recalcula hashes.

### Desglose
Agrupado por TipoIva: Impuesto="01", CalificacionOperacion="S1". Se serializa como JSON en `RegistroFacturacion.Desglose`.

### QR
URL: `https://www.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR?nif=...&numserie=...&fecha=...&importe=...`
El importe del QR es el total FISCAL (Base+IVA), sin IRPF.

### Endpoints AEAT
- Preproducción: `https://prewww2.aeat.es/wlpl/TIKE-CONT/...`
- Producción: `https://www.agenciatributaria.gob.es/wlpl/TIKE-CONT/...`

### Tipos de factura AEAT
- `F1`: Factura ordinaria
- `R1`, `R2`, `R3`, `R4`: Factura rectificativa
- `S`: Rectificación por sustitución
- `I`: Rectificación por diferencias

## IRPF (Retención)

- Porcentaje configurable en Empresa → Configuración VERI*FACTU (default 15%)
- Se persiste por factura: cambiar config global NO afecta facturas existentes
- Cálculo: `IrpfImporte = BaseImponible × IrpfPorcentaje / 100`
- Total a cobrar: `BaseImponible + IvaImporte − IrpfImporte`
- El hash AEAT y QR usan `TotalFiscal = BaseImponible + IvaImporte` (sin IRPF)
- La retención NO es parte del registro VERI*FACTU (solo menciones voluntarias en la factura impresa)

## Cálculos (extraídos de NumericHelper.cs)

```
Importe línea = Cantidad × PrecioUnitario
BaseImponible = Σ Importe líneas
IvaImporte = Σ (Importe × IvaPorcentaje / 100)
IrpfImporte = BaseImponible × IrpfPorcentaje / 100
Total = BaseImponible + IvaImporte − IrpfImporte
```

## PDF (Haru PDF via hbhpdf)

- A4 con: cabecera emisor (nombre, nif, dirección), datos cliente, tabla líneas, totales (Base, IVA, IRPF, Total)
- Se guarda en `/tmp/Facturas/{numero}.pdf` y abre con visor del SO

## Convenciones de código

- Sin comentarios en el código (excepto AGENTS.md y ADRs)
- Nombres de variables, funciones, métodos y clases en español (dominio del problema)
- Funciones sin prefijo: `CrearCliente()`, `CalcularHash()`, `ObtenerUltimoHash()`
- Logger.Error() en catches; no re-lanzar excepciones en UI
- Las vistas (HWGUI) NO tienen lógica de negocio; solo eventos de botones y doble click
- NO inventar nada: toda funcionalidad nueva debe existir primero en el proyecto .NET

## Vistas HWGUI

| Vista | Archivo | CRUD |
|---|---|---|
| Países | `src/views/PaisesView.prg` | Crear, editar, desactivar |
| Tipos IVA | `src/views/TiposIvaView.prg` | Crear, editar, eliminar |
| Tipos Identificación | `src/views/TiposIdentificacionView.prg` | Crear, editar, desactivar |
| Clientes | `src/views/ClientesView.prg` | Crear, editar (con combos país/tipo ID), eliminar |
| Artículos | `src/views/ArticulosView.prg` | Crear, editar (con combo tipo IVA), eliminar |
| Empresa/Configuración | `src/views/EmpresaView.prg` | Empresa, Veri*Factu, IVA, IRPF |
| Facturas | `src/views/FacturasView.prg` | Listado + imprimir PDF + anular |
| Factura (edición) | `src/views/FacturaEditView.prg` | Cabecera + líneas editables + totales |
| Proveedores | `src/views/ProveedoresView.prg` | Crear, editar (con combos país/tipo ID), eliminar |
| Categorías Gasto | `src/views/CategoriasGastoView.prg` | Crear, editar, eliminar |
| Bienes Inversión | `src/views/BienesInversionView.prg` | Crear, editar, eliminar |
| Gastos | `src/views/GastosView.prg` | Listado + marcar pagado/no pagado |
| Gasto (edición) | `src/views/GastoEditView.prg` | Proveedor, categoría, importes, IVA/retención |

Estilo de ventana principal: `WS_DLGFRAME + WS_SYSMENU + DS_CENTER` (no `WS_POPUP` — no funciona con Cinnamon).

## Estado del proyecto

| Hito | Estado | Descripción |
|---|---|---|---|
| Hito 1 | ✅ | Toolchain multiplataforma (Linux + Windows) |
| Hito 2 | ✅ | BD SQLite (15 tablas + seed) + servicios básicos |
| Hito 3 | ✅ | CRUD maestros: 6 ventanas HWGUI + 2 servicios |
| Hito 4 | ✅ | Facturas + PDF + VERI*FACTU (UI + PDF + SOAP completo) |
| Hito 5 | ✅ | Exportación XML/CSV + Logger: 4 servicios + menu exportar |
| Hito 6 | ✅ | Gastos + Secundarios: 4 servicios DB + 6 vistas HWGUI |

## Problemas conocidos (del proyecto .NET)

1. **Culture decimal**: es_ES usa coma decimal. El hash AEAT y URL QR usan punto siempre. NO usar transformación de decimal con coma en cálculos que generen hash o URLs.
2. **SQLite decimal**: SQLite mapea decimal como TEXT. Usar CAST(columna AS REAL) en SQL directo.
3. **Schema drift**: La BD se crea en el primer arranque. Si el modelo cambia (nuevas columnas), hay que añadirlas con ALTER TABLE o borrar la BD.
4. **Sin migraciones**: No hay migraciones automáticas. EnsureCreated() no existe en Harbour — crear tablas manualmente en primer arranque.
5. **CHECKBOX HWGUI**: se usa `@ x, y CHECKBOX <var> CAPTION "..." SIZE w, h` (NO `@ x, y GET <var> CHECKBOX`).
6. **@ en múltiples líneas**: cada control `@ x, y` debe ir en su propia línea (no separar con `;`).
