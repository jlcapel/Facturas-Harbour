#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerClientes(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT c.Id, c.Nombre, c.TipoCliente, c.Nif, c.PaisId, c.TipoIdentificacionId, " + ;
      "c.NifIva, c.Direccion, c.Poblacion, c.Provincia, " + ;
      "c.CodigoPostal, c.Telefono, c.Email, c.Activo " + ;
      "FROM Clientes c ORDER BY c.Nombre")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_int(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4), ;
         sqlite3_column_int(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_text(stmt, 11), ;
         sqlite3_column_text(stmt, 12), ;
         sqlite3_column_int(stmt, 13) != 0 } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerClientePorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Nombre, TipoCliente, Nif, PaisId, TipoIdentificacionId, " + ;
      "NifIva, Direccion, Poblacion, Provincia, CodigoPostal, Telefono, Email, Activo " + ;
      "FROM Clientes WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_int(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4), ;
         sqlite3_column_int(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_text(stmt, 11), ;
         sqlite3_column_text(stmt, 12), ;
         sqlite3_column_int(stmt, 13) != 0 }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarCliente(db, nId, cNombre, nTipoCliente, nPaisId, nTipoIdId, cNif, cNifIva, ;
      cDireccion, cPoblacion, cProvincia, cCodigoPostal, cTelefono, cEmail, lActivo)
   LOCAL stmt, nRes

   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO Clientes(Nombre, TipoCliente, PaisId, TipoIdentificacionId, Nif, NifIva, " + ;
         "Direccion, Poblacion, Provincia, CodigoPostal, Telefono, Email, Activo) " + ;
         "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE Clientes SET Nombre=?, TipoCliente=?, PaisId=?, TipoIdentificacionId=?, " + ;
         "Nif=?, NifIva=?, Direccion=?, Poblacion=?, Provincia=?, CodigoPostal=?, " + ;
         "Telefono=?, Email=?, Activo=? WHERE Id=?")
   ENDIF

   sqlite3_bind_text(stmt, 1, cNombre)
   sqlite3_bind_int(stmt, 2, nTipoCliente)
   IF nPaisId == 0
      sqlite3_bind_null(stmt, 3)
   ELSE
      sqlite3_bind_int(stmt, 3, nPaisId)
   ENDIF
   IF nTipoIdId == 0
      sqlite3_bind_null(stmt, 4)
   ELSE
      sqlite3_bind_int(stmt, 4, nTipoIdId)
   ENDIF
   sqlite3_bind_text(stmt, 5, cNif)
   IF cNifIva == NIL
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_text(stmt, 6, cNifIva)
   ENDIF
   sqlite3_bind_text(stmt, 7, cDireccion)
   sqlite3_bind_text(stmt, 8, cPoblacion)
   sqlite3_bind_text(stmt, 9, cProvincia)
   sqlite3_bind_text(stmt, 10, cCodigoPostal)
   sqlite3_bind_text(stmt, 11, cTelefono)
   sqlite3_bind_text(stmt, 12, cEmail)
   sqlite3_bind_int(stmt, 13, iif(lActivo, 1, 0))

   IF nId != 0
      sqlite3_bind_int(stmt, 14, nId)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION EliminarCliente(db, nId)
   LOCAL stmt, nRes
   stmt := sqlite3_prepare(db, "DELETE FROM Clientes WHERE Id = ?")
   sqlite3_bind_int(stmt, 1, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
