#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerDbPath()
   LOCAL cHome := hb_GetEnv("HOME")
   RETURN cHome + "/Facturas/facturas.db"

FUNCTION AbrirBaseDatos()
   LOCAL cPath := ObtenerDbPath()
   LOCAL cDir := hb_FNameDir(cPath)
   IF !hb_DirExists(cDir)
      hb_DirBuild(cDir)
   ENDIF
   RETURN sqlite3_open(cPath, .T.)

FUNCTION InicializarBaseDatos()
   LOCAL db := AbrirBaseDatos()
   IF Empty(db)
      RETURN .F.
   ENDIF
   CrearTablas(db)
   SembrarDatosIniciales(db)
   db := NIL
   RETURN .T.

STATIC FUNCTION CrearTablas(db)

   sqlite3_exec(db, "PRAGMA journal_mode=WAL")
   sqlite3_exec(db, "PRAGMA foreign_keys=ON")

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Paises( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Codigo TEXT(2) NOT NULL UNIQUE, " + ;
      "Nombre TEXT(100) NOT NULL, " + ;
      "Nacionalidad TEXT(100), " + ;
      "EsUE INTEGER NOT NULL DEFAULT 0, " + ;
      "Activo INTEGER NOT NULL DEFAULT 1 )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS TiposIdentificacion( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "CodigoAEAT TEXT(10) NOT NULL UNIQUE, " + ;
      "Nombre TEXT(100) NOT NULL, " + ;
      "Activo INTEGER NOT NULL DEFAULT 1 )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS TiposIva( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Nombre TEXT(50) NOT NULL, " + ;
      "Porcentaje TEXT NOT NULL, " + ;
      "Activo INTEGER NOT NULL DEFAULT 1, " + ;
      "FechaInicio TEXT NOT NULL, " + ;
      "FechaFin TEXT )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Configuracion( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Clave TEXT(50) NOT NULL UNIQUE, " + ;
      "Valor TEXT(500) )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Clientes( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Nombre TEXT(200) NOT NULL, " + ;
      "TipoCliente INTEGER NOT NULL DEFAULT 0, " + ;
      "PaisId INTEGER REFERENCES Paises(Id) ON DELETE SET NULL, " + ;
      "TipoIdentificacionId INTEGER REFERENCES TiposIdentificacion(Id) ON DELETE SET NULL, " + ;
      "Nif TEXT(30) NOT NULL, " + ;
      "NifIva TEXT(30), " + ;
      "Direccion TEXT(200), " + ;
      "Poblacion TEXT(100), " + ;
      "Provincia TEXT(50), " + ;
      "CodigoPostal TEXT(10), " + ;
      "Telefono TEXT(50), " + ;
      "Email TEXT(200), " + ;
      "Activo INTEGER NOT NULL DEFAULT 1 )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Articulos( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Codigo TEXT(50) NOT NULL UNIQUE, " + ;
      "Descripcion TEXT(300) NOT NULL, " + ;
      "PrecioUnitario TEXT NOT NULL, " + ;
      "UnidadMedida TEXT(20), " + ;
      "Activo INTEGER NOT NULL DEFAULT 1, " + ;
      "TipoIvaId INTEGER REFERENCES TiposIva(Id) ON DELETE SET NULL )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Facturas( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "NumeroFactura TEXT(20) NOT NULL UNIQUE, " + ;
      "FechaEmision TEXT NOT NULL, " + ;
      "FechaOperacion TEXT, " + ;
      "ClienteId INTEGER NOT NULL REFERENCES Clientes(Id) ON DELETE RESTRICT, " + ;
      "TipoFactura INTEGER NOT NULL DEFAULT 0, " + ;
      "Estado INTEGER NOT NULL DEFAULT 0, " + ;
      "FacturaRectificadaId INTEGER REFERENCES Facturas(Id) ON DELETE SET NULL, " + ;
      "Descripcion TEXT(500), " + ;
      "AeatTipoFactura TEXT(4) NOT NULL DEFAULT 'F1', " + ;
      "TipoRectificacion TEXT(1), " + ;
      "BaseImponible TEXT NOT NULL, " + ;
      "IvaImporte TEXT NOT NULL, " + ;
      "IrpfPorcentaje TEXT NOT NULL, " + ;
      "IrpfImporte TEXT NOT NULL, " + ;
      "Total TEXT NOT NULL, " + ;
      "DescuentoGlobalPorcentaje TEXT, " + ;
      "DescuentoGlobalImporte TEXT )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS LineasFactura( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "FacturaId INTEGER NOT NULL REFERENCES Facturas(Id) ON DELETE CASCADE, " + ;
      "ArticuloId INTEGER REFERENCES Articulos(Id) ON DELETE SET NULL, " + ;
      "TipoIvaId INTEGER REFERENCES TiposIva(Id) ON DELETE SET NULL, " + ;
      "Descripcion TEXT(300) NOT NULL, " + ;
      "Cantidad TEXT NOT NULL, " + ;
      "PrecioUnitario TEXT NOT NULL, " + ;
      "IvaPorcentaje TEXT NOT NULL, " + ;
      "Importe TEXT NOT NULL, " + ;
      "DescuentoPorcentaje TEXT, " + ;
      "DescuentoImporte TEXT )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS RegistrosFacturacion( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "FacturaId INTEGER NOT NULL UNIQUE REFERENCES Facturas(Id) ON DELETE CASCADE, " + ;
      "TipoRegistro INTEGER NOT NULL DEFAULT 0, " + ;
      "Hash TEXT(64) NOT NULL UNIQUE, " + ;
      "HashAnterior TEXT(64), " + ;
      "FirmaElectronica TEXT(500), " + ;
      "NifEmisor TEXT(9) NOT NULL, " + ;
      "NumeroFactura TEXT(60), " + ;
      "FechaEmision TEXT NOT NULL, " + ;
      "BaseImponible TEXT NOT NULL, " + ;
      "IvaImporte TEXT NOT NULL, " + ;
      "Total TEXT NOT NULL, " + ;
      "IdFacturaAnulada TEXT(60), " + ;
      "FechaFacturaAnulada TEXT, " + ;
      "CSV TEXT(50), " + ;
      "CodigoQR TEXT(500), " + ;
      "FechaRegistro TEXT NOT NULL, " + ;
      "EnviadoAEAT INTEGER NOT NULL DEFAULT 0, " + ;
      "FechaEnvioAEAT TEXT, " + ;
      "RespuestaAEAT TEXT(4000), " + ;
      "IdRegistroAnterior INTEGER UNIQUE REFERENCES RegistrosFacturacion(Id) ON DELETE SET NULL, " + ;
      "IDVersion TEXT, RefExterna TEXT, NombreRazonEmisor TEXT, " + ;
      "Subsanacion TEXT, RechazoPrevio TEXT, " + ;
      "TipoFactura TEXT, TipoRectificativa TEXT, " + ;
      "FacturasRectificadas TEXT, FacturasSustituidas TEXT, " + ;
      "ImporteRectificacion TEXT, FechaOperacion TEXT, DescripcionOperacion TEXT(500), " + ;
      "Desglose TEXT, Encadenamiento TEXT, " + ;
      "SistemaInformatico TEXT, FechaHoraHusoGenRegistro TEXT NOT NULL, " + ;
      "TipoHuella TEXT DEFAULT '01', SinRegistroPrevio TEXT )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS RegistrosEvento( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "TipoEvento INTEGER NOT NULL, " + ;
      "Descripcion TEXT(200) NOT NULL, " + ;
      "Usuario TEXT(50), " + ;
      "FechaHora TEXT NOT NULL, " + ;
      "Hash TEXT(64), " + ;
      "HashAnterior TEXT(64), " + ;
      "IdEventoAnterior INTEGER REFERENCES RegistrosEvento(Id) ON DELETE SET NULL )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Proveedores( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Nombre TEXT(200) NOT NULL, " + ;
      "Nif TEXT(30) NOT NULL, " + ;
      "NifIva TEXT(30), " + ;
      "TipoIdentificacionId INTEGER REFERENCES TiposIdentificacion(Id) ON DELETE SET NULL, " + ;
      "PaisId INTEGER REFERENCES Paises(Id) ON DELETE SET NULL, " + ;
      "Direccion TEXT(200), " + ;
      "Poblacion TEXT(100), " + ;
      "Provincia TEXT(50), " + ;
      "CodigoPostal TEXT(10), " + ;
      "Telefono TEXT(50), " + ;
      "Email TEXT(200), " + ;
      "IBAN TEXT(34), " + ;
      "Activo INTEGER NOT NULL DEFAULT 1 )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS CategoriasGasto( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Nombre TEXT(100) NOT NULL, " + ;
      "PorcentajeDeducibleIRPF TEXT NOT NULL, " + ;
      "IvaDeducible INTEGER NOT NULL DEFAULT 1, " + ;
      "Orden INTEGER NOT NULL, " + ;
      "Activo INTEGER NOT NULL DEFAULT 1 )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS Gastos( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "NumeroFactura TEXT(30) NOT NULL, " + ;
      "NumeroRecepcion INTEGER, " + ;
      "FechaEmision TEXT NOT NULL, " + ;
      "FechaOperacion TEXT, " + ;
      "FechaRecepcion TEXT NOT NULL, " + ;
      "TipoDocumento INTEGER NOT NULL, " + ;
      "ProveedorId INTEGER NOT NULL REFERENCES Proveedores(Id) ON DELETE RESTRICT, " + ;
      "CategoriaGastoId INTEGER REFERENCES CategoriasGasto(Id) ON DELETE SET NULL, " + ;
      "Descripcion TEXT(500) NOT NULL, " + ;
      "BaseImponible TEXT NOT NULL, " + ;
      "IvaPorcentaje TEXT NOT NULL, " + ;
      "IvaImporte TEXT NOT NULL, " + ;
      "RetencionPorcentaje TEXT NOT NULL, " + ;
      "RetencionImporte TEXT NOT NULL, " + ;
      "Total TEXT NOT NULL, " + ;
      "GastoDeducibleIRPF TEXT NOT NULL, " + ;
      "MedioPago INTEGER NOT NULL, " + ;
      "Pagado INTEGER NOT NULL DEFAULT 0, " + ;
      "FechaPago TEXT, " + ;
      "Observaciones TEXT(1000), " + ;
      "RutaAdjunto TEXT(500), " + ;
      "IVADeducible INTEGER NOT NULL DEFAULT 1, " + ;
      "BienInversionId INTEGER, " + ;
      "FechaCreacion TEXT NOT NULL )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS LineasGasto( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "GastoId INTEGER NOT NULL REFERENCES Gastos(Id) ON DELETE CASCADE, " + ;
      "Descripcion TEXT(300) NOT NULL, " + ;
      "BaseImponible TEXT NOT NULL, " + ;
      "IvaPorcentaje TEXT NOT NULL, " + ;
      "IvaImporte TEXT NOT NULL, " + ;
      "RetencionPorcentaje TEXT NOT NULL, " + ;
      "RetencionImporte TEXT NOT NULL, " + ;
      "ImporteTotal TEXT NOT NULL )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS BienesInversion( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "Nombre TEXT(200) NOT NULL, " + ;
      "FechaAdquisicion TEXT NOT NULL, " + ;
      "ValorAdquisicion TEXT NOT NULL, " + ;
      "PorcentajeUsoActividad TEXT NOT NULL, " + ;
      "AmortizacionAnual TEXT NOT NULL, " + ;
      "ValorAmortizado TEXT NOT NULL, " + ;
      "ValorNetoContable TEXT NOT NULL, " + ;
      "Categoria TEXT(100), " + ;
      "FechaInicioAmortizacion TEXT, " + ;
      "EnUso INTEGER NOT NULL DEFAULT 1, " + ;
      "FechaBaja TEXT )" )

   sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS idx_Facturas_ClienteId ON Facturas(ClienteId)")
   sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS idx_LineasFactura_FacturaId ON LineasFactura(FacturaId)")
   sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS idx_LineasFactura_ArticuloId ON LineasFactura(ArticuloId)")
   sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS idx_RegistrosFacturacion_FacturaId ON RegistrosFacturacion(FacturaId)")
   sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS idx_Gastos_ProveedorId ON Gastos(ProveedorId)")
   sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS idx_LineasGasto_GastoId ON LineasGasto(GastoId)")

RETURN .T.

STATIC FUNCTION SembrarDatosIniciales(db)
   LOCAL stmt

   IF !TablaVacia(db, "Paises")
      SembrarPaises(db)
   ENDIF

   IF !TablaVacia(db, "TiposIdentificacion")
      SembrarTiposIdentificacion(db)
   ENDIF

   IF !TablaVacia(db, "TiposIva")
      SembrarTiposIva(db)
   ENDIF

   IF !TablaVacia(db, "Configuracion")
      SembrarConfiguracion(db)
   ENDIF

   IF !TablaVacia(db, "CategoriasGasto")
      SembrarCategoriasGasto(db)
   ENDIF

RETURN .T.

STATIC FUNCTION TablaVacia(db, cTabla)
   LOCAL stmt := sqlite3_prepare(db, "SELECT COUNT(*) FROM " + cTabla)
   LOCAL nCount := 0
   IF !Empty(stmt) .AND. sqlite3_step(stmt) == SQLITE_ROW
      nCount := sqlite3_column_int(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN nCount > 0

STATIC FUNCTION SembrarPaises(db)
   LOCAL aPaises := { ;
      { "ES", "España", "Española", 1 }, ;
      { "DE", "Alemania", "Alemana", 1 }, ;
      { "FR", "Francia", "Francesa", 1 }, ;
      { "IT", "Italia", "Italiana", 1 }, ;
      { "PT", "Portugal", "Portuguesa", 1 }, ;
      { "GB", "Reino Unido", "Británica", 0 }, ;
      { "US", "Estados Unidos", "Estadounidense", 0 }, ;
      { "AR", "Argentina", "Argentina", 0 }, ;
      { "MX", "México", "Mexicana", 0 }, ;
      { "CO", "Colombia", "Colombiana", 0 }, ;
      { "CL", "Chile", "Chilena", 0 }, ;
      { "PE", "Perú", "Peruana", 0 }, ;
      { "UY", "Uruguay", "Uruguaya", 0 }, ;
      { "BR", "Brasil", "Brasileña", 0 }, ;
      { "CN", "China", "China", 0 }, ;
      { "JP", "Japón", "Japonesa", 0 }, ;
      { "MA", "Marruecos", "Marroquí", 0 }, ;
      { "AD", "Andorra", "Andorrana", 0 }, ;
      { "BE", "Bélgica", "Belga", 1 }, ;
      { "NL", "Países Bajos", "Neerlandesa", 1 }, ;
      { "LU", "Luxemburgo", "Luxemburguesa", 1 }, ;
      { "CH", "Suiza", "Suiza", 0 }, ;
      { "AT", "Austria", "Austriaca", 1 }, ;
      { "IE", "Irlanda", "Irlandesa", 1 }, ;
      { "DK", "Dinamarca", "Danesa", 1 }, ;
      { "SE", "Suecia", "Sueca", 1 }, ;
      { "FI", "Finlandia", "Finesa", 1 }, ;
      { "PL", "Polonia", "Polaca", 1 }, ;
      { "CZ", "República Checa", "Checa", 1 } }

   LOCAL stmt := sqlite3_prepare(db, "INSERT INTO Paises(Codigo, Nombre, Nacionalidad, EsUE) VALUES(?, ?, ?, ?)")
   LOCAL nI
   FOR nI := 1 TO Len(aPaises)
      sqlite3_bind_text(stmt, 1, aPaises[nI][1])
      sqlite3_bind_text(stmt, 2, aPaises[nI][2])
      sqlite3_bind_text(stmt, 3, aPaises[nI][3])
      sqlite3_bind_int(stmt, 4, aPaises[nI][4])
      sqlite3_step(stmt)
      sqlite3_reset(stmt)
   NEXT
   sqlite3_finalize(stmt)
RETURN .T.

STATIC FUNCTION SembrarTiposIdentificacion(db)
   LOCAL aTipos := { ;
      { "01", "NIF - DNI/CIF" }, ;
      { "02", "NIF-IVA (operador intracomunitario)" }, ;
      { "03", "Pasaporte" }, ;
      { "04", "Documento oficial de identificación" }, ;
      { "05", "Certificado de residencia" }, ;
      { "06", "Otro documento probatorio" } }

   LOCAL stmt := sqlite3_prepare(db, "INSERT INTO TiposIdentificacion(CodigoAEAT, Nombre) VALUES(?, ?)")
   LOCAL nI
   FOR nI := 1 TO Len(aTipos)
      sqlite3_bind_text(stmt, 1, aTipos[nI][1])
      sqlite3_bind_text(stmt, 2, aTipos[nI][2])
      sqlite3_step(stmt)
      sqlite3_reset(stmt)
   NEXT
   sqlite3_finalize(stmt)
RETURN .T.

STATIC FUNCTION SembrarTiposIva(db)
   LOCAL aTipos := { ;
      { "IVA General", "21.00", "2012-09-01", NIL }, ;
      { "IVA Reducido", "10.00", "2012-09-01", NIL }, ;
      { "IVA Superreducido", "4.00", "1995-01-01", NIL }, ;
      { "0% - Inversión sujeto pasivo", "0.00", "1993-01-01", NIL }, ;
      { "0% - Exportación / No sujeto", "0.00", "1993-01-01", NIL }, ;
      { "Exento", "0.00", "1993-01-01", NIL } }

   LOCAL stmt := sqlite3_prepare(db, "INSERT INTO TiposIva(Nombre, Porcentaje, FechaInicio, FechaFin) VALUES(?, ?, ?, ?)")
   LOCAL nI
   FOR nI := 1 TO Len(aTipos)
      sqlite3_bind_text(stmt, 1, aTipos[nI][1])
      sqlite3_bind_text(stmt, 2, aTipos[nI][2])
      sqlite3_bind_text(stmt, 3, aTipos[nI][3])
      sqlite3_bind_null(stmt, 4)
      sqlite3_step(stmt)
      sqlite3_reset(stmt)
   NEXT
   sqlite3_finalize(stmt)
RETURN .T.

STATIC FUNCTION SembrarConfiguracion(db)
   LOCAL aConfig := { ;
      { "Empresa.Nif", "" }, ;
      { "Empresa.Nombre", "" }, ;
      { "Empresa.Direccion", "" }, ;
      { "Empresa.Poblacion", "" }, ;
      { "Empresa.Provincia", "" }, ;
      { "Empresa.CodigoPostal", "" }, ;
      { "Empresa.Telefono", "" }, ;
      { "Empresa.Email", "" }, ;
      { "Empresa.Web", "" }, ;
      { "VeriFactu.Nif", "" }, ;
      { "VeriFactu.IdEmisor", "FV" }, ;
      { "VeriFactu.NombreSoftware", "Facturas" }, ;
      { "VeriFactu.VersionSoftware", "1.0.0" }, ;
      { "VeriFactu.Ambiente", "1" }, ;
      { "IVA.General", "21.00" }, ;
      { "IVA.Reducido", "10.00" }, ;
      { "IVA.Superreducido", "4.00" }, ;
      { "IRPF.Porcentaje", "15" }, ;
      { "UltimoNumeroFactura", "0" } }

   LOCAL stmt := sqlite3_prepare(db, "INSERT INTO Configuracion(Clave, Valor) VALUES(?, ?)")
   LOCAL nI
   FOR nI := 1 TO Len(aConfig)
      sqlite3_bind_text(stmt, 1, aConfig[nI][1])
      sqlite3_bind_text(stmt, 2, aConfig[nI][2])
      sqlite3_step(stmt)
      sqlite3_reset(stmt)
   NEXT
   sqlite3_finalize(stmt)
RETURN .T.

STATIC FUNCTION SembrarCategoriasGasto(db)
   LOCAL aCat := { ;
      { "Suministros", "100.00", 1, 1 }, ;
      { "Alquiler", "100.00", 1, 2 }, ;
      { "Material / Oficina", "100.00", 1, 3 }, ;
      { "Profesionales", "100.00", 1, 4 }, ;
      { "Transporte", "100.00", 1, 5 }, ;
      { "Seguros", "100.00", 0, 6 }, ;
      { "Hostelería / Restaurantes", "50.00", 1, 7 }, ;
      { "Formación", "100.00", 1, 8 }, ;
      { "Informática", "100.00", 1, 9 }, ;
      { "Otros", "100.00", 1, 10 } }

   LOCAL stmt := sqlite3_prepare(db, "INSERT INTO CategoriasGasto(Nombre, PorcentajeDeducibleIRPF, IvaDeducible, Orden) VALUES(?, ?, ?, ?)")
   LOCAL nI
   FOR nI := 1 TO Len(aCat)
      sqlite3_bind_text(stmt, 1, aCat[nI][1])
      sqlite3_bind_text(stmt, 2, aCat[nI][2])
      sqlite3_bind_int(stmt, 3, aCat[nI][3])
      sqlite3_bind_int(stmt, 4, aCat[nI][4])
      sqlite3_step(stmt)
      sqlite3_reset(stmt)
   NEXT
   sqlite3_finalize(stmt)
RETURN .T.
