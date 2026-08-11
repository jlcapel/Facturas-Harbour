#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerTiposIva(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Nombre, Porcentaje, Activo, FechaInicio, FechaFin, Impuesto, ClaveRegimen, CalificacionOperacion, DescripcionFiscal FROM TiposIva ORDER BY CAST(Porcentaje AS REAL)")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4) != 0, ;
         sqlite3_column_text(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10) } )
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerTipoIvaPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Nombre, Porcentaje, Activo, FechaInicio, FechaFin, Impuesto, ClaveRegimen, CalificacionOperacion, DescripcionFiscal FROM TiposIva WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_int(stmt, 4) != 0, ;
         sqlite3_column_text(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION GuardarTipoIva(db, nId, cNombre, cPorcentaje, lActivo, cFechaInicio, cFechaFin, cImpuesto, cClaveRegimen, cCalificacionOperacion, cDescripcionFiscal)
   LOCAL stmt, nRes

   cImpuesto := NormalizarCodigoFiscalTipoIva(cImpuesto, "01")
   cClaveRegimen := NormalizarCodigoFiscalTipoIva(cClaveRegimen, "01")
   cCalificacionOperacion := NormalizarCodigoFiscalTipoIva(cCalificacionOperacion, "S1")
   IF cDescripcionFiscal != NIL
      cDescripcionFiscal := AllTrim(cDescripcionFiscal)
   ENDIF

   IF nId == 0
      stmt := sqlite3_prepare(db, ;
         "INSERT INTO TiposIva(Nombre, Porcentaje, Activo, FechaInicio, FechaFin, Impuesto, ClaveRegimen, CalificacionOperacion, DescripcionFiscal) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)")
   ELSE
      stmt := sqlite3_prepare(db, ;
         "UPDATE TiposIva SET Nombre=?, Porcentaje=?, Activo=?, FechaInicio=?, FechaFin=?, Impuesto=?, ClaveRegimen=?, CalificacionOperacion=?, DescripcionFiscal=? WHERE Id=?")
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

   sqlite3_bind_text(stmt, 6, cImpuesto)
   sqlite3_bind_text(stmt, 7, cClaveRegimen)
   sqlite3_bind_text(stmt, 8, cCalificacionOperacion)
   IF Empty(cDescripcionFiscal)
      sqlite3_bind_null(stmt, 9)
   ELSE
      sqlite3_bind_text(stmt, 9, cDescripcionFiscal)
   ENDIF

   IF nId != 0
      sqlite3_bind_int(stmt, 10, nId)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

STATIC FUNCTION NormalizarCodigoFiscalTipoIva(cValor, cDefecto)
   IF cValor == NIL .OR. Empty(AllTrim(cValor))
      RETURN cDefecto
   ENDIF
RETURN Upper(AllTrim(cValor))
