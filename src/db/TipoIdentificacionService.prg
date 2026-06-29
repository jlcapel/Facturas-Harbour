#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerTiposIdentificacion(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, CodigoAEAT, Nombre, Activo FROM TiposIdentificacion ORDER BY Id")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0 } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerTipoIdentificacionPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, CodigoAEAT, Nombre, Activo FROM TiposIdentificacion WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0 }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerTipoIdentificacionPorCodigoAEAT(db, cCodigo)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, CodigoAEAT, Nombre, Activo FROM TiposIdentificacion WHERE CodigoAEAT = ?")
   LOCAL aResult := NIL
   sqlite3_bind_text(stmt, 1, cCodigo)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0 }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarTipoIdentificacion(db, nId, cCodigoAEAT, cNombre, lActivo)
   LOCAL stmt, nRes

   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO TiposIdentificacion(CodigoAEAT, Nombre, Activo) VALUES(?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE TiposIdentificacion SET CodigoAEAT=?, Nombre=?, Activo=? WHERE Id=?")
   ENDIF

   sqlite3_bind_text(stmt, 1, cCodigoAEAT)
   sqlite3_bind_text(stmt, 2, cNombre)
   sqlite3_bind_int(stmt, 3, iif(lActivo, 1, 0))

   IF nId != 0
      sqlite3_bind_int(stmt, 4, nId)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
