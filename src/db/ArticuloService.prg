#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerArticulos(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT a.Id, a.Codigo, a.Descripcion, a.PrecioUnitario, a.UnidadMedida, " + ;
      "a.Activo, a.TipoIvaId " + ;
      "FROM Articulos a ORDER BY a.Codigo")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_int(stmt, 5) != 0, ;
         sqlite3_column_int(stmt, 6) } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerArticuloPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Codigo, Descripcion, PrecioUnitario, UnidadMedida, Activo, TipoIvaId " + ;
      "FROM Articulos WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_int(stmt, 5) != 0, ;
         sqlite3_column_int(stmt, 6) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarArticulo(db, nId, cCodigo, cDescripcion, cPrecioUnitario, cUnidadMedida, lActivo, nTipoIvaId)
   LOCAL stmt, nRes

   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO Articulos(Codigo, Descripcion, PrecioUnitario, UnidadMedida, Activo, TipoIvaId) " + ;
         "VALUES(?, ?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE Articulos SET Codigo=?, Descripcion=?, PrecioUnitario=?, " + ;
         "UnidadMedida=?, Activo=?, TipoIvaId=? WHERE Id=?")
   ENDIF

   sqlite3_bind_text(stmt, 1, cCodigo)
   sqlite3_bind_text(stmt, 2, cDescripcion)
   sqlite3_bind_text(stmt, 3, cPrecioUnitario)
   sqlite3_bind_text(stmt, 4, cUnidadMedida)
   sqlite3_bind_int(stmt, 5, iif(lActivo, 1, 0))
   IF nTipoIvaId == 0
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_int(stmt, 6, nTipoIvaId)
   ENDIF

   IF nId != 0
      sqlite3_bind_int(stmt, 7, nId)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION EliminarArticulo(db, nId)
   LOCAL stmt, nRes
   stmt := sqlite3_prepare(db, "DELETE FROM Articulos WHERE Id = ?")
   sqlite3_bind_int(stmt, 1, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
