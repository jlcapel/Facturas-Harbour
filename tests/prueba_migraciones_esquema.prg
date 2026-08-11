#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cDirectorio := hb_GetEnv("FACTURAS_PRUEBA_DIR")
   LOCAL dbVacia := sqlite3_open(cDirectorio + "/vacia.db", .T.)
   LOCAL dbPrevia := sqlite3_open(cDirectorio + "/previa.db", .T.)
   LOCAL lVacia, lPrevia, lObjetivoVacio, lObjetivoPrevio, lDatos, lSinUnicidad, lInsercion, lIntegridad

   HBTEST !Empty(dbVacia) IS .T.
   HBTEST !Empty(dbPrevia) IS .T.
   IF Empty(dbVacia) .OR. Empty(dbPrevia)
      ErrorLevel(1)
      RETURN
   ENDIF

   CrearTablas(dbVacia)
   lVacia := AsegurarEsquemaFiscal(dbVacia) .AND. AsegurarEsquemaVersionesFiscales(dbVacia)
   lObjetivoVacio := EsEsquemaObjetivo(dbVacia)

   lPrevia := CrearEsquemaPrevio(dbPrevia)
   IF lPrevia
      lPrevia := AsegurarEsquemaVersionesFiscales(dbPrevia)
   ENDIF
   IF lPrevia
      lPrevia := AsegurarEsquemaVersionesFiscales(dbPrevia)
   ENDIF
   lObjetivoPrevio := EsEsquemaObjetivo(dbPrevia)
   lDatos := LeerNumero(dbPrevia, "SELECT COUNT(*) FROM RegistrosFacturacion") == 1 .AND. ;
      LeerTexto(dbPrevia, "SELECT Hash FROM RegistrosFacturacion WHERE Id=1") == "HASH_INICIAL" .AND. ;
      LeerNumero(dbPrevia, "SELECT FacturaId FROM RegistrosFacturacion WHERE Id=1") == 1 .AND. ;
      ExisteIndice(dbPrevia, "idx_prueba_registros_numero")
   lSinUnicidad := !FacturaIdEsUnico(dbPrevia)
   lInsercion := sqlite3_exec(dbPrevia, ;
      "INSERT INTO RegistrosFacturacion(FacturaId, TipoRegistro, Hash, HashAnterior, NifEmisor, NumeroFactura, FechaEmision, BaseImponible, IvaImporte, Total, FechaRegistro, IdRegistroAnterior, FechaHoraHusoGenRegistro) " + ;
      "VALUES(1, 2, 'HASH_SUBSANACION', 'HASH_INICIAL', 'B12345674', 'F-001', '2026-08-10', '10.00', '2.10', '12.10', '2026-08-10T10:00:00Z', 1, '2026-08-10T10:00:00Z')") == SQLITE_OK
   lIntegridad := IntegridadForaneaValida(dbPrevia)

   HBTEST lVacia IS .T.
   HBTEST lObjetivoVacio IS .T.
   HBTEST lPrevia IS .T.
   HBTEST lObjetivoPrevio IS .T.
   HBTEST lDatos IS .T.
   HBTEST lSinUnicidad IS .T.
   HBTEST lInsercion IS .T.
   HBTEST lIntegridad IS .T.
   dbVacia := NIL
   dbPrevia := NIL
   ErrorLevel(Iif(lVacia .AND. lObjetivoVacio .AND. lPrevia .AND. lObjetivoPrevio .AND. lDatos .AND. lSinUnicidad .AND. lInsercion .AND. lIntegridad, 0, 1))
RETURN

STATIC FUNCTION CrearEsquemaPrevio(db)
   LOCAL lOk := sqlite3_exec(db, "PRAGMA foreign_keys=ON") == SQLITE_OK

   IF lOk
      lOk := sqlite3_exec(db, "CREATE TABLE Facturas(Id INTEGER PRIMARY KEY AUTOINCREMENT)") == SQLITE_OK .AND. ;
         sqlite3_exec(db, "CREATE TABLE TiposIva(Id INTEGER PRIMARY KEY AUTOINCREMENT)") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "INSERT INTO Facturas(Id) VALUES(1)") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, ;
         "CREATE TABLE RegistrosFacturacion( " + ;
         "Id INTEGER PRIMARY KEY AUTOINCREMENT, FacturaId INTEGER NOT NULL UNIQUE REFERENCES Facturas(Id) ON DELETE CASCADE, " + ;
         "TipoRegistro INTEGER NOT NULL DEFAULT 0, Hash TEXT(64) NOT NULL UNIQUE, HashAnterior TEXT(64), " + ;
         "NifEmisor TEXT(9) NOT NULL, NumeroFactura TEXT(60), FechaEmision TEXT NOT NULL, " + ;
         "BaseImponible TEXT NOT NULL, IvaImporte TEXT NOT NULL, Total TEXT NOT NULL, FechaRegistro TEXT NOT NULL, " + ;
         "IdRegistroAnterior INTEGER UNIQUE REFERENCES RegistrosFacturacion(Id) ON DELETE SET NULL, " + ;
         "FechaHoraHusoGenRegistro TEXT NOT NULL )") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "CREATE INDEX idx_prueba_registros_numero ON RegistrosFacturacion(NumeroFactura)") == SQLITE_OK
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, ;
         "INSERT INTO RegistrosFacturacion(Id, FacturaId, TipoRegistro, Hash, HashAnterior, NifEmisor, NumeroFactura, FechaEmision, BaseImponible, IvaImporte, Total, FechaRegistro, IdRegistroAnterior, FechaHoraHusoGenRegistro) " + ;
         "VALUES(1, 1, 0, 'HASH_INICIAL', NULL, 'B12345674', 'F-001', '2026-08-10', '10.00', '2.10', '12.10', '2026-08-10T09:00:00Z', NULL, '2026-08-10T09:00:00Z')") == SQLITE_OK
   ENDIF
RETURN lOk

STATIC FUNCTION EsEsquemaObjetivo(db)
RETURN ExisteTabla(db, "FacturasVersionesFiscales") .AND. ;
   ExisteTabla(db, "FacturasDesglosesIva") .AND. ;
   ExisteTabla(db, "FacturasVersionesFiscalesDesglosesIva") .AND. ;
   ExisteColumna(db, "RegistrosFacturacion", "FacturaVersionFiscalId") .AND. ;
   ExisteIndice(db, "IX_RegistrosFacturacion_FacturaVersionFiscalId") .AND. ;
   ExisteIndice(db, "IX_FacturasDesglosesIva_FacturaId_Orden") .AND. ;
   ExisteIndice(db, "IX_FacturasVersionesFiscalesDesglosesIva_FacturaVersionFiscalId_Orden")

STATIC FUNCTION ExisteTabla(db, cTabla)
   LOCAL stmt := sqlite3_prepare(db, "SELECT 1 FROM sqlite_master WHERE type='table' AND name=?")
   LOCAL lExiste := .F.

   IF !Empty(stmt)
      sqlite3_bind_text(stmt, 1, cTabla)
      lExiste := sqlite3_step(stmt) == SQLITE_ROW
      sqlite3_finalize(stmt)
   ENDIF
RETURN lExiste

STATIC FUNCTION ExisteColumna(db, cTabla, cColumna)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA table_info(" + cTabla + ")")
   LOCAL lExiste := .F.

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
RETURN lExiste

STATIC FUNCTION ExisteIndice(db, cIndice)
   LOCAL stmt := sqlite3_prepare(db, "SELECT 1 FROM sqlite_master WHERE type='index' AND name=?")
   LOCAL lExiste := .F.

   IF !Empty(stmt)
      sqlite3_bind_text(stmt, 1, cIndice)
      lExiste := sqlite3_step(stmt) == SQLITE_ROW
      sqlite3_finalize(stmt)
   ENDIF
RETURN lExiste

STATIC FUNCTION FacturaIdEsUnico(db)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA index_list(RegistrosFacturacion)")
   LOCAL cIndice, lUnico := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cIndice := sqlite3_column_text(stmt, 2)
      IF sqlite3_column_int(stmt, 3) == 1 .AND. IndiceTieneFacturaId(db, cIndice)
         lUnico := .T.
         EXIT
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)
RETURN lUnico

STATIC FUNCTION IndiceTieneFacturaId(db, cIndice)
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

STATIC FUNCTION LeerTexto(db, cSql)
   LOCAL stmt := sqlite3_prepare(db, cSql)
   LOCAL cValor := ""

   IF !Empty(stmt)
      IF sqlite3_step(stmt) == SQLITE_ROW
         cValor := sqlite3_column_text(stmt, 1)
      ENDIF
      sqlite3_finalize(stmt)
   ENDIF
RETURN cValor

STATIC FUNCTION LeerNumero(db, cSql)
   LOCAL stmt := sqlite3_prepare(db, cSql)
   LOCAL nValor := 0

   IF !Empty(stmt)
      IF sqlite3_step(stmt) == SQLITE_ROW
         nValor := sqlite3_column_int(stmt, 1)
      ENDIF
      sqlite3_finalize(stmt)
   ENDIF
RETURN nValor

STATIC FUNCTION IntegridadForaneaValida(db)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA foreign_key_check")
   LOCAL lValida := .F.

   IF !Empty(stmt)
      lValida := sqlite3_step(stmt) != SQLITE_ROW
      sqlite3_finalize(stmt)
   ENDIF
RETURN lValida
