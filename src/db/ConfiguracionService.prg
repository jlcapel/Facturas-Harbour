#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerConfiguracion(db, cClave)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Valor FROM Configuracion WHERE Clave = ?")
   LOCAL cValor := NIL
   sqlite3_bind_text(stmt, 1, cClave)
   IF sqlite3_step(stmt) == SQLITE_ROW
      cValor := sqlite3_column_text(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cValor

FUNCTION EstablecerConfiguracion(db, cClave, cValor)
   LOCAL stmt, nRes
   stmt := sqlite3_prepare(db, ;
      "INSERT OR REPLACE INTO Configuracion(Clave, Valor) VALUES(?, ?)")
   sqlite3_bind_text(stmt, 1, cClave)
   sqlite3_bind_text(stmt, 2, cValor)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION ObtenerConfiguracionEntero(db, cClave, nDef)
   LOCAL cValor := ObtenerConfiguracion(db, cClave)
   IF cValor == NIL
      RETURN nDef
   ENDIF
   RETURN Val(cValor)

FUNCTION ObtenerConfiguracionDecimal(db, cClave, nDef)
   LOCAL cValor := ObtenerConfiguracion(db, cClave)
   IF cValor == NIL
      RETURN nDef
   ENDIF
   RETURN Val(cValor)
