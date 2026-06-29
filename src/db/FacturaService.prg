#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerFacturas(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT f.Id, f.NumeroFactura, f.FechaEmision, f.AeatTipoFactura, " + ;
      "c.Nombre, CAST(f.BaseImponible AS REAL), CAST(f.Total AS REAL), " + ;
      "f.Estado, r.CSV, r.EnviadoAEAT, f.ClienteId, f.TipoFactura " + ;
      "FROM Facturas f " + ;
      "JOIN Clientes c ON f.ClienteId = c.Id " + ;
      "LEFT JOIN RegistrosFacturacion r ON r.FacturaId = f.Id " + ;
      "ORDER BY f.FechaEmision DESC")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         SqlDateToDate(sqlite3_column_text(stmt, 2)), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         Val(sqlite3_column_text(stmt, 5)), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         sqlite3_column_int(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_int(stmt, 9), ;
         sqlite3_column_int(stmt, 10), ;
         sqlite3_column_int(stmt, 11) })
   ENDDO
   sqlite3_finalize(stmt)
   RETURN aResult

FUNCTION ObtenerFacturaPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT f.Id, f.NumeroFactura, f.FechaEmision, f.FechaOperacion, " + ;
      "f.ClienteId, f.TipoFactura, f.Estado, f.FacturaRectificadaId, " + ;
      "f.Descripcion, f.AeatTipoFactura, f.TipoRectificacion, " + ;
      "CAST(f.BaseImponible AS REAL), CAST(f.IvaImporte AS REAL), " + ;
      "CAST(f.IrpfPorcentaje AS REAL), CAST(f.IrpfImporte AS REAL), " + ;
      "CAST(f.Total AS REAL), " + ;
      "CAST(f.DescuentoGlobalPorcentaje AS REAL), CAST(f.DescuentoGlobalImporte AS REAL), " + ;
      "c.Nombre, c.Nif, c.TipoCliente, p.Codigo, p.Nombre, " + ;
      "ti.CodigoAEAT, " + ;
      "r.Id, r.Hash, r.CSV, r.EnviadoAEAT, r.RespuestaAEAT, r.CodigoQR, r.FechaEnvioAEAT " + ;
      "FROM Facturas f " + ;
      "JOIN Clientes c ON f.ClienteId = c.Id " + ;
      "LEFT JOIN Paises p ON c.PaisId = p.Id " + ;
      "LEFT JOIN TiposIdentificacion ti ON c.TipoIdentificacionId = ti.Id " + ;
      "LEFT JOIN RegistrosFacturacion r ON r.FacturaId = f.Id " + ;
      "WHERE f.Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         SqlDateToDate(sqlite3_column_text(stmt, 2)), ;
         SqlDateToDate(sqlite3_column_text(stmt, 3)), ;
         sqlite3_column_int(stmt, 4), ;
         sqlite3_column_int(stmt, 5), ;
         sqlite3_column_int(stmt, 6), ;
         sqlite3_column_int(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         Val(sqlite3_column_text(stmt, 11)), ;
         Val(sqlite3_column_text(stmt, 12)), ;
         Val(sqlite3_column_text(stmt, 13)), ;
         Val(sqlite3_column_text(stmt, 14)), ;
         Val(sqlite3_column_text(stmt, 15)), ;
         Val(sqlite3_column_text(stmt, 16)), ;
         Val(sqlite3_column_text(stmt, 17)), ;
         sqlite3_column_text(stmt, 18), ;
         sqlite3_column_text(stmt, 19), ;
         sqlite3_column_int(stmt, 20), ;
         sqlite3_column_text(stmt, 21), ;
         sqlite3_column_text(stmt, 22), ;
         sqlite3_column_text(stmt, 23), ;
         sqlite3_column_int(stmt, 24), ;
         sqlite3_column_text(stmt, 25), ;
         sqlite3_column_text(stmt, 26), ;
         sqlite3_column_int(stmt, 27), ;
         sqlite3_column_text(stmt, 28), ;
         sqlite3_column_text(stmt, 29), ;
         sqlite3_column_text(stmt, 30) }
   ENDIF
   sqlite3_finalize(stmt)

   IF aResult != NIL
      aResult := ObtenerLineasFactura(db, nId, aResult)
   ENDIF
   RETURN aResult

FUNCTION CrearFactura(db, aFactura, aLineas)
   LOCAL nFacturaId, nI
   LOCAL nBaseImp := 0, nIvaImp := 0, nIrpfPct, nIrpfImp, nTotal

   nIrpfPct := ObtenerIrpfPorcentaje(db)

   FOR nI := 1 TO Len(aLineas)
      nBaseImp := nBaseImp + aLineas[nI][6]
      nIvaImp := nIvaImp + aLineas[nI][6] * aLineas[nI][7] / 100
   NEXT

   nIrpfImp := nBaseImp * nIrpfPct / 100
   nTotal := nBaseImp + nIvaImp - nIrpfImp

   aFactura[11] := nBaseImp
   aFactura[12] := nIvaImp
   aFactura[13] := nIrpfPct
   aFactura[14] := nIrpfImp
   aFactura[15] := nTotal

   nFacturaId := InsertarFactura(db, aFactura)
   IF nFacturaId == 0
      RETURN 0
   ENDIF

   FOR nI := 1 TO Len(aLineas)
      aLineas[nI][1] := nFacturaId
      InsertarLineaFactura(db, aLineas[nI])
   NEXT

   RETURN nFacturaId

FUNCTION GenerarNumeroFactura(db)
   LOCAL nAnyo := Year(Date())
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT NumeroFactura FROM Facturas WHERE NumeroFactura LIKE ? " + ;
      "ORDER BY NumeroFactura DESC LIMIT 1")
   LOCAL cPrefijo := "F" + Str(nAnyo, 4) + "-"
   LOCAL nNumero := 1, cUltimo, nGuion, nSeq

   sqlite3_bind_text(stmt, 1, cPrefijo + "%")
   IF sqlite3_step(stmt) == SQLITE_ROW
      cUltimo := sqlite3_column_text(stmt, 0)
      nGuion := At("-", cUltimo)
      IF nGuion > 0
         nSeq := Val(SubStr(cUltimo, nGuion + 1))
         IF nSeq > 0
            nNumero := nSeq + 1
         ENDIF
      ENDIF
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cPrefijo + PadL(nNumero, 6, "0")

FUNCTION ObtenerIrpfPorcentaje(db)
   LOCAL cIrpf := ObtenerConfiguracion(db, "IRPF.Porcentaje")
   IF cIrpf == NIL .OR. Empty(cIrpf)
      RETURN 0
   ENDIF
   RETURN Val(cIrpf)

STATIC FUNCTION InsertarFactura(db, aF)
   LOCAL stmt := sqlite3_prepare(db, ;
      "INSERT INTO Facturas(NumeroFactura, FechaEmision, FechaOperacion, " + ;
      "ClienteId, TipoFactura, Estado, FacturaRectificadaId, " + ;
      "Descripcion, AeatTipoFactura, TipoRectificacion, " + ;
      "BaseImponible, IvaImporte, IrpfPorcentaje, IrpfImporte, Total, " + ;
      "DescuentoGlobalPorcentaje, DescuentoGlobalImporte) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   LOCAL nId

   sqlite3_bind_text(stmt, 1, aF[1])
   sqlite3_bind_text(stmt, 2, FechaISO8601(aF[2]))
   IF aF[3] == NIL
      sqlite3_bind_text(stmt, 3, FechaISO8601(aF[2]))
   ELSE
      sqlite3_bind_text(stmt, 3, FechaISO8601(aF[3]))
   ENDIF
   sqlite3_bind_int(stmt, 4, aF[4])
   sqlite3_bind_int(stmt, 5, aF[5])
   sqlite3_bind_int(stmt, 6, aF[6])
   IF aF[7] == NIL .OR. aF[7] == 0
      sqlite3_bind_null(stmt, 7)
   ELSE
      sqlite3_bind_int(stmt, 7, aF[7])
   ENDIF
   sqlite3_bind_text(stmt, 8, aF[8])
   sqlite3_bind_text(stmt, 9, aF[9])
   sqlite3_bind_text(stmt, 10, aF[10])
   sqlite3_bind_text(stmt, 11, Str(aF[11], 12, 2))
   sqlite3_bind_text(stmt, 12, Str(aF[12], 12, 2))
   sqlite3_bind_text(stmt, 13, Str(aF[13], 6, 2))
   sqlite3_bind_text(stmt, 14, Str(aF[14], 12, 2))
   sqlite3_bind_text(stmt, 15, Str(aF[15], 12, 2))
   IF aF[16] == NIL .OR. aF[16] == 0
      sqlite3_bind_null(stmt, 16)
   ELSE
      sqlite3_bind_text(stmt, 16, Str(aF[16], 6, 2))
   ENDIF
   IF aF[17] == NIL .OR. aF[17] == 0
      sqlite3_bind_null(stmt, 17)
   ELSE
      sqlite3_bind_text(stmt, 17, Str(aF[17], 12, 2))
   ENDIF

   IF sqlite3_step(stmt) != SQLITE_DONE
      sqlite3_finalize(stmt)
      RETURN 0
   ENDIF
   sqlite3_finalize(stmt)
   nId := sqlite3_last_insert_rowid(db)
   RETURN nId

STATIC FUNCTION InsertarLineaFactura(db, aL)
   LOCAL stmt, nRes
   stmt := sqlite3_prepare(db, ;
      "INSERT INTO LineasFactura(FacturaId, ArticuloId, TipoIvaId, " + ;
      "Descripcion, Cantidad, PrecioUnitario, IvaPorcentaje, Importe, " + ;
      "DescuentoPorcentaje, DescuentoImporte) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   sqlite3_bind_int(stmt, 1, aL[1])
   IF aL[2] == NIL .OR. aL[2] == 0
      sqlite3_bind_null(stmt, 2)
   ELSE
      sqlite3_bind_int(stmt, 2, aL[2])
   ENDIF
   IF aL[3] == NIL .OR. aL[3] == 0
      sqlite3_bind_null(stmt, 3)
   ELSE
      sqlite3_bind_int(stmt, 3, aL[3])
   ENDIF
   sqlite3_bind_text(stmt, 4, aL[4])
   sqlite3_bind_text(stmt, 5, Str(aL[5], 12, 2))
   sqlite3_bind_text(stmt, 6, Str(aL[6], 12, 2))
   sqlite3_bind_text(stmt, 7, Str(aL[7], 6, 2))
   sqlite3_bind_text(stmt, 8, Str(aL[8], 12, 2))
   IF aL[9] == NIL .OR. aL[9] == 0
      sqlite3_bind_null(stmt, 9)
   ELSE
      sqlite3_bind_text(stmt, 9, Str(aL[9], 6, 2))
   ENDIF
   IF aL[10] == NIL .OR. aL[10] == 0
      sqlite3_bind_null(stmt, 10)
   ELSE
      sqlite3_bind_text(stmt, 10, Str(aL[10], 12, 2))
   ENDIF
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

STATIC FUNCTION ObtenerLineasFactura(db, nFacturaId, aFactura)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT l.Id, l.ArticuloId, l.TipoIvaId, l.Descripcion, " + ;
      "CAST(l.Cantidad AS REAL), CAST(l.PrecioUnitario AS REAL), " + ;
      "CAST(l.IvaPorcentaje AS REAL), CAST(l.Importe AS REAL), " + ;
      "CAST(l.DescuentoPorcentaje AS REAL), CAST(l.DescuentoImporte AS REAL), " + ;
      "a.Codigo, a.Descripcion, t.Nombre " + ;
      "FROM LineasFactura l " + ;
      "LEFT JOIN Articulos a ON l.ArticuloId = a.Id " + ;
      "LEFT JOIN TiposIva t ON l.TipoIvaId = t.Id " + ;
      "WHERE l.FacturaId = ? ORDER BY l.Id")
   LOCAL aLineas := {}
   sqlite3_bind_int(stmt, 1, nFacturaId)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aLineas, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_int(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         Val(sqlite3_column_text(stmt, 4)), ;
         Val(sqlite3_column_text(stmt, 5)), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         Val(sqlite3_column_text(stmt, 7)), ;
         Val(sqlite3_column_text(stmt, 8)), ;
         Val(sqlite3_column_text(stmt, 9)), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_text(stmt, 11), ;
         sqlite3_column_text(stmt, 12) })
   ENDDO
   sqlite3_finalize(stmt)
   AAdd(aFactura, aLineas)
   RETURN aFactura
