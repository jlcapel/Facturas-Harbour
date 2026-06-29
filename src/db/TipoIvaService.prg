#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerTiposIva(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Nombre, Porcentaje, Activo, FechaInicio, FechaFin FROM TiposIva ORDER BY CAST(Porcentaje AS REAL)")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0, ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5) } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerTipoIvaPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Nombre, Porcentaje, Activo, FechaInicio, FechaFin FROM TiposIva WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0, ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarTipoIva(db, nId, cNombre, cPorcentaje, lActivo, cFechaInicio, cFechaFin)
   LOCAL stmt, nRes

   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO TiposIva(Nombre, Porcentaje, Activo, FechaInicio, FechaFin) VALUES(?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE TiposIva SET Nombre=?, Porcentaje=?, Activo=?, FechaInicio=?, FechaFin=? WHERE Id=?")
   ENDIF

   sqlite3_bind_text(stmt, 1, cNombre)
   sqlite3_bind_text(stmt, 2, cPorcentaje)
   sqlite3_bind_int(stmt, 3, iif(lActivo, 1, 0))
   sqlite3_bind_text(stmt, 4, cFechaInicio)

   IF cFechaFin == NIL
      sqlite3_bind_null(stmt, 5)
   ELSE
      sqlite3_bind_text(stmt, 5, cFechaFin)
   ENDIF

   IF nId != 0
      sqlite3_bind_int(stmt, 6, nId)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
