#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerProveedores(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT p.Id, p.Nombre, p.Nif, p.Direccion, p.Poblacion, " + ;
      "p.Provincia, p.Telefono, p.Email, p.IBAN, p.Activo, " + ;
      "p.PaisId, p.TipoIdentificacionId " + ;
      "FROM Proveedores p ORDER BY p.Nombre")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_int(stmt, 9) != 0, ;
         sqlite3_column_int(stmt, 10), ;
         sqlite3_column_int(stmt, 11) })
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerProveedorPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Nombre, Nif, NifIva, Direccion, Poblacion, Provincia, " + ;
      "CodigoPostal, Telefono, Email, IBAN, Activo, " + ;
      "PaisId, TipoIdentificacionId FROM Proveedores WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_int(stmt, 11) != 0, ;
         sqlite3_column_int(stmt, 12), ;
         sqlite3_column_int(stmt, 13) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarProveedor(db, nId, cNombre, cNif, cNifIva, nTipoIdId, nPaisId, ;
      cDireccion, cPoblacion, cProvincia, cCp, cTelefono, cEmail, cIban, lActivo)
   LOCAL stmt, nRes
   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO Proveedores(Nombre, Nif, NifIva, TipoIdentificacionId, PaisId, " + ;
         "Direccion, Poblacion, Provincia, CodigoPostal, Telefono, Email, IBAN, Activo) " + ;
         "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE Proveedores SET Nombre=?, Nif=?, NifIva=?, TipoIdentificacionId=?, PaisId=?, " + ;
         "Direccion=?, Poblacion=?, Provincia=?, CodigoPostal=?, Telefono=?, Email=?, IBAN=?, Activo=? WHERE Id=?")
   ENDIF
   sqlite3_bind_text(stmt, 1, cNombre)
   sqlite3_bind_text(stmt, 2, cNif)
   IF cNifIva == NIL
      sqlite3_bind_null(stmt, 3)
   ELSE
      sqlite3_bind_text(stmt, 3, cNifIva)
   ENDIF
   IF nTipoIdId == 0; sqlite3_bind_null(stmt, 4); ELSE; sqlite3_bind_int(stmt, 4, nTipoIdId); ENDIF
   IF nPaisId == 0; sqlite3_bind_null(stmt, 5); ELSE; sqlite3_bind_int(stmt, 5, nPaisId); ENDIF
   sqlite3_bind_text(stmt, 6, cDireccion)
   sqlite3_bind_text(stmt, 7, cPoblacion)
   sqlite3_bind_text(stmt, 8, cProvincia)
   sqlite3_bind_text(stmt, 9, cCp)
   sqlite3_bind_text(stmt, 10, cTelefono)
   sqlite3_bind_text(stmt, 11, cEmail)
   sqlite3_bind_text(stmt, 12, cIban)
   sqlite3_bind_int(stmt, 13, Iif(lActivo, 1, 0))
   IF nId != 0
      sqlite3_bind_int(stmt, 14, nId)
   ENDIF
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION EliminarProveedor(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "DELETE FROM Proveedores WHERE Id = ?")
   LOCAL nRes
   sqlite3_bind_int(stmt, 1, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
