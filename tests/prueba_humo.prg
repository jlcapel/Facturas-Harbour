#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cRutaDb := hb_GetEnv("FACTURAS_PRUEBA_DB")
   LOCAL db
   LOCAL lRutaValida, lDbAbierta, lPaises, lConfiguracion, nIva

   lRutaValida := !Empty(cRutaDb)
   HBTEST lRutaValida IS .T.
   db := sqlite3_open(cRutaDb, .T.)
   lDbAbierta := !Empty(db)
   HBTEST lDbAbierta IS .T.

   sqlite3_exec(db, "CREATE TABLE Paises(Id INTEGER PRIMARY KEY, Codigo TEXT(2) NOT NULL UNIQUE, Nombre TEXT(100) NOT NULL, Nacionalidad TEXT(100), EsUE INTEGER NOT NULL DEFAULT 0, Activo INTEGER NOT NULL DEFAULT 1)")
   sqlite3_exec(db, "CREATE TABLE Configuracion(Id INTEGER PRIMARY KEY, Clave TEXT(50) NOT NULL UNIQUE, Valor TEXT(500))")

   lPaises := ExisteTabla(db, "Paises")
   lConfiguracion := ExisteTabla(db, "Configuracion")
   nIva := CalcularIvaLinea(100, 21)
   HBTEST lPaises IS .T.
   HBTEST lConfiguracion IS .T.
   HBTEST nIva IS 21.00

   db := NIL
   ErrorLevel(Iif(lRutaValida .AND. lDbAbierta .AND. lPaises .AND. lConfiguracion .AND. nIva == 21.00, 0, 1))
RETURN

STATIC FUNCTION ExisteTabla(db, cNombre)
   LOCAL stmt := sqlite3_prepare(db, "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?")
   LOCAL lExiste := .F.

   sqlite3_bind_text(stmt, 1, cNombre)
   IF sqlite3_step(stmt) == SQLITE_ROW
      lExiste := .T.
   ENDIF
   stmt := NIL
RETURN lExiste
