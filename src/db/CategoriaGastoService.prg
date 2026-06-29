#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerCategoriasGasto(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Nombre, PorcentajeDeducibleIRPF, IvaDeducible, Orden, Activo " + ;
      "FROM CategoriasGasto ORDER BY Orden")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0, ;
         sqlite3_column_int(stmt, 4), ;
         sqlite3_column_int(stmt, 5) != 0 })
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerCategoriaGastoPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Nombre, PorcentajeDeducibleIRPF, IvaDeducible, Orden, Activo " + ;
      "FROM CategoriasGasto WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_int(stmt, 3) != 0, ;
         sqlite3_column_int(stmt, 4), ;
         sqlite3_column_int(stmt, 5) != 0 }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarCategoriaGasto(db, nId, cNombre, cPctDeducible, lIvaDeducible, nOrden, lActivo)
   LOCAL stmt, nRes
   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO CategoriasGasto(Nombre, PorcentajeDeducibleIRPF, IvaDeducible, Orden, Activo) " + ;
         "VALUES(?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE CategoriasGasto SET Nombre=?, PorcentajeDeducibleIRPF=?, IvaDeducible=?, Orden=?, Activo=? WHERE Id=?")
   ENDIF
   sqlite3_bind_text(stmt, 1, cNombre)
   sqlite3_bind_text(stmt, 2, cPctDeducible)
   sqlite3_bind_int(stmt, 3, Iif(lIvaDeducible, 1, 0))
   sqlite3_bind_int(stmt, 4, nOrden)
   sqlite3_bind_int(stmt, 5, Iif(lActivo, 1, 0))
   IF nId != 0
      sqlite3_bind_int(stmt, 6, nId)
   ENDIF
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION EliminarCategoriaGasto(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "DELETE FROM CategoriasGasto WHERE Id = ?")
   LOCAL nRes
   sqlite3_bind_int(stmt, 1, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
