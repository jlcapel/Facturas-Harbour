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
   AsegurarEsquemaFiscal(db)
   IF !AsegurarEsquemaVersionesFiscales(db)
      db := NIL
      RETURN .F.
   ENDIF
   SembrarDatosIniciales(db)
   db := NIL
   RETURN .T.

FUNCTION AsegurarEsquemaFiscal(db)
   AsegurarColumnaFiscal(db, "TiposIva", "Impuesto", "TEXT NOT NULL DEFAULT '01'")
   AsegurarColumnaFiscal(db, "TiposIva", "ClaveRegimen", "TEXT NOT NULL DEFAULT '01'")
   AsegurarColumnaFiscal(db, "TiposIva", "CalificacionOperacion", "TEXT NOT NULL DEFAULT 'S1'")
   AsegurarColumnaFiscal(db, "TiposIva", "DescripcionFiscal", "TEXT")
   AsegurarColumnaFiscal(db, "LineasFactura", "Impuesto", "TEXT NOT NULL DEFAULT '01'")
   AsegurarColumnaFiscal(db, "LineasFactura", "ClaveRegimen", "TEXT NOT NULL DEFAULT '01'")
   AsegurarColumnaFiscal(db, "LineasFactura", "CalificacionOperacion", "TEXT DEFAULT 'S1'")
   AsegurarColumnaFiscal(db, "LineasFactura", "OperacionExenta", "TEXT")
   AsegurarColumnaFiscal(db, "LineasFactura", "DescripcionFiscal", "TEXT")
   sqlite3_exec(db, "UPDATE TiposIva SET Impuesto='01' WHERE Impuesto IS NULL OR TRIM(Impuesto)=''" )
   sqlite3_exec(db, "UPDATE TiposIva SET ClaveRegimen='01' WHERE ClaveRegimen IS NULL OR TRIM(ClaveRegimen)=''" )
   sqlite3_exec(db, "UPDATE TiposIva SET CalificacionOperacion='S1' WHERE CalificacionOperacion IS NULL OR TRIM(CalificacionOperacion)=''" )
   sqlite3_exec(db, "UPDATE TiposIva SET Impuesto='01', ClaveRegimen='01', CalificacionOperacion='S2', DescripcionFiscal=COALESCE(DescripcionFiscal, 'Operación sujeta y no exenta con inversión del sujeto pasivo') WHERE Nombre LIKE '%Inversión%' AND CalificacionOperacion <> 'S2'" )
RETURN .T.

STATIC FUNCTION AsegurarColumnaFiscal(db, cTabla, cColumna, cDefinicion)
   LOCAL stmt, lExiste := .F.

   IF !ExisteTablaMigracion(db, cTabla)
      RETURN .F.
   ENDIF
   stmt := sqlite3_prepare(db, "PRAGMA table_info(" + cTabla + ")")
   IF Empty(stmt)
      RETURN .F.
   ENDIF
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      IF Lower(sqlite3_column_text(stmt, 2)) == Lower(cColumna)
         lExiste := .T.
         EXIT
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)
   IF !lExiste
      RETURN sqlite3_exec(db, "ALTER TABLE " + cTabla + " ADD COLUMN " + cColumna + " " + cDefinicion) == SQLITE_OK
   ENDIF
RETURN .T.

FUNCTION AsegurarEsquemaVersionesFiscales(db)
   LOCAL lOk := ExisteTablaMigracion(db, "RegistrosFacturacion") .AND. ;
      ExisteTablaMigracion(db, "Facturas") .AND. ExisteTablaMigracion(db, "TiposIva")

   IF !lOk
      RETURN .F.
   ENDIF
   IF RegistroFacturaTieneUnicidad(db)
      lOk := ReconstruirRegistrosFacturacion(db)
   ENDIF
   IF !lOk
      RETURN .F.
   ENDIF
   lOk := AsegurarColumnaFiscal(db, "RegistrosFacturacion", "FacturaVersionFiscalId", "INTEGER")
   IF !lOk
      RETURN .F.
   ENDIF
   IF !ExisteTablaMigracion(db, "FacturasVersionesFiscales")
      lOk := CrearTablaFacturasVersionesFiscales(db)
   ENDIF
   IF lOk .AND. !ExisteTablaMigracion(db, "FacturasDesglosesIva")
      lOk := CrearTablaFacturasDesglosesIva(db)
   ENDIF
   IF lOk .AND. !ExisteTablaMigracion(db, "FacturasVersionesFiscalesDesglosesIva")
      lOk := CrearTablaFacturasVersionesFiscalesDesglosesIva(db)
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_RegistrosFacturacion_FacturaId ON RegistrosFacturacion(FacturaId)") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS IX_RegistrosFacturacion_FacturaVersionFiscalId ON RegistrosFacturacion(FacturaVersionFiscalId)") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS IX_FacturasVersionesFiscales_HashContenido ON FacturasVersionesFiscales(HashContenido)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasVersionesFiscales_FacturaId ON FacturasVersionesFiscales(FacturaId)") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasDesglosesIva_FacturaId_Orden ON FacturasDesglosesIva(FacturaId, Orden)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasDesglosesIva_TipoIvaId ON FacturasDesglosesIva(TipoIvaId)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasVersionesFiscalesDesglosesIva_FacturaVersionFiscalId_Orden ON FacturasVersionesFiscalesDesglosesIva(FacturaVersionFiscalId, Orden)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasVersionesFiscalesDesglosesIva_TipoIvaId ON FacturasVersionesFiscalesDesglosesIva(TipoIvaId)") == SQLITE_OK
   ENDIF
RETURN lOk

STATIC FUNCTION CrearTablaFacturasVersionesFiscales(db)
RETURN sqlite3_exec(db, ;
   "CREATE TABLE FacturasVersionesFiscales( " + ;
   "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
   "FacturaId INTEGER NOT NULL, RegistroFacturacionId INTEGER, TipoRegistro INTEGER NOT NULL, " + ;
   "NumeroFactura TEXT NOT NULL, FechaEmision TEXT NOT NULL, FechaOperacion TEXT, ClienteId INTEGER NOT NULL, " + ;
   "ClienteSnapshotJson TEXT NOT NULL, LineasSnapshotJson TEXT NOT NULL, Descripcion TEXT, " + ;
   "AeatTipoFactura TEXT NOT NULL, TipoRectificacion TEXT, FacturaRectificadaId INTEGER, " + ;
   "BaseImponible TEXT NOT NULL, IvaImporte TEXT NOT NULL, IrpfPorcentaje TEXT NOT NULL, " + ;
   "IrpfImporte TEXT NOT NULL, Total TEXT NOT NULL, TotalFiscal TEXT NOT NULL, DesgloseJson TEXT NOT NULL, " + ;
   "FechaCreacion TEXT NOT NULL, HashContenido TEXT NOT NULL, " + ;
   "FOREIGN KEY(FacturaId) REFERENCES Facturas(Id) ON DELETE RESTRICT )" ) == SQLITE_OK

STATIC FUNCTION CrearTablaFacturasDesglosesIva(db)
   LOCAL lOk := sqlite3_exec(db, ;
      "CREATE TABLE FacturasDesglosesIva( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, FacturaId INTEGER NOT NULL, Orden INTEGER NOT NULL, TipoIvaId INTEGER, " + ;
      "TipoIvaNombre TEXT, Impuesto TEXT NOT NULL DEFAULT '01', ClaveRegimen TEXT NOT NULL DEFAULT '01', " + ;
      "CalificacionOperacion TEXT, OperacionExenta TEXT, DescripcionFiscal TEXT, TipoImpositivo TEXT NOT NULL, " + ;
      "BaseImponible TEXT NOT NULL, CuotaRepercutida TEXT NOT NULL, TotalFiscal TEXT NOT NULL, " + ;
      "FOREIGN KEY(FacturaId) REFERENCES Facturas(Id) ON DELETE RESTRICT, " + ;
      "FOREIGN KEY(TipoIvaId) REFERENCES TiposIva(Id) ON DELETE RESTRICT )" ) == SQLITE_OK

   IF lOk
      lOk := sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasDesglosesIva_FacturaId_Orden ON FacturasDesglosesIva(FacturaId, Orden)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasDesglosesIva_TipoIvaId ON FacturasDesglosesIva(TipoIvaId)") == SQLITE_OK
   ENDIF
RETURN lOk

STATIC FUNCTION CrearTablaFacturasVersionesFiscalesDesglosesIva(db)
   LOCAL lOk := sqlite3_exec(db, ;
      "CREATE TABLE FacturasVersionesFiscalesDesglosesIva( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, FacturaVersionFiscalId INTEGER NOT NULL, Orden INTEGER NOT NULL, TipoIvaId INTEGER, " + ;
      "TipoIvaNombre TEXT, Impuesto TEXT NOT NULL DEFAULT '01', ClaveRegimen TEXT NOT NULL DEFAULT '01', " + ;
      "CalificacionOperacion TEXT, OperacionExenta TEXT, DescripcionFiscal TEXT, TipoImpositivo TEXT NOT NULL, " + ;
      "BaseImponible TEXT NOT NULL, CuotaRepercutida TEXT NOT NULL, TotalFiscal TEXT NOT NULL, " + ;
      "FOREIGN KEY(FacturaVersionFiscalId) REFERENCES FacturasVersionesFiscales(Id) ON DELETE RESTRICT, " + ;
      "FOREIGN KEY(TipoIvaId) REFERENCES TiposIva(Id) ON DELETE RESTRICT )" ) == SQLITE_OK

   IF lOk
      lOk := sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasVersionesFiscalesDesglosesIva_FacturaVersionFiscalId_Orden ON FacturasVersionesFiscalesDesglosesIva(FacturaVersionFiscalId, Orden)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS IX_FacturasVersionesFiscalesDesglosesIva_TipoIvaId ON FacturasVersionesFiscalesDesglosesIva(TipoIvaId)") == SQLITE_OK
   ENDIF
RETURN lOk

STATIC FUNCTION ExisteTablaMigracion(db, cTabla)
   LOCAL stmt := sqlite3_prepare(db, "SELECT 1 FROM sqlite_master WHERE type='table' AND name=?")
   LOCAL lExiste := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   sqlite3_bind_text(stmt, 1, cTabla)
   lExiste := sqlite3_step(stmt) == SQLITE_ROW
   sqlite3_finalize(stmt)
RETURN lExiste

STATIC FUNCTION RegistroFacturaTieneUnicidad(db)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA index_list(RegistrosFacturacion)")
   LOCAL cIndice, lUnico := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cIndice := sqlite3_column_text(stmt, 2)
      IF sqlite3_column_int(stmt, 3) == 1 .AND. IndiceEsFacturaUnico(db, cIndice)
         lUnico := .T.
         EXIT
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)
RETURN lUnico

STATIC FUNCTION IndiceEsFacturaUnico(db, cIndice)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA index_info('" + StrTran(cIndice, "'", "''") + "')")
   LOCAL nColumnas := 0, lFactura := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nColumnas++
      lFactura := Lower(sqlite3_column_text(stmt, 3)) == "facturaid"
   ENDDO
   sqlite3_finalize(stmt)
RETURN nColumnas == 1 .AND. lFactura

STATIC FUNCTION ReconstruirRegistrosFacturacion(db)
   LOCAL cDefinicion := DefinicionTablaMigracion(db, "RegistrosFacturacion")
   LOCAL cNueva, cColumnas, aAuxiliares, nI, lOk := .T.

   cNueva := StrTran(cDefinicion, "FacturaId INTEGER NOT NULL UNIQUE REFERENCES", "FacturaId INTEGER NOT NULL REFERENCES")
   IF Empty(cDefinicion) .OR. cNueva == cDefinicion
      RETURN .F.
   ENDIF
   cNueva := StrTran(cNueva, "CREATE TABLE RegistrosFacturacion", "CREATE TABLE RegistrosFacturacionMigracion")
   cNueva := StrTran(cNueva, "CREATE TABLE IF NOT EXISTS RegistrosFacturacion", "CREATE TABLE IF NOT EXISTS RegistrosFacturacionMigracion")
   IF At("RegistrosFacturacionMigracion", cNueva) == 0
      RETURN .F.
   ENDIF
   cColumnas := ColumnasTablaMigracion(db, "RegistrosFacturacion")
   aAuxiliares := DefinicionesAuxiliaresMigracion(db)
   IF Empty(cColumnas)
      RETURN .F.
   ENDIF
   lOk := sqlite3_exec(db, "PRAGMA foreign_keys=OFF") == SQLITE_OK
   IF lOk
      lOk := sqlite3_exec(db, "BEGIN IMMEDIATE") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, cNueva) == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "INSERT INTO RegistrosFacturacionMigracion(" + cColumnas + ") SELECT " + cColumnas + " FROM RegistrosFacturacion") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "DROP TABLE RegistrosFacturacion") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "ALTER TABLE RegistrosFacturacionMigracion RENAME TO RegistrosFacturacion") == SQLITE_OK
   ENDIF
   IF lOk
      FOR nI := 1 TO Len(aAuxiliares)
         lOk := sqlite3_exec(db, aAuxiliares[nI]) == SQLITE_OK
         IF !lOk
            EXIT
         ENDIF
      NEXT
   ENDIF
   IF lOk
      lOk := IntegridadForaneaValida(db)
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "COMMIT") == SQLITE_OK
   ELSE
      sqlite3_exec(db, "ROLLBACK")
   ENDIF
   sqlite3_exec(db, "PRAGMA foreign_keys=ON")
RETURN lOk

STATIC FUNCTION DefinicionTablaMigracion(db, cTabla)
   LOCAL stmt := sqlite3_prepare(db, "SELECT sql FROM sqlite_master WHERE type='table' AND name=?")
   LOCAL cDefinicion := ""

   IF Empty(stmt)
      RETURN cDefinicion
   ENDIF
   sqlite3_bind_text(stmt, 1, cTabla)
   IF sqlite3_step(stmt) == SQLITE_ROW
      cDefinicion := sqlite3_column_text(stmt, 1)
   ENDIF
   sqlite3_finalize(stmt)
RETURN cDefinicion

STATIC FUNCTION ColumnasTablaMigracion(db, cTabla)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA table_info(" + cTabla + ")")
   LOCAL cColumnas := "", cColumna

   IF Empty(stmt)
      RETURN cColumnas
   ENDIF
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cColumna := sqlite3_column_text(stmt, 2)
      IF !Empty(cColumnas)
         cColumnas += ","
      ENDIF
      cColumnas += '"' + StrTran(cColumna, '"', '""') + '"'
   ENDDO
   sqlite3_finalize(stmt)
RETURN cColumnas

STATIC FUNCTION DefinicionesAuxiliaresMigracion(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT type, name, sql FROM sqlite_master WHERE tbl_name='RegistrosFacturacion' AND type IN ('index','trigger') AND sql IS NOT NULL")
   LOCAL aDefiniciones := {}, cTipo, cIndice, cDefinicion

   IF Empty(stmt)
      RETURN aDefiniciones
   ENDIF
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cTipo := sqlite3_column_text(stmt, 1)
      cIndice := sqlite3_column_text(stmt, 2)
      cDefinicion := sqlite3_column_text(stmt, 3)
      IF cTipo == "index" .AND. IndiceEsFacturaUnico(db, cIndice)
         LOOP
      ENDIF
      AAdd(aDefiniciones, cDefinicion)
   ENDDO
   sqlite3_finalize(stmt)
RETURN aDefiniciones

STATIC FUNCTION IntegridadForaneaValida(db)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA foreign_key_check")
   LOCAL lValida := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   lValida := sqlite3_step(stmt) != SQLITE_ROW
   sqlite3_finalize(stmt)
RETURN lValida

FUNCTION CrearTablas(db)

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
      "Impuesto TEXT NOT NULL DEFAULT '01', " + ;
      "ClaveRegimen TEXT NOT NULL DEFAULT '01', " + ;
      "CalificacionOperacion TEXT NOT NULL DEFAULT 'S1', " + ;
      "DescripcionFiscal TEXT, " + ;
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
      "Impuesto TEXT NOT NULL DEFAULT '01', " + ;
      "ClaveRegimen TEXT NOT NULL DEFAULT '01', " + ;
      "CalificacionOperacion TEXT DEFAULT 'S1', " + ;
      "OperacionExenta TEXT, " + ;
      "DescripcionFiscal TEXT, " + ;
      "DescuentoPorcentaje TEXT, " + ;
      "DescuentoImporte TEXT )" )

   sqlite3_exec(db, ;
      "CREATE TABLE IF NOT EXISTS RegistrosFacturacion( " + ;
      "Id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
      "FacturaId INTEGER NOT NULL REFERENCES Facturas(Id) ON DELETE CASCADE, " + ;
      "FacturaVersionFiscalId INTEGER, " + ;
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
      "FacturaSimplificadaArt7273 TEXT, FacturaSinIdentifDestinatarioArt61d TEXT, Macrodato TEXT, " + ;
      "EmitidaPorTerceroODestinatario TEXT, Tercero TEXT, Destinatarios TEXT, Cupon TEXT, " + ;
      "Desglose TEXT, Encadenamiento TEXT, " + ;
      "SistemaInformatico TEXT, FechaHoraHusoGenRegistro TEXT NOT NULL, " + ;
      "NumRegistroAcuerdoFacturacion TEXT, IdAcuerdoSistemaInformatico TEXT, TipoHuella TEXT DEFAULT '01', " + ;
      "SinRegistroPrevio TEXT, RechazoPrevioAnulacion TEXT, GeneradoPor TEXT, Generador TEXT )" )

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
      nCount := sqlite3_column_int(stmt, 1)
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
       { "Language", "es" }, ;
       { "VeriFactu.NombreSistemaInformatico", "Facturas" }, ;
      { "VeriFactu.NifDesarrollo", "" }, ;
      { "VeriFactu.VersionSIF", "1.0.0" }, ;
      { "VeriFactu.NumeroInstalacion", "1" }, ;
      { "VeriFactu.SoloVerifactu", "S" }, ;
      { "VeriFactu.MultiOTPosible", "N" }, ;
      { "VeriFactu.IndicadorMultiplesOT", "N" }, ;
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
