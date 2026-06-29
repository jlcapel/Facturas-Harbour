#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerGastos(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT g.Id, g.NumeroFactura, g.FechaEmision, g.TipoDocumento, " + ;
      "p.Nombre, CAST(g.BaseImponible AS REAL), CAST(g.Total AS REAL), " + ;
      "g.Pagado, g.ProveedorId, g.CategoriaGastoId, g.MedioPago " + ;
      "FROM Gastos g JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "ORDER BY g.FechaEmision DESC")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         SqlDateToDate(sqlite3_column_text(stmt, 2)), ;
         sqlite3_column_int(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         Val(sqlite3_column_text(stmt, 5)), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         sqlite3_column_int(stmt, 7) != 0, ;
         sqlite3_column_int(stmt, 8), ;
         sqlite3_column_int(stmt, 9), ;
         sqlite3_column_int(stmt, 10) })
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerGastoPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT g.Id, g.NumeroFactura, g.NumeroRecepcion, " + ;
      "g.FechaEmision, g.FechaOperacion, g.FechaRecepcion, " + ;
      "g.TipoDocumento, g.ProveedorId, g.CategoriaGastoId, " + ;
      "g.Descripcion, CAST(g.BaseImponible AS REAL), " + ;
      "CAST(g.IvaPorcentaje AS REAL), CAST(g.IvaImporte AS REAL), " + ;
      "CAST(g.RetencionPorcentaje AS REAL), CAST(g.RetencionImporte AS REAL), " + ;
      "CAST(g.Total AS REAL), g.GastoDeducibleIRPF, " + ;
      "g.MedioPago, g.Pagado, g.FechaPago, " + ;
      "g.Observaciones, g.RutaAdjunto, g.IVADeducible, " + ;
      "g.BienInversionId, " + ;
      "p.Nombre, p.Nif " + ;
      "FROM Gastos g JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "WHERE g.Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_int(stmt, 2), ;
         SqlDateToDate(sqlite3_column_text(stmt, 3)), ;
         SqlDateToDate(sqlite3_column_text(stmt, 4)), ;
         SqlDateToDate(sqlite3_column_text(stmt, 5)), ;
         sqlite3_column_int(stmt, 6), ;
         sqlite3_column_int(stmt, 7), ;
         sqlite3_column_int(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         Val(sqlite3_column_text(stmt, 10)), ;
         Val(sqlite3_column_text(stmt, 11)), ;
         Val(sqlite3_column_text(stmt, 12)), ;
         Val(sqlite3_column_text(stmt, 13)), ;
         Val(sqlite3_column_text(stmt, 14)), ;
         Val(sqlite3_column_text(stmt, 15)), ;
         sqlite3_column_text(stmt, 16), ;
         sqlite3_column_int(stmt, 17), ;
         sqlite3_column_int(stmt, 18) != 0, ;
         sqlite3_column_text(stmt, 19), ;
         sqlite3_column_text(stmt, 20), ;
         sqlite3_column_text(stmt, 21), ;
         sqlite3_column_int(stmt, 22) != 0, ;
         sqlite3_column_int(stmt, 23), ;
         sqlite3_column_text(stmt, 24), ;
         sqlite3_column_text(stmt, 25) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION CrearGasto(db, aGasto)
   LOCAL stmt, nId

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO Gastos(NumeroFactura, NumeroRecepcion, " + ;
      "FechaEmision, FechaOperacion, FechaRecepcion, " + ;
      "TipoDocumento, ProveedorId, CategoriaGastoId, " + ;
      "Descripcion, BaseImponible, IvaPorcentaje, IvaImporte, " + ;
      "RetencionPorcentaje, RetencionImporte, Total, " + ;
      "GastoDeducibleIRPF, MedioPago, Pagado, FechaPago, " + ;
      "Observaciones, RutaAdjunto, IVADeducible, BienInversionId, FechaCreacion) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))")

   sqlite3_bind_text(stmt, 1, aGasto[1])
   IF aGasto[2] == NIL; sqlite3_bind_null(stmt, 2); ELSE; sqlite3_bind_int(stmt, 2, aGasto[2]); ENDIF
   sqlite3_bind_text(stmt, 3, FechaISO8601(aGasto[3]))
   IF aGasto[4] == NIL; sqlite3_bind_text(stmt, 4, FechaISO8601(aGasto[3])); ELSE; sqlite3_bind_text(stmt, 4, FechaISO8601(aGasto[4])); ENDIF
   sqlite3_bind_text(stmt, 5, FechaISO8601(aGasto[5]))
   sqlite3_bind_int(stmt, 6, aGasto[6])
   sqlite3_bind_int(stmt, 7, aGasto[7])
   IF aGasto[8] == NIL; sqlite3_bind_null(stmt, 8); ELSE; sqlite3_bind_int(stmt, 8, aGasto[8]); ENDIF
   sqlite3_bind_text(stmt, 9, aGasto[9])
   sqlite3_bind_text(stmt, 10, Str(aGasto[10], 12, 2))
   sqlite3_bind_text(stmt, 11, Str(aGasto[11], 6, 2))
   sqlite3_bind_text(stmt, 12, Str(aGasto[12], 12, 2))
   sqlite3_bind_text(stmt, 13, Str(aGasto[13], 6, 2))
   sqlite3_bind_text(stmt, 14, Str(aGasto[14], 12, 2))
   sqlite3_bind_text(stmt, 15, Str(aGasto[15], 12, 2))
   sqlite3_bind_text(stmt, 16, aGasto[16])
   sqlite3_bind_int(stmt, 17, aGasto[17])
   sqlite3_bind_int(stmt, 18, Iif(aGasto[18], 1, 0))
   IF aGasto[19] == NIL; sqlite3_bind_null(stmt, 19); ELSE; sqlite3_bind_text(stmt, 19, FechaISO8601(aGasto[19])); ENDIF
   sqlite3_bind_text(stmt, 20, aGasto[20])
   sqlite3_bind_text(stmt, 21, aGasto[21])
   sqlite3_bind_int(stmt, 22, Iif(aGasto[22], 1, 0))
   IF aGasto[23] == NIL; sqlite3_bind_null(stmt, 23); ELSE; sqlite3_bind_int(stmt, 23, aGasto[23]); ENDIF

   IF sqlite3_step(stmt) != SQLITE_DONE
      sqlite3_finalize(stmt)
      RETURN 0
   ENDIF
   sqlite3_finalize(stmt)
   nId := sqlite3_last_insert_rowid(db)
   RETURN nId

FUNCTION ActualizarGasto(db, nId, aGasto)
   LOCAL stmt, nRes
   stmt := sqlite3_prepare(db, ;
      "UPDATE Gastos SET NumeroFactura=?, NumeroRecepcion=?, " + ;
      "FechaEmision=?, FechaOperacion=?, FechaRecepcion=?, " + ;
      "TipoDocumento=?, ProveedorId=?, CategoriaGastoId=?, " + ;
      "Descripcion=?, BaseImponible=?, IvaPorcentaje=?, IvaImporte=?, " + ;
      "RetencionPorcentaje=?, RetencionImporte=?, Total=?, " + ;
      "GastoDeducibleIRPF=?, MedioPago=?, Pagado=?, FechaPago=?, " + ;
      "Observaciones=?, RutaAdjunto=?, IVADeducible=?, BienInversionId=? " + ;
      "WHERE Id=?")
   sqlite3_bind_text(stmt, 1, aGasto[1])
   IF aGasto[2] == NIL; sqlite3_bind_null(stmt, 2); ELSE; sqlite3_bind_int(stmt, 2, aGasto[2]); ENDIF
   sqlite3_bind_text(stmt, 3, FechaISO8601(aGasto[3]))
   IF aGasto[4] == NIL; sqlite3_bind_text(stmt, 4, FechaISO8601(aGasto[3])); ELSE; sqlite3_bind_text(stmt, 4, FechaISO8601(aGasto[4])); ENDIF
   sqlite3_bind_text(stmt, 5, FechaISO8601(aGasto[5]))
   sqlite3_bind_int(stmt, 6, aGasto[6])
   sqlite3_bind_int(stmt, 7, aGasto[7])
   IF aGasto[8] == NIL; sqlite3_bind_null(stmt, 8); ELSE; sqlite3_bind_int(stmt, 8, aGasto[8]); ENDIF
   sqlite3_bind_text(stmt, 9, aGasto[9])
   sqlite3_bind_text(stmt, 10, Str(aGasto[10], 12, 2))
   sqlite3_bind_text(stmt, 11, Str(aGasto[11], 6, 2))
   sqlite3_bind_text(stmt, 12, Str(aGasto[12], 12, 2))
   sqlite3_bind_text(stmt, 13, Str(aGasto[13], 6, 2))
   sqlite3_bind_text(stmt, 14, Str(aGasto[14], 12, 2))
   sqlite3_bind_text(stmt, 15, Str(aGasto[15], 12, 2))
   sqlite3_bind_text(stmt, 16, aGasto[16])
   sqlite3_bind_int(stmt, 17, aGasto[17])
   sqlite3_bind_int(stmt, 18, Iif(aGasto[18], 1, 0))
   IF aGasto[19] == NIL; sqlite3_bind_null(stmt, 19); ELSE; sqlite3_bind_text(stmt, 19, FechaISO8601(aGasto[19])); ENDIF
   sqlite3_bind_text(stmt, 20, aGasto[20])
   sqlite3_bind_text(stmt, 21, aGasto[21])
   sqlite3_bind_int(stmt, 22, Iif(aGasto[22], 1, 0))
   IF aGasto[23] == NIL; sqlite3_bind_null(stmt, 23); ELSE; sqlite3_bind_int(stmt, 23, aGasto[23]); ENDIF
   sqlite3_bind_int(stmt, 24, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION EliminarGasto(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "DELETE FROM Gastos WHERE Id = ?")
   LOCAL nRes
   sqlite3_bind_int(stmt, 1, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION MarcarGastoPagado(db, nId, lPagado)
   LOCAL stmt := sqlite3_prepare(db, ;
      "UPDATE Gastos SET Pagado=?, FechaPago=Iif(?=1, date('now'), NIL) WHERE Id=?")
   LOCAL nRes
   sqlite3_bind_int(stmt, 1, Iif(lPagado, 1, 0))
   sqlite3_bind_int(stmt, 2, Iif(lPagado, 1, 0))
   sqlite3_bind_int(stmt, 3, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION GenerarNumeroRecepcion(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT MAX(NumeroRecepcion) FROM Gastos")
   LOCAL nNum := 1
   IF sqlite3_step(stmt) == SQLITE_ROW .AND. sqlite3_column_int(stmt, 0) > 0
      nNum := sqlite3_column_int(stmt, 0) + 1
   ENDIF
   sqlite3_finalize(stmt)
   RETURN nNum
