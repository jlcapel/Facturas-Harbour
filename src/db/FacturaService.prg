#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION ObtenerFacturas(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT f.Id, f.NumeroFactura, f.FechaEmision, f.AeatTipoFactura, " + ;
      "c.Nombre, CAST(f.BaseImponible AS REAL), CAST(f.Total AS REAL), " + ;
      "CASE WHEN f.Estado=1 OR EXISTS(SELECT 1 FROM Facturas fa " + ;
      "JOIN RegistrosFacturacion ra ON ra.FacturaId=fa.Id AND ra.TipoRegistro=1 " + ;
      "WHERE fa.FacturaRectificadaId=f.Id AND fa.TipoFactura=2) THEN 1 ELSE 0 END, " + ;
      "r.CSV, r.EnviadoAEAT, f.ClienteId, f.TipoFactura " + ;
      "FROM Facturas f " + ;
      "JOIN Clientes c ON f.ClienteId = c.Id " + ;
      "LEFT JOIN RegistrosFacturacion r ON r.FacturaId = f.Id AND r.TipoRegistro = 0 " + ;
      "ORDER BY f.FechaEmision DESC")
   LOCAL aResult := {}
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aResult, { ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         SqlDateToDate(sqlite3_column_text(stmt, 3)), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         Val(sqlite3_column_text(stmt, 7)), ;
         sqlite3_column_int(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_int(stmt, 10), ;
         sqlite3_column_int(stmt, 11), ;
         sqlite3_column_int(stmt, 12) })
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
      "LEFT JOIN RegistrosFacturacion r ON r.FacturaId = f.Id AND r.TipoRegistro = 0 " + ;
      "WHERE f.Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := { ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         SqlDateToDate(sqlite3_column_text(stmt, 3)), ;
         SqlDateToDate(sqlite3_column_text(stmt, 4)), ;
         sqlite3_column_int(stmt, 5), ;
         sqlite3_column_int(stmt, 6), ;
         sqlite3_column_int(stmt, 7), ;
         sqlite3_column_int(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_text(stmt, 11), ;
         Val(sqlite3_column_text(stmt, 12)), ;
         Val(sqlite3_column_text(stmt, 13)), ;
         Val(sqlite3_column_text(stmt, 14)), ;
         Val(sqlite3_column_text(stmt, 15)), ;
         Val(sqlite3_column_text(stmt, 16)), ;
         Val(sqlite3_column_text(stmt, 17)), ;
         Val(sqlite3_column_text(stmt, 18)), ;
         sqlite3_column_text(stmt, 19), ;
         sqlite3_column_text(stmt, 20), ;
         sqlite3_column_int(stmt, 21), ;
         sqlite3_column_text(stmt, 22), ;
         sqlite3_column_text(stmt, 23), ;
         sqlite3_column_text(stmt, 24), ;
         sqlite3_column_int(stmt, 25), ;
         sqlite3_column_text(stmt, 26), ;
         sqlite3_column_text(stmt, 27), ;
         sqlite3_column_int(stmt, 28), ;
         sqlite3_column_text(stmt, 29), ;
         sqlite3_column_text(stmt, 30), ;
         sqlite3_column_text(stmt, 31) }
   ENDIF
   sqlite3_finalize(stmt)

   IF aResult != NIL
      aResult := ObtenerLineasFactura(db, nId, aResult)
   ENDIF
   RETURN aResult

FUNCTION CrearFactura(db, aFactura, aLineas)
   LOCAL nFacturaId := 0, nVersionFiscalId := 0, nRegistroId := 0, nI
   LOCAL nBaseImp := 0, nIvaImp := 0, nIrpfPct, nIrpfImp, nTotal
   LOCAL cNifEmisor, cNombreEmisor, aCliente, cNifCliente, cNombreCliente
   LOCAL aPais, cCodigoPais, lEsNacional, aTipoId, cCodigoAEAT
   LOCAL cTipoRectificativa, nFacturaRectificadaId, aTratamiento, aLineasSnapshot
   LOCAL lOk, lEvento

   nIrpfPct := ObtenerIrpfPorcentaje(db)

   FOR nI := 1 TO Len(aLineas)
      IF Len(aLineas[nI]) < 18
         LogInfo("CrearFactura: linea sin tratamiento IVA fiscal")
         RETURN 0
      ENDIF
      aTratamiento := BuscarTratamientoIva(aLineas[nI][16], aLineas[nI][17])
      IF aTratamiento == NIL .OR. (TratamientoIvaExigeIvaCero(aTratamiento) .AND. aLineas[nI][7] != 0)
         LogInfo("CrearFactura: tratamiento IVA no valido")
         RETURN 0
      ENDIF
      aLineas[nI][14] := aTratamiento[3]
      aLineas[nI][15] := aTratamiento[4]
      aLineas[nI][16] := aTratamiento[5]
      aLineas[nI][17] := aTratamiento[6]
      aLineas[nI][18] := aTratamiento[7]
      nBaseImp := nBaseImp + aLineas[nI][8]
      nIvaImp := nIvaImp + CalcularIvaLinea(aLineas[nI][8], aLineas[nI][7])
   NEXT

   nBaseImp := RoundFiscal(nBaseImp)
   nIvaImp := RoundFiscal(nIvaImp)
   nIrpfImp := RoundFiscal(nBaseImp * nIrpfPct / 100)
   nTotal := RoundFiscal(nBaseImp + nIvaImp - nIrpfImp)

   aFactura[11] := nBaseImp
   aFactura[12] := nIvaImp
   aFactura[13] := nIrpfPct
   aFactura[14] := nIrpfImp
   aFactura[15] := nTotal

   lOk := sqlite3_exec(db, "BEGIN IMMEDIATE") == SQLITE_OK
   IF lOk
      nFacturaId := InsertarFactura(db, aFactura)
      lOk := nFacturaId > 0
   ENDIF
   IF lOk
      FOR nI := 1 TO Len(aLineas)
         aLineas[nI][1] := nFacturaId
         lOk := InsertarLineaFactura(db, aLineas[nI])
         IF !lOk
            EXIT
         ENDIF
      NEXT
   ENDIF
   IF lOk
      cNifEmisor := ObtenerConfiguracion(db, "Empresa.Nif")
      cNombreEmisor := ObtenerConfiguracion(db, "Empresa.Nombre")
      aCliente := ObtenerClientePorId(db, aFactura[4])
      lOk := aCliente != NIL
   ENDIF
   IF lOk
      aPais := ObtenerPaisPorId(db, aCliente[5])
      aTipoId := ObtenerTipoIdentificacionPorId(db, aCliente[6])
      lOk := aPais != NIL .AND. aTipoId != NIL
   ENDIF
   IF lOk
      cNifCliente := aCliente[4]
      cNombreCliente := aCliente[2]
      cCodigoPais := aPais[2]
      lEsNacional := aPais[5]
      cCodigoAEAT := aTipoId[2]
      aLineasSnapshot := ObtenerLineasFactura(db, nFacturaId, {})[1]
      nVersionFiscalId := CrearVersionFiscal(db, nFacturaId, aFactura, aCliente, aPais, aTipoId, aLineasSnapshot, 0, .T.)
      lOk := nVersionFiscalId > 0
   ENDIF
   IF lOk
      cTipoRectificativa := Iif(AeatEsRectificativa(aFactura[9]), aFactura[10], "")
      nFacturaRectificadaId := aFactura[7]
      nRegistroId := CrearRegistroAlta(db, nFacturaId, nVersionFiscalId, cNifEmisor, cNombreEmisor, ;
         aFactura[1], aFactura[2], aFactura[11], aFactura[12], aFactura[15], ;
         aFactura[9], cTipoRectificativa, nFacturaRectificadaId, aFactura[8], aFactura[3], ;
         cNifCliente, cNombreCliente, cCodigoPais, cCodigoAEAT, ;
         aLineasSnapshot, lEsNacional)
      lOk := nRegistroId > 0
   ENDIF
   IF lOk
      lEvento := RegistrarEvento(db, "CreacionFactura", "Factura " + aFactura[1] + " creada")
      lOk := lEvento
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "COMMIT") == SQLITE_OK
   ENDIF
   IF !lOk
      sqlite3_exec(db, "ROLLBACK")
      RETURN 0
   ENDIF
   EnviarRegistroAlta(db, nRegistroId)
RETURN nFacturaId

FUNCTION SubsanarFactura(db, nFacturaId, aFactura, aLineas)
   LOCAL aOriginal := ObtenerFacturaPorId(db, nFacturaId)
   LOCAL aVersion, aCliente, aPais, aTipoId, aTratamiento, nI
   LOCAL nBaseImp := 0, nIvaImp := 0, nIrpfImp, nTotal, nVersionFiscalId := 0, nRegistroId := 0
   LOCAL cNifEmisor, cNombreEmisor, nIrpfPorcentaje, dFechaOperacion, lOk, lEvento

   IF aOriginal == NIL .OR. !ExisteRegistroFactura(db, nFacturaId) .OR. Len(aLineas) == 0
      RETURN 0
   ENDIF
   FOR nI := 1 TO Len(aLineas)
      IF Len(aLineas[nI]) < 18
         RETURN 0
      ENDIF
      aTratamiento := BuscarTratamientoIva(aLineas[nI][16], aLineas[nI][17])
      IF aTratamiento == NIL .OR. (TratamientoIvaExigeIvaCero(aTratamiento) .AND. aLineas[nI][7] != 0)
         RETURN 0
      ENDIF
      aLineas[nI][14] := aTratamiento[3]
      aLineas[nI][15] := aTratamiento[4]
      aLineas[nI][16] := aTratamiento[5]
      aLineas[nI][17] := aTratamiento[6]
      aLineas[nI][18] := aTratamiento[7]
      nBaseImp := nBaseImp + aLineas[nI][8]
      nIvaImp := nIvaImp + CalcularIvaLinea(aLineas[nI][8], aLineas[nI][7])
   NEXT
   nBaseImp := RoundFiscal(nBaseImp)
   nIvaImp := RoundFiscal(nIvaImp)
   nIrpfPorcentaje := Iif(aFactura[13] == NIL, ObtenerIrpfPorcentaje(db), aFactura[13])
   nIrpfImp := RoundFiscal(nBaseImp * nIrpfPorcentaje / 100)
   nTotal := RoundFiscal(nBaseImp + nIvaImp - nIrpfImp)

   aVersion := AClone(aFactura)
   aVersion[1] := aOriginal[2]
   aVersion[2] := aOriginal[3]
   dFechaOperacion := aFactura[3]
   IF dFechaOperacion == NIL .OR. Empty(dFechaOperacion)
      dFechaOperacion := aOriginal[4]
   ENDIF
   IF dFechaOperacion == NIL .OR. Empty(dFechaOperacion)
      dFechaOperacion := aOriginal[3]
   ENDIF
   aVersion[3] := dFechaOperacion
   aVersion[5] := aOriginal[6]
   aVersion[6] := aOriginal[7]
   aVersion[7] := Iif(aFactura[7] == NIL, aOriginal[8], aFactura[7])
   aVersion[11] := nBaseImp
   aVersion[12] := nIvaImp
   aVersion[13] := nIrpfPorcentaje
   aVersion[14] := nIrpfImp
   aVersion[15] := nTotal

   aCliente := ObtenerClientePorId(db, aVersion[4])
   IF aCliente == NIL
      RETURN 0
   ENDIF
   aPais := ObtenerPaisPorId(db, aCliente[5])
   aTipoId := ObtenerTipoIdentificacionPorId(db, aCliente[6])
   IF aPais == NIL .OR. aTipoId == NIL
      RETURN 0
   ENDIF
   cNifEmisor := ObtenerConfiguracion(db, "Empresa.Nif")
   cNombreEmisor := ObtenerConfiguracion(db, "Empresa.Nombre")

   lOk := sqlite3_exec(db, "BEGIN IMMEDIATE") == SQLITE_OK
   IF lOk
      nVersionFiscalId := CrearVersionFiscal(db, nFacturaId, aVersion, aCliente, aPais, aTipoId, aLineas, 2, .F.)
      lOk := nVersionFiscalId > 0
   ENDIF
   IF lOk
      nRegistroId := CrearRegistroSustitutivo(db, nFacturaId, nVersionFiscalId, cNifEmisor, cNombreEmisor, ;
         aVersion[1], aVersion[2], aVersion[11], aVersion[12], aVersion[9], ;
         aOriginal[12], aOriginal[13], aVersion[8], aVersion[3], aCliente[4], aCliente[2], ;
         aPais[2], aTipoId[2], aLineas, aPais[5])
      lOk := nRegistroId > 0
   ENDIF
   IF lOk
      lEvento := RegistrarEvento(db, "Subsanacion", "Factura " + aOriginal[2] + " subsanada")
      lOk := lEvento
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "COMMIT") == SQLITE_OK
   ENDIF
   IF !lOk
      sqlite3_exec(db, "ROLLBACK")
      RETURN 0
   ENDIF
   EnviarRegistroAlta(db, nRegistroId)
RETURN nFacturaId

STATIC FUNCTION ExisteRegistroFactura(db, nFacturaId)
   LOCAL stmt := sqlite3_prepare(db, "SELECT 1 FROM RegistrosFacturacion WHERE FacturaId=? LIMIT 1")
   LOCAL lExiste := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   sqlite3_bind_int(stmt, 1, nFacturaId)
   lExiste := sqlite3_step(stmt) == SQLITE_ROW
   sqlite3_finalize(stmt)
RETURN lExiste

FUNCTION GenerarNumeroFactura(db)
   LOCAL nAnyo := Year(Date())
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT NumeroFactura FROM Facturas WHERE NumeroFactura LIKE ? " + ;
      "ORDER BY NumeroFactura DESC LIMIT 1")
   LOCAL cPrefijo := "F" + Str(nAnyo, 4) + "-"
   LOCAL nNumero := 1, cUltimo, nGuion, nSeq

   sqlite3_bind_text(stmt, 1, cPrefijo + "%")
   IF sqlite3_step(stmt) == SQLITE_ROW
      cUltimo := sqlite3_column_text(stmt, 1)
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
      "Impuesto, ClaveRegimen, CalificacionOperacion, OperacionExenta, DescripcionFiscal, " + ;
      "DescuentoPorcentaje, DescuentoImporte) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
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
   sqlite3_bind_text(stmt, 9, aL[14])
   sqlite3_bind_text(stmt, 10, aL[15])
   IF aL[16] == NIL
      sqlite3_bind_null(stmt, 11)
   ELSE
      sqlite3_bind_text(stmt, 11, aL[16])
   ENDIF
   IF aL[17] == NIL
      sqlite3_bind_null(stmt, 12)
   ELSE
      sqlite3_bind_text(stmt, 12, aL[17])
   ENDIF
   IF aL[18] == NIL
      sqlite3_bind_null(stmt, 13)
   ELSE
      sqlite3_bind_text(stmt, 13, aL[18])
   ENDIF
   IF aL[9] == NIL .OR. aL[9] == 0
      sqlite3_bind_null(stmt, 14)
   ELSE
      sqlite3_bind_text(stmt, 14, Str(aL[9], 6, 2))
   ENDIF
   IF aL[10] == NIL .OR. aL[10] == 0
      sqlite3_bind_null(stmt, 15)
   ELSE
      sqlite3_bind_text(stmt, 15, Str(aL[10], 12, 2))
   ENDIF
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

STATIC FUNCTION CrearVersionFiscal(db, nFacturaId, aFactura, aCliente, aPais, aTipoId, aLineas, nTipoRegistro, lGuardarDesgloseFactura)
   LOCAL cClienteSnapshot, cLineasSnapshot, cDesglose
   LOCAL dtCreacion := hb_DateTime(), cHash, stmt, nRes, nId, lOk

   cClienteSnapshot := CrearClienteSnapshotJson(aCliente, aPais, aTipoId)
   cLineasSnapshot := CrearLineasSnapshotJson(aLineas)
   cDesglose := GenerarDesgloseJson(aLineas)
   cHash := CalcularHashContenidoVersionFiscal(nFacturaId, aFactura, cClienteSnapshot, cLineasSnapshot, cDesglose, dtCreacion, nTipoRegistro)
   stmt := sqlite3_prepare(db, ;
      "INSERT INTO FacturasVersionesFiscales(" + ;
      "FacturaId, RegistroFacturacionId, TipoRegistro, NumeroFactura, FechaEmision, FechaOperacion, ClienteId, " + ;
      "ClienteSnapshotJson, LineasSnapshotJson, Descripcion, AeatTipoFactura, TipoRectificacion, FacturaRectificadaId, " + ;
      "BaseImponible, IvaImporte, IrpfPorcentaje, IrpfImporte, Total, TotalFiscal, DesgloseJson, FechaCreacion, HashContenido) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   IF Empty(stmt)
      RETURN 0
   ENDIF
   sqlite3_bind_int(stmt, 1, nFacturaId)
   sqlite3_bind_null(stmt, 2)
   sqlite3_bind_int(stmt, 3, nTipoRegistro)
   sqlite3_bind_text(stmt, 4, aFactura[1])
   sqlite3_bind_text(stmt, 5, FechaISO8601(aFactura[2]))
   IF aFactura[3] == NIL
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_text(stmt, 6, FechaISO8601(aFactura[3]))
   ENDIF
   sqlite3_bind_int(stmt, 7, aFactura[4])
   sqlite3_bind_text(stmt, 8, cClienteSnapshot)
   sqlite3_bind_text(stmt, 9, cLineasSnapshot)
   VincularTextoONulo(stmt, 10, aFactura[8])
   sqlite3_bind_text(stmt, 11, aFactura[9])
   VincularTextoONulo(stmt, 12, aFactura[10])
   IF aFactura[7] == NIL .OR. aFactura[7] == 0
      sqlite3_bind_null(stmt, 13)
   ELSE
      sqlite3_bind_int(stmt, 13, aFactura[7])
   ENDIF
   sqlite3_bind_text(stmt, 14, DecimalAPuntoSinEspacios(aFactura[11]))
   sqlite3_bind_text(stmt, 15, DecimalAPuntoSinEspacios(aFactura[12]))
   sqlite3_bind_text(stmt, 16, DecimalAPuntoSinEspacios(aFactura[13]))
   sqlite3_bind_text(stmt, 17, DecimalAPuntoSinEspacios(aFactura[14]))
   sqlite3_bind_text(stmt, 18, DecimalAPuntoSinEspacios(aFactura[15]))
   sqlite3_bind_text(stmt, 19, DecimalAPuntoSinEspacios(aFactura[11] + aFactura[12]))
   sqlite3_bind_text(stmt, 20, cDesglose)
   sqlite3_bind_text(stmt, 21, FechaSnapshot(dtCreacion))
   sqlite3_bind_text(stmt, 22, cHash)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   IF nRes != SQLITE_DONE
      RETURN 0
   ENDIF
   nId := sqlite3_last_insert_rowid(db)
   lOk := InsertarDesglosesIva(db, "FacturasVersionesFiscalesDesglosesIva", "FacturaVersionFiscalId", nId, cDesglose)
   IF lOk .AND. lGuardarDesgloseFactura
      lOk := InsertarDesglosesIva(db, "FacturasDesglosesIva", "FacturaId", nFacturaId, cDesglose)
   ENDIF
   IF !lOk
      RETURN 0
   ENDIF
RETURN nId

STATIC FUNCTION InsertarDesglosesIva(db, cTabla, cColumnaDocumento, nDocumentoId, cDesglose)
   LOCAL hDesglose := {=>}, aDetalle, nI

   IF hb_jsonDecode(cDesglose, @hDesglose) == 0 .OR. !hb_HHasKey(hDesglose, "DetalleDesglose")
      RETURN .F.
   ENDIF
   aDetalle := hDesglose["DetalleDesglose"]
   FOR nI := 1 TO Len(aDetalle)
      IF !InsertarDesgloseIva(db, cTabla, cColumnaDocumento, nDocumentoId, nI, aDetalle[nI])
         RETURN .F.
      ENDIF
   NEXT
RETURN .T.

STATIC FUNCTION InsertarDesgloseIva(db, cTabla, cColumnaDocumento, nDocumentoId, nOrden, hDetalle)
   LOCAL stmt := sqlite3_prepare(db, ;
      "INSERT INTO " + cTabla + "(" + cColumnaDocumento + ", Orden, TipoIvaId, TipoIvaNombre, " + ;
      "Impuesto, ClaveRegimen, CalificacionOperacion, OperacionExenta, DescripcionFiscal, " + ;
      "TipoImpositivo, BaseImponible, CuotaRepercutida, TotalFiscal) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   LOCAL nBase, nCuota

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   nBase := hDetalle["BaseImponibleOimporteNoSujeto"]
   nCuota := hDetalle["CuotaRepercutida"]
   sqlite3_bind_int(stmt, 1, nDocumentoId)
   sqlite3_bind_int(stmt, 2, nOrden)
   IF hDetalle["TipoIvaId"] == NIL
      sqlite3_bind_null(stmt, 3)
   ELSE
      sqlite3_bind_int(stmt, 3, hDetalle["TipoIvaId"])
   ENDIF
   VincularTextoONulo(stmt, 4, hDetalle["TipoIvaNombre"])
   sqlite3_bind_text(stmt, 5, hDetalle["Impuesto"])
   sqlite3_bind_text(stmt, 6, hDetalle["ClaveRegimen"])
   VincularTextoONulo(stmt, 7, hDetalle["CalificacionOperacion"])
   VincularTextoONulo(stmt, 8, hDetalle["OperacionExenta"])
   sqlite3_bind_null(stmt, 9)
   sqlite3_bind_text(stmt, 10, DecimalAPuntoSinEspacios(hDetalle["TipoImpositivo"]))
   sqlite3_bind_text(stmt, 11, DecimalAPuntoSinEspacios(nBase))
   sqlite3_bind_text(stmt, 12, DecimalAPuntoSinEspacios(nCuota))
   sqlite3_bind_text(stmt, 13, DecimalAPuntoSinEspacios(nBase + nCuota))
   nOrden := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN nOrden == SQLITE_DONE

STATIC FUNCTION CrearClienteSnapshotJson(aCliente, aPais, aTipoId)
   LOCAL hCliente := {=>}, hPais := {=>}, hTipo := {=>}

   hPais["Id"] := aPais[1]
   hPais["Codigo"] := aPais[2]
   hPais["Nombre"] := aPais[3]
   hPais["Nacionalidad"] := aPais[4]
   hPais["EsUE"] := aPais[5]
   hTipo["Id"] := aTipoId[1]
   hTipo["CodigoAEAT"] := aTipoId[2]
   hTipo["Nombre"] := aTipoId[3]
   hCliente["Id"] := aCliente[1]
   hCliente["Nombre"] := aCliente[2]
   hCliente["TipoCliente"] := TipoClienteSnapshot(aCliente[3])
   hCliente["Nif"] := aCliente[4]
   hCliente["NifIva"] := aCliente[7]
   hCliente["Direccion"] := aCliente[8]
   hCliente["Poblacion"] := aCliente[9]
   hCliente["Provincia"] := aCliente[10]
   hCliente["CodigoPostal"] := aCliente[11]
   hCliente["Telefono"] := aCliente[12]
   hCliente["Email"] := aCliente[13]
   hCliente["Pais"] := hPais
   hCliente["TipoIdentificacion"] := hTipo
RETURN hb_jsonEncode(hCliente, .F.)

STATIC FUNCTION CrearLineasSnapshotJson(aLineas)
   LOCAL aSnapshot := {}, nI, hLinea

   FOR nI := 1 TO Len(aLineas)
      hLinea := {=>}
      hLinea["Id"] := aLineas[nI][1]
      hLinea["ArticuloId"] := Iif(aLineas[nI][2] == 0, NIL, aLineas[nI][2])
      hLinea["ArticuloCodigo"] := aLineas[nI][11]
      hLinea["ArticuloDescripcion"] := aLineas[nI][12]
      hLinea["TipoIvaId"] := Iif(aLineas[nI][3] == 0, NIL, aLineas[nI][3])
      hLinea["TipoIvaNombre"] := aLineas[nI][13]
      hLinea["Impuesto"] := CodigoSnapshot(aLineas[nI][14], "01")
      hLinea["ClaveRegimen"] := CodigoSnapshot(aLineas[nI][15], "01")
      hLinea["CalificacionOperacion"] := CodigoSnapshot(aLineas[nI][16], NIL)
      hLinea["OperacionExenta"] := CodigoSnapshot(aLineas[nI][17], NIL)
      hLinea["DescripcionFiscal"] := aLineas[nI][18]
      hLinea["Descripcion"] := aLineas[nI][4]
      hLinea["Cantidad"] := DecimalSnapshot(aLineas[nI][5])
      hLinea["PrecioUnitario"] := DecimalSnapshot(aLineas[nI][6])
      hLinea["IvaPorcentaje"] := DecimalSnapshot(aLineas[nI][7])
      hLinea["Importe"] := DecimalSnapshot(aLineas[nI][8])
      IF aLineas[nI][9] == NIL .OR. aLineas[nI][9] == 0
         hLinea["DescuentoPorcentaje"] := NIL
      ELSE
         hLinea["DescuentoPorcentaje"] := DecimalSnapshot(aLineas[nI][9])
      ENDIF
      IF aLineas[nI][10] == NIL .OR. aLineas[nI][10] == 0
         hLinea["DescuentoImporte"] := NIL
      ELSE
         hLinea["DescuentoImporte"] := DecimalSnapshot(aLineas[nI][10])
      ENDIF
      AAdd(aSnapshot, hLinea)
   NEXT
RETURN hb_jsonEncode(aSnapshot, .F.)

STATIC FUNCTION CalcularHashContenidoVersionFiscal(nFacturaId, aFactura, cClienteSnapshot, cLineasSnapshot, cDesglose, dtCreacion, nTipoRegistro)
   LOCAL hContenido := {=>}

   hContenido["FacturaId"] := nFacturaId
   hContenido["RegistroFacturacionId"] := NIL
   hContenido["TipoRegistro"] := TipoRegistroSnapshot(nTipoRegistro)
   hContenido["NumeroFactura"] := aFactura[1]
   hContenido["FechaEmision"] := FechaSnapshot(aFactura[2])
   hContenido["FechaOperacion"] := Iif(aFactura[3] == NIL, NIL, FechaSnapshot(aFactura[3]))
   hContenido["ClienteId"] := aFactura[4]
   hContenido["ClienteSnapshotJson"] := cClienteSnapshot
   hContenido["LineasSnapshotJson"] := cLineasSnapshot
   hContenido["Descripcion"] := aFactura[8]
   hContenido["AeatTipoFactura"] := aFactura[9]
   hContenido["TipoRectificacion"] := aFactura[10]
   hContenido["FacturaRectificadaId"] := Iif(aFactura[7] == 0, NIL, aFactura[7])
   hContenido["BaseImponible"] := DecimalSnapshot(aFactura[11])
   hContenido["IvaImporte"] := DecimalSnapshot(aFactura[12])
   hContenido["IrpfPorcentaje"] := DecimalSnapshot(aFactura[13])
   hContenido["IrpfImporte"] := DecimalSnapshot(aFactura[14])
   hContenido["Total"] := DecimalSnapshot(aFactura[15])
   hContenido["TotalFiscal"] := DecimalSnapshot(aFactura[11] + aFactura[12])
   hContenido["DesgloseJson"] := cDesglose
   hContenido["FechaCreacion"] := FechaSnapshot(dtCreacion)
RETURN Upper(hb_SHA256(hb_jsonEncode(hContenido, .F.), 1))

STATIC FUNCTION TipoRegistroSnapshot(nTipoRegistro)
   IF nTipoRegistro == 1
      RETURN "Anulacion"
   ENDIF
   IF nTipoRegistro == 2
      RETURN "Sustitutivo"
   ENDIF
RETURN "Alta"

STATIC FUNCTION TipoClienteSnapshot(nTipoCliente)
   DO CASE
   CASE nTipoCliente == 1
      RETURN "Intracomunitario"
   CASE nTipoCliente == 2
      RETURN "Extracomunitario"
   ENDCASE
RETURN "Nacional"

STATIC FUNCTION CodigoSnapshot(cCodigo, cDefecto)
   IF cCodigo == NIL .OR. Empty(AllTrim(cCodigo))
      RETURN cDefecto
   ENDIF
RETURN Upper(AllTrim(cCodigo))

STATIC FUNCTION DecimalSnapshot(nValor)
RETURN StripTrailingZeros(DecimalAPuntoSinEspacios(nValor))

STATIC FUNCTION FechaSnapshot(xFecha)
   LOCAL cFecha

   IF ValType(xFecha) == "D"
      RETURN FechaISO8601(xFecha) + "T00:00:00.0000000Z"
   ENDIF
   cFecha := FechaISO8601ConTimeZone(xFecha)
RETURN Left(cFecha, Len(cFecha) - 1) + ".0000000Z"

STATIC FUNCTION VincularTextoONulo(stmt, nIndice, cValor)
   IF cValor == NIL
      sqlite3_bind_null(stmt, nIndice)
   ELSE
      sqlite3_bind_text(stmt, nIndice, cValor)
   ENDIF
RETURN NIL

FUNCTION AnularFactura(db, nFacturaOriginalId, cMotivo)
   LOCAL aOriginal := ObtenerFacturaPorId(db, nFacturaOriginalId)
   LOCAL aAnulacion := Array(17), aLineasAnulacion, aCliente, aPais, aTipoId, nI
   LOCAL nFacturaAnulacionId := 0, nVersionFiscalId := 0, nRegistroId := 0
   LOCAL nBaseImponible := 0, nIvaImporte := 0, nTotal, cNumeroAnulacion
   LOCAL cNifEmisor, cNombreEmisor, lOk

   IF aOriginal == NIL .OR. EstaAnuladaOperativamente(db, nFacturaOriginalId) .OR. Len(aOriginal[32]) == 0
      RETURN 0
   ENDIF
   cNumeroAnulacion := GenerarNumeroFactura(db)
   aLineasAnulacion := CrearLineasAnulacion(aOriginal[32])
   FOR nI := 1 TO Len(aLineasAnulacion)
      nBaseImponible := nBaseImponible + aLineasAnulacion[nI][8]
      nIvaImporte := nIvaImporte + CalcularIvaLinea(aLineasAnulacion[nI][8], aLineasAnulacion[nI][7])
   NEXT
   nBaseImponible := RoundFiscal(nBaseImponible)
   nIvaImporte := RoundFiscal(nIvaImporte)
   nTotal := RoundFiscal(nBaseImponible + nIvaImporte)

   aAnulacion[1] := cNumeroAnulacion
   aAnulacion[2] := Date()
   aAnulacion[3] := Date()
   aAnulacion[4] := aOriginal[5]
   aAnulacion[5] := 2
   aAnulacion[6] := 0
   aAnulacion[7] := nFacturaOriginalId
   aAnulacion[8] := "Anulación de " + aOriginal[2] + ": " + cMotivo
   aAnulacion[9] := "R5"
   aAnulacion[10] := ""
   aAnulacion[11] := nBaseImponible
   aAnulacion[12] := nIvaImporte
   aAnulacion[13] := 0
   aAnulacion[14] := 0
   aAnulacion[15] := nTotal
   aAnulacion[16] := NIL
   aAnulacion[17] := NIL

   aCliente := ObtenerClientePorId(db, aAnulacion[4])
   IF aCliente == NIL
      RETURN 0
   ENDIF
   aPais := ObtenerPaisPorId(db, aCliente[5])
   aTipoId := ObtenerTipoIdentificacionPorId(db, aCliente[6])
   IF aPais == NIL .OR. aTipoId == NIL
      RETURN 0
   ENDIF
   cNifEmisor := ObtenerConfiguracion(db, "Empresa.Nif")
   cNombreEmisor := ObtenerConfiguracion(db, "Empresa.Nombre")

   lOk := sqlite3_exec(db, "BEGIN IMMEDIATE") == SQLITE_OK
   IF lOk
      nFacturaAnulacionId := InsertarFactura(db, aAnulacion)
      lOk := nFacturaAnulacionId > 0
   ENDIF
   IF lOk
      FOR nI := 1 TO Len(aLineasAnulacion)
         aLineasAnulacion[nI][1] := nFacturaAnulacionId
         lOk := InsertarLineaFactura(db, aLineasAnulacion[nI])
         IF !lOk
            EXIT
         ENDIF
      NEXT
   ENDIF
   IF lOk
      nVersionFiscalId := CrearVersionFiscal(db, nFacturaAnulacionId, aAnulacion, aCliente, aPais, aTipoId, aLineasAnulacion, 1, .T.)
      lOk := nVersionFiscalId > 0
   ENDIF
   IF lOk
      nRegistroId := CrearRegistroAnulacion(db, nFacturaAnulacionId, nVersionFiscalId, cNifEmisor, ;
         aAnulacion[1], aAnulacion[2], aAnulacion[11], aAnulacion[12], ;
         aOriginal[2], aOriginal[3], aOriginal[12], aOriginal[13])
      lOk := nRegistroId > 0
   ENDIF
   IF lOk
      lOk := sqlite3_exec(db, "COMMIT") == SQLITE_OK
   ENDIF
   IF !lOk
      sqlite3_exec(db, "ROLLBACK")
      RETURN 0
   ENDIF
   EnviarRegistroAnulacion(db, nRegistroId)
   RegistrarEvento(db, "AnulacionFactura", "Factura " + aOriginal[2] + " anulada")
RETURN nFacturaAnulacionId

STATIC FUNCTION EstaAnuladaOperativamente(db, nFacturaId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT 1 FROM Facturas f WHERE f.Id=? AND (f.Estado=1 OR EXISTS(" + ;
      "SELECT 1 FROM Facturas fa JOIN RegistrosFacturacion ra ON ra.FacturaId=fa.Id " + ;
      "WHERE fa.FacturaRectificadaId=f.Id AND fa.TipoFactura=2 AND ra.TipoRegistro=1))")
   LOCAL lAnulada := .F.

   IF Empty(stmt)
      RETURN .F.
   ENDIF
   sqlite3_bind_int(stmt, 1, nFacturaId)
   lAnulada := sqlite3_step(stmt) == SQLITE_ROW
   sqlite3_finalize(stmt)
RETURN lAnulada

STATIC FUNCTION CrearLineasAnulacion(aLineasOriginales)
   LOCAL aResultado := {}, aLinea, nI

   FOR nI := 1 TO Len(aLineasOriginales)
      aLinea := AClone(aLineasOriginales[nI])
      aLinea[1] := 0
      aLinea[4] := "Anulación " + aLinea[4]
      aLinea[6] := -aLinea[6]
      aLinea[8] := -aLinea[8]
      IF aLinea[10] != NIL .AND. aLinea[10] != 0
         aLinea[10] := -aLinea[10]
      ENDIF
      AAdd(aResultado, aLinea)
   NEXT
RETURN aResultado

STATIC FUNCTION ObtenerLineasFactura(db, nFacturaId, aFactura)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT l.Id, l.ArticuloId, l.TipoIvaId, l.Descripcion, " + ;
      "CAST(l.Cantidad AS REAL), CAST(l.PrecioUnitario AS REAL), " + ;
      "CAST(l.IvaPorcentaje AS REAL), CAST(l.Importe AS REAL), " + ;
      "CAST(l.DescuentoPorcentaje AS REAL), CAST(l.DescuentoImporte AS REAL), " + ;
      "a.Codigo, a.Descripcion, t.Nombre, " + ;
      "l.Impuesto, l.ClaveRegimen, l.CalificacionOperacion, l.OperacionExenta, l.DescripcionFiscal " + ;
      "FROM LineasFactura l " + ;
      "LEFT JOIN Articulos a ON l.ArticuloId = a.Id " + ;
      "LEFT JOIN TiposIva t ON l.TipoIvaId = t.Id " + ;
      "WHERE l.FacturaId = ? ORDER BY l.Id")
   LOCAL aLineas := {}
   sqlite3_bind_int(stmt, 1, nFacturaId)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aLineas, { ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_int(stmt, 2), ;
         sqlite3_column_int(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         Val(sqlite3_column_text(stmt, 5)), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         Val(sqlite3_column_text(stmt, 7)), ;
         Val(sqlite3_column_text(stmt, 8)), ;
         Val(sqlite3_column_text(stmt, 9)), ;
         Val(sqlite3_column_text(stmt, 10)), ;
         sqlite3_column_text(stmt, 11), ;
         sqlite3_column_text(stmt, 12), ;
         sqlite3_column_text(stmt, 13), ;
         sqlite3_column_text(stmt, 14), ;
         sqlite3_column_text(stmt, 15), ;
         sqlite3_column_text(stmt, 16), ;
         sqlite3_column_text(stmt, 17), ;
         sqlite3_column_text(stmt, 18) })
   ENDDO
   sqlite3_finalize(stmt)
   AAdd(aFactura, aLineas)
   RETURN aFactura
