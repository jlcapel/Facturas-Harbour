#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerBienesInversion(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Nombre, FechaAdquisicion, CAST(ValorAdquisicion AS REAL), " + ;
      "CAST(PorcentajeUsoActividad AS REAL), CAST(AmortizacionAnual AS REAL), " + ;
      "CAST(ValorAmortizado AS REAL), CAST(ValorNetoContable AS REAL), " + ;
      "Categoria, FechaInicioAmortizacion, EnUso, FechaBaja " + ;
      "FROM BienesInversion ORDER BY Nombre")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         SqlDateToDate(sqlite3_column_text(stmt, 2)), ;
         Val(sqlite3_column_text(stmt, 3)), ;
         Val(sqlite3_column_text(stmt, 4)), ;
         Val(sqlite3_column_text(stmt, 5)), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         Val(sqlite3_column_text(stmt, 7)), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_int(stmt, 10) != 0, ;
         sqlite3_column_text(stmt, 11) })
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerBienInversionPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Nombre, FechaAdquisicion, ValorAdquisicion, " + ;
      "PorcentajeUsoActividad, AmortizacionAnual, " + ;
      "ValorAmortizado, ValorNetoContable, " + ;
      "Categoria, FechaInicioAmortizacion, EnUso, FechaBaja " + ;
      "FROM BienesInversion WHERE Id = ?")
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
         sqlite3_column_int(stmt, 10) != 0, ;
         sqlite3_column_text(stmt, 11) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarBienInversion(db, nId, cNombre, dFechaAdq, nValorAdq, nPctUso, ;
      nAmortAnual, nValorAmort, nValorNeto, cCategoria, dFechaIniAmort, lEnUso, dFechaBaja)
   LOCAL stmt, nRes
   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO BienesInversion(Nombre, FechaAdquisicion, ValorAdquisicion, " + ;
         "PorcentajeUsoActividad, AmortizacionAnual, ValorAmortizado, ValorNetoContable, " + ;
         "Categoria, FechaInicioAmortizacion, EnUso, FechaBaja) " + ;
         "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE BienesInversion SET Nombre=?, FechaAdquisicion=?, ValorAdquisicion=?, " + ;
         "PorcentajeUsoActividad=?, AmortizacionAnual=?, ValorAmortizado=?, ValorNetoContable=?, " + ;
         "Categoria=?, FechaInicioAmortizacion=?, EnUso=?, FechaBaja=? WHERE Id=?")
   ENDIF
   sqlite3_bind_text(stmt, 1, cNombre)
   sqlite3_bind_text(stmt, 2, FechaISO8601(dFechaAdq))
   sqlite3_bind_text(stmt, 3, Str(nValorAdq, 12, 2))
   sqlite3_bind_text(stmt, 4, Str(nPctUso, 6, 2))
   sqlite3_bind_text(stmt, 5, Str(nAmortAnual, 12, 2))
   sqlite3_bind_text(stmt, 6, Str(nValorAmort, 12, 2))
   sqlite3_bind_text(stmt, 7, Str(nValorNeto, 12, 2))
   IF Empty(cCategoria)
      sqlite3_bind_null(stmt, 8)
   ELSE
      sqlite3_bind_text(stmt, 8, cCategoria)
   ENDIF
   IF dFechaIniAmort == NIL
      sqlite3_bind_null(stmt, 9)
   ELSE
      sqlite3_bind_text(stmt, 9, FechaISO8601(dFechaIniAmort))
   ENDIF
   sqlite3_bind_int(stmt, 10, Iif(lEnUso, 1, 0))
   IF dFechaBaja == NIL
      sqlite3_bind_null(stmt, 11)
   ELSE
      sqlite3_bind_text(stmt, 11, FechaISO8601(dFechaBaja))
   ENDIF
   IF nId != 0
      sqlite3_bind_int(stmt, 12, nId)
   ENDIF
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION EliminarBienInversion(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "DELETE FROM BienesInversion WHERE Id = ?")
   LOCAL nRes
   sqlite3_bind_int(stmt, 1, nId)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE
