#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerPaises(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Codigo, Nombre, Nacionalidad, EsUE, Activo FROM Paises ORDER BY Nombre")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4) != 0, ;
         sqlite3_column_int(stmt, 5) != 0 } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerPaisPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Codigo, Nombre, Nacionalidad, EsUE, Activo FROM Paises WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4) != 0, ;
         sqlite3_column_int(stmt, 5) != 0 }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerPaisPorCodigo(db, cCodigo)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Codigo, Nombre, Nacionalidad, EsUE, Activo FROM Paises WHERE Codigo = ?")
   LOCAL aResult := NIL
   sqlite3_bind_text(stmt, 1, cCodigo)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4) != 0, ;
         sqlite3_column_int(stmt, 5) != 0 }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerPaisesUE(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Codigo, Nombre FROM Paises WHERE EsUE = 1 AND Activo = 1 ORDER BY Nombre")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2) } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarPais(db, nId, cCodigo, cNombre, cNacionalidad, lEsUE, lActivo)
   LOCAL stmt, nRes

   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO Paises(Codigo, Nombre, Nacionalidad, EsUE, Activo) VALUES(?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE Paises SET Codigo=?, Nombre=?, Nacionalidad=?, EsUE=?, Activo=? WHERE Id=?")
   ENDIF

   sqlite3_bind_text(stmt, 1, cCodigo)
   sqlite3_bind_text(stmt, 2, cNombre)
   sqlite3_bind_text(stmt, 3, cNacionalidad)
   sqlite3_bind_int(stmt, 4, iif(lEsUE, 1, 0))
   sqlite3_bind_int(stmt, 5, iif(lActivo, 1, 0))

   IF nId != 0
      sqlite3_bind_int(stmt, 6, nId)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
