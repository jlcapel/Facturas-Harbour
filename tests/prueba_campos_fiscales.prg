#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cRutaDb := hb_GetEnv("FACTURAS_PRUEBA_DB")
   LOCAL db := sqlite3_open(cRutaDb, .T.)
   LOCAL lAbierta := !Empty(db), aTipos, nTipo, aS1, aS2, aN2, aE5
   LOCAL lColumnas, lMigracion, lGuardado, lRoundtrip, lTratamientos

   HBTEST lAbierta IS .T.
   IF !lAbierta
      ErrorLevel(1)
      RETURN
   ENDIF

   sqlite3_exec(db, "CREATE TABLE TiposIva(Id INTEGER PRIMARY KEY, Nombre TEXT NOT NULL, Porcentaje TEXT NOT NULL, Activo INTEGER NOT NULL DEFAULT 1, FechaInicio TEXT NOT NULL, FechaFin TEXT)")
   sqlite3_exec(db, "CREATE TABLE LineasFactura(Id INTEGER PRIMARY KEY, FacturaId INTEGER NOT NULL, ArticuloId INTEGER, TipoIvaId INTEGER, Descripcion TEXT NOT NULL, Cantidad TEXT NOT NULL, PrecioUnitario TEXT NOT NULL, IvaPorcentaje TEXT NOT NULL, Importe TEXT NOT NULL, DescuentoPorcentaje TEXT, DescuentoImporte TEXT)")
   sqlite3_exec(db, "INSERT INTO TiposIva(Id, Nombre, Porcentaje, Activo, FechaInicio) VALUES(1, 'IVA Inversión', '0', 1, '20260101')")

   AsegurarEsquemaFiscal(db)
   lColumnas := ExisteColumna(db, "TiposIva", "Impuesto") .AND. ;
      ExisteColumna(db, "TiposIva", "ClaveRegimen") .AND. ;
      ExisteColumna(db, "TiposIva", "CalificacionOperacion") .AND. ;
      ExisteColumna(db, "TiposIva", "DescripcionFiscal") .AND. ;
      ExisteColumna(db, "LineasFactura", "Impuesto") .AND. ;
      ExisteColumna(db, "LineasFactura", "ClaveRegimen") .AND. ;
      ExisteColumna(db, "LineasFactura", "CalificacionOperacion") .AND. ;
      ExisteColumna(db, "LineasFactura", "OperacionExenta") .AND. ;
      ExisteColumna(db, "LineasFactura", "DescripcionFiscal")
   lMigracion := LeerTexto(db, "SELECT Impuesto FROM TiposIva WHERE Id=1") == "01" .AND. ;
      LeerTexto(db, "SELECT ClaveRegimen FROM TiposIva WHERE Id=1") == "01" .AND. ;
      LeerTexto(db, "SELECT CalificacionOperacion FROM TiposIva WHERE Id=1") == "S2" .AND. ;
      LeerTexto(db, "SELECT DescripcionFiscal FROM TiposIva WHERE Id=1") == "Operación sujeta y no exenta con inversión del sujeto pasivo"

   lGuardado := GuardarTipoIva(db, 0, "IVA no sujeta", "0", .T., "20260101", NIL, "01", "01", "N2", "Operacion no sujeta por reglas de localizacion.")
   aTipos := ObtenerTiposIva(db)
   nTipo := AScan(aTipos, {|a| a[2] == "IVA no sujeta"})
   lRoundtrip := nTipo > 0 .AND. aTipos[nTipo][7] == "01" .AND. ;
      aTipos[nTipo][8] == "01" .AND. aTipos[nTipo][9] == "N2" .AND. ;
      aTipos[nTipo][10] == "Operacion no sujeta por reglas de localizacion."

   aS1 := BuscarTratamientoIva("S1", NIL)
   aS2 := BuscarTratamientoIva("S2", NIL)
   aN2 := BuscarTratamientoIva("N2", NIL)
   aE5 := BuscarTratamientoIva(NIL, "E5")
   lTratamientos := aS1[1] == "S1" .AND. !TratamientoIvaExigeIvaCero(aS1) .AND. ;
      aS2[1] == "S2" .AND. TratamientoIvaExigeIvaCero(aS2) .AND. ;
      aN2[1] == "N2" .AND. TratamientoIvaExigeIvaCero(aN2) .AND. ;
      aE5[1] == "E5" .AND. TratamientoIvaExigeIvaCero(aE5)

   HBTEST lColumnas IS .T.
   HBTEST lMigracion IS .T.
   HBTEST lGuardado IS .T.
   HBTEST lRoundtrip IS .T.
   HBTEST lTratamientos IS .T.
   db := NIL
   ErrorLevel(Iif(lColumnas .AND. lMigracion .AND. lGuardado .AND. lRoundtrip .AND. lTratamientos, 0, 1))
RETURN

STATIC FUNCTION ExisteColumna(db, cTabla, cColumna)
   LOCAL stmt := sqlite3_prepare(db, "PRAGMA table_info(" + cTabla + ")")
   LOCAL lExiste := .F.

   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      IF Lower(sqlite3_column_text(stmt, 2)) == Lower(cColumna)
         lExiste := .T.
         EXIT
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)
RETURN lExiste

STATIC FUNCTION LeerTexto(db, cSql)
   LOCAL stmt := sqlite3_prepare(db, cSql)
   LOCAL cValor := ""

   IF sqlite3_step(stmt) == SQLITE_ROW
      cValor := sqlite3_column_text(stmt, 1)
   ENDIF
   sqlite3_finalize(stmt)
RETURN cValor
