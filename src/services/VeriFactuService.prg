#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION CalcularHashVeriFactu(cNifEmisor, cNumFactura, dFechaExpedicion, cTipoFactura, nCuotaTotal, nImporteTotal, cHashAnterior, dFechaHoraHuso)
   LOCAL cData, cAnterior, cFechaStr, cFechaHusoStr, cImporte, cCuota

   cAnterior := Iif(cHashAnterior == NIL, "", cHashAnterior)
   cFechaStr := FechaDDMMYYYY(dFechaExpedicion)
   cFechaHusoStr := FechaISO8601ConTimeZone(dFechaHoraHuso)
   cCuota := DecimalAPunto(nCuotaTotal)
   cImporte := DecimalAPunto(nImporteTotal)

   cData := "IDEmisorFactura=" + cNifEmisor + ;
      "&NumSerieFactura=" + cNumFactura + ;
      "&FechaExpedicionFactura=" + cFechaStr + ;
      "&TipoFactura=" + cTipoFactura + ;
      "&CuotaTotal=" + cCuota + ;
      "&ImporteTotal=" + cImporte + ;
      "&Huella=" + cAnterior + ;
      "&FechaHoraHusoGenRegistro=" + cFechaHusoStr

   RETURN Upper(hb_SHA256(cData, 1))

FUNCTION CrearRegistroAlta(db, nFacturaId, cNifEmisor, cNombreEmisor, cNumFactura, dFechaEmision, ;
      nBaseImponible, nIvaImporte, nTotal, cTipoFactura, cTipoRectificativa, ;
      nFacturaRectificadaId, cDescripcion, dFechaOperacion, ;
      cNifCliente, cNombreCliente, cCodigoPais, cCodigoAEAT, ;
      aLineas, lEsNacional)

   LOCAL cHashAnterior, nIdRegistroAnterior, dNtpTime
   LOCAL cHash, cEncadenamiento, cDestinatarios, cDesglose, cSistemaInfo
   LOCAL cFacturasRectificadas := NIL, stmt, nRes

   dNtpTime := hb_DateTime()

   cHashAnterior := ObtenerUltimoHashRegistro(db)
   nIdRegistroAnterior := ObtenerUltimoIdRegistro(db)

   cHash := CalcularHashVeriFactu(cNifEmisor, cNumFactura, dFechaEmision, ;
      cTipoFactura, nIvaImporte, nBaseImponible + nIvaImporte, ;
      cHashAnterior, dNtpTime)

   cEncadenamiento := GenerarEncadenamiento(cHashAnterior, cNifEmisor, cNumFactura, dFechaEmision)
   cDestinatarios := GenerarDestinatariosJson(cNifCliente, cNombreCliente, cCodigoPais, cCodigoAEAT, lEsNacional)
   cDesglose := GenerarDesgloseJson(aLineas)
   cSistemaInfo := GenerarSistemaInformaticoJson(db)

   IF AeatEsRectificativa(cTipoFactura) .AND. nFacturaRectificadaId != NIL .AND. nFacturaRectificadaId > 0
      cFacturasRectificadas := GenerarFacturasRectificadasJson(db, nFacturaRectificadaId)
   ENDIF

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO RegistrosFacturacion(" + ;
      "FacturaId, TipoRegistro, Hash, HashAnterior, IdRegistroAnterior, " + ;
      "NifEmisor, NumeroFactura, FechaEmision, " + ;
      "BaseImponible, IvaImporte, Total, " + ;
      "NombreRazonEmisor, IDVersion, TipoFactura, TipoRectificativa, " + ;
      "FacturasRectificadas, FechaOperacion, DescripcionOperacion, " + ;
      "FechaHoraHusoGenRegistro, TipoHuella, FechaRegistro, " + ;
      "Destinatarios, Desglose, SistemaInformatico, Encadenamiento, " + ;
      "EnviadoAEAT) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)")

   sqlite3_bind_int(stmt, 1, nFacturaId)
   sqlite3_bind_int(stmt, 2, 0)
   sqlite3_bind_text(stmt, 3, cHash)
   IF Empty(cHashAnterior)
      sqlite3_bind_null(stmt, 4)
   ELSE
      sqlite3_bind_text(stmt, 4, cHashAnterior)
   ENDIF
   IF nIdRegistroAnterior == 0
      sqlite3_bind_null(stmt, 5)
   ELSE
      sqlite3_bind_int(stmt, 5, nIdRegistroAnterior)
   ENDIF
   sqlite3_bind_text(stmt, 6, cNifEmisor)
   sqlite3_bind_text(stmt, 7, cNumFactura)
   sqlite3_bind_text(stmt, 8, FechaISO8601(dFechaEmision))
   sqlite3_bind_text(stmt, 9, Str(nBaseImponible, 12, 2))
   sqlite3_bind_text(stmt, 10, Str(nIvaImporte, 12, 2))
   sqlite3_bind_text(stmt, 11, Str(nBaseImponible + nIvaImporte, 12, 2))
   sqlite3_bind_text(stmt, 12, cNombreEmisor)
   sqlite3_bind_text(stmt, 13, "1.0")
   sqlite3_bind_text(stmt, 14, cTipoFactura)
   sqlite3_bind_text(stmt, 15, cTipoRectificativa)
   IF cFacturasRectificadas == NIL
      sqlite3_bind_null(stmt, 16)
   ELSE
      sqlite3_bind_text(stmt, 16, cFacturasRectificadas)
   ENDIF
   IF dFechaOperacion == NIL
      sqlite3_bind_text(stmt, 17, FechaISO8601(dFechaEmision))
   ELSE
      sqlite3_bind_text(stmt, 17, FechaISO8601(dFechaOperacion))
   ENDIF
   IF cDescripcion == NIL .OR. Empty(cDescripcion)
      sqlite3_bind_text(stmt, 18, "Operacion")
   ELSE
      sqlite3_bind_text(stmt, 18, cDescripcion)
   ENDIF
   sqlite3_bind_text(stmt, 19, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 20, "01")
   sqlite3_bind_text(stmt, 21, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 22, cDestinatarios)
   sqlite3_bind_text(stmt, 23, cDesglose)
   sqlite3_bind_text(stmt, 24, cSistemaInfo)
   sqlite3_bind_text(stmt, 25, cEncadenamiento)

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION CrearRegistroAnulacion(db, nFacturaId, nFacturaOriginalId, cNumFacturaAnulacion, ;
      dFechaAnulacion, cNifEmisor, nBaseAnulacion, nIvaAnulacion, ;
      cNumFacturaOriginal, dFechaOriginal)

   LOCAL cHashAnterior, nIdRegistroAnterior, dNtpTime, cHash
   LOCAL cEncadenamiento, cSistemaInfo, stmt, nRes

   dNtpTime := hb_DateTime()
   cHashAnterior := ObtenerUltimoHashRegistro(db)
   nIdRegistroAnterior := ObtenerUltimoIdRegistro(db)
   cHash := CalcularHashVeriFactu(cNifEmisor, cNumFacturaAnulacion, dFechaAnulacion, ;
      "R5", nIvaAnulacion, nBaseAnulacion + nIvaAnulacion, ;
      cHashAnterior, dNtpTime)
   cEncadenamiento := GenerarEncadenamiento(cHashAnterior, cNifEmisor, cNumFacturaAnulacion, dFechaAnulacion)
   cSistemaInfo := GenerarSistemaInformaticoJson(db)

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO RegistrosFacturacion(" + ;
      "FacturaId, TipoRegistro, Hash, HashAnterior, IdRegistroAnterior, " + ;
      "NifEmisor, NumeroFactura, FechaEmision, " + ;
      "BaseImponible, IvaImporte, Total, " + ;
      "IdFacturaAnulada, FechaFacturaAnulada, " + ;
      "FechaRegistro, TipoFactura, IDVersion, " + ;
      "FechaHoraHusoGenRegistro, TipoHuella, " + ;
      "SinRegistroPrevio, RechazoPrevioAnulacion, GeneradoPor, " + ;
      "SistemaInformatico, Encadenamiento, EnviadoAEAT) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)")

   sqlite3_bind_int(stmt, 1, nFacturaId)
   sqlite3_bind_int(stmt, 2, 1)
   sqlite3_bind_text(stmt, 3, cHash)
   IF Empty(cHashAnterior)
      sqlite3_bind_null(stmt, 4)
   ELSE
      sqlite3_bind_text(stmt, 4, cHashAnterior)
   ENDIF
   IF nIdRegistroAnterior == 0
      sqlite3_bind_null(stmt, 5)
   ELSE
      sqlite3_bind_int(stmt, 5, nIdRegistroAnterior)
   ENDIF
   sqlite3_bind_text(stmt, 6, cNifEmisor)
   sqlite3_bind_text(stmt, 7, cNumFacturaAnulacion)
   sqlite3_bind_text(stmt, 8, FechaISO8601(dFechaAnulacion))
   sqlite3_bind_text(stmt, 9, Str(nBaseAnulacion, 12, 2))
   sqlite3_bind_text(stmt, 10, Str(nIvaAnulacion, 12, 2))
   sqlite3_bind_text(stmt, 11, Str(nBaseAnulacion + nIvaAnulacion, 12, 2))
   sqlite3_bind_text(stmt, 12, cNumFacturaOriginal)
   sqlite3_bind_text(stmt, 13, FechaISO8601(dFechaOriginal))
   sqlite3_bind_text(stmt, 14, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 15, "R5")
   sqlite3_bind_text(stmt, 16, "1.0")
   sqlite3_bind_text(stmt, 17, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 18, "01")
   sqlite3_bind_text(stmt, 19, "N")
   sqlite3_bind_text(stmt, 20, "N")
   sqlite3_bind_text(stmt, 21, "E")
   sqlite3_bind_text(stmt, 22, cSistemaInfo)
   sqlite3_bind_text(stmt, 23, cEncadenamiento)

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION VerificarCadenaRegistros(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Hash, HashAnterior, NifEmisor, NumeroFactura, " + ;
      "FechaEmision, IvaImporte, BaseImponible, TipoFactura, FechaHoraHusoGenRegistro " + ;
      "FROM RegistrosFacturacion ORDER BY Id")
   LOCAL nI := 0, cHashAnterior, cHashEsperado

   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nI++
      IF nI > 1
         cHashAnterior := sqlite3_column_text(stmt, 2)
         IF cHashAnterior != ObtenerHashPorOrden(db, nI - 1)
            sqlite3_finalize(stmt)
            RETURN .F.
         ENDIF
      ENDIF
      cHashEsperado := CalcularHashVeriFactu(;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         SqlDateToDate(sqlite3_column_text(stmt, 5)), ;
         sqlite3_column_text(stmt, 8), ;
         Val(sqlite3_column_text(stmt, 6)), ;
         Val(sqlite3_column_text(stmt, 6)) + Val(sqlite3_column_text(stmt, 7)), ;
         Iif(nI > 1, ObtenerHashPorOrden(db, nI - 1), ""), ;
         SqlDateToDate(sqlite3_column_text(stmt, 9)))
      IF sqlite3_column_text(stmt, 1) != cHashEsperado
         sqlite3_finalize(stmt)
         RETURN .F.
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)
   RETURN .T.

FUNCTION GenerarDesgloseJson(aLineas)
   LOCAL nI, nTipoIvaId, nTipoIvaActual, nBaseGrupo, nCuota, nIvaPct
   LOCAL aGrupos := {}, cJson, cLineas := ""

   nTipoIvaActual := 0
   nBaseGrupo := 0
   nCuota := 0
   nIvaPct := 0

   FOR nI := 1 TO Len(aLineas)
      nTipoIvaId := aLineas[nI][7]
      IF nTipoIvaId != nTipoIvaActual .AND. nTipoIvaActual != 0
         cLineas += '{"Impuesto":"01","ClaveRegimen":"01","CalificacionOperacion":"S1",' + ;
            '"TipoImpositivo":' + DecimalAPunto(nIvaPct) + ',' + ;
            '"BaseImponibleOimporteNoSujeto":' + DecimalAPunto(nBaseGrupo) + ',' + ;
            '"CuotaRepercutida":' + DecimalAPunto(nCuota) + '},'
         nBaseGrupo := 0
         nCuota := 0
      ENDIF
      nTipoIvaActual := nTipoIvaId
      nIvaPct := Val(aLineas[nI][6])
      nBaseGrupo := nBaseGrupo + Val(aLineas[nI][5])
      nCuota := nCuota + Val(aLineas[nI][5]) * nIvaPct / 100
   NEXT

   IF nBaseGrupo != 0
      cLineas += '{"Impuesto":"01","ClaveRegimen":"01","CalificacionOperacion":"S1",' + ;
         '"TipoImpositivo":' + DecimalAPunto(nIvaPct) + ',' + ;
         '"BaseImponibleOimporteNoSujeto":' + DecimalAPunto(nBaseGrupo) + ',' + ;
         '"CuotaRepercutida":' + DecimalAPunto(nCuota) + '}'
   ENDIF

   RETURN '{"DetalleDesglose":[' + cLineas + ']}'

STATIC FUNCTION ObtenerUltimoHashRegistro(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Hash FROM RegistrosFacturacion ORDER BY Id DESC LIMIT 1")
   LOCAL cHash := ""
   IF sqlite3_step(stmt) == SQLITE_ROW
      cHash := sqlite3_column_text(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cHash

STATIC FUNCTION ObtenerUltimoIdRegistro(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id FROM RegistrosFacturacion ORDER BY Id DESC LIMIT 1")
   LOCAL nId := 0
   IF sqlite3_step(stmt) == SQLITE_ROW
      nId := sqlite3_column_int(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN nId

STATIC FUNCTION ObtenerHashPorOrden(db, nOrden)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Hash FROM RegistrosFacturacion ORDER BY Id LIMIT 1 OFFSET ?")
   LOCAL cHash
   sqlite3_bind_int(stmt, 1, nOrden - 1)
   IF sqlite3_step(stmt) == SQLITE_ROW
      cHash := sqlite3_column_text(stmt, 0)
   ELSE
      cHash := ""
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cHash

STATIC FUNCTION GenerarEncadenamiento(cHashAnterior, cNif, cNumFactura, dFecha)
   IF Empty(cHashAnterior)
      RETURN '{"PrimerRegistro":"S"}'
   ENDIF
   RETURN '{"RegistroAnterior":{"IDEmisorFactura":"' + cNif + '",' + ;
      '"NumSerieFactura":"' + cNumFactura + '",' + ;
      '"FechaExpedicionFactura":"' + FechaDDMMYYYY(dFecha) + '",' + ;
      '"Huella":"' + cHashAnterior + '"}}'

STATIC FUNCTION GenerarDestinatariosJson(cNif, cNombre, cCodigoPais, cCodigoAEAT, lEsNacional)
   RETURN '[{"NombreRazon":"' + cNombre + '",' + ;
      '"NIF":"' + cNif + '",' + ;
      '"EsNacional":' + Iif(lEsNacional, "true", "false") + ',' + ;
      '"CodigoPais":"' + cCodigoPais + '",' + ;
      '"CodigoAEAT":"' + cCodigoAEAT + '"}]'

STATIC FUNCTION GenerarSistemaInformaticoJson(db)
   LOCAL cNombreRazon := ObtenerConfiguracion(db, "Empresa.Nombre")
   LOCAL cNif := ObtenerConfiguracion(db, "Empresa.Nif")
   LOCAL cIdSI := ObtenerConfiguracion(db, "VeriFactu.IdEmisor")
   LOCAL cVersion := ObtenerConfiguracion(db, "VeriFactu.VersionSoftware")
   LOCAL cNombreSI := ObtenerConfiguracion(db, "VeriFactu.NombreSoftware")

   IF Empty(cIdSI); cIdSI := "FV"; ENDIF
   IF Empty(cVersion); cVersion := "1.0.0"; ENDIF
   IF Empty(cNombreSI); cNombreSI := "Facturas"; ENDIF

   RETURN '{"NombreRazon":"' + cNombreRazon + '",' + ;
      '"NIF":"' + cNif + '",' + ;
      '"NombreSistemaInformatico":"' + cNombreSI + '",' + ;
      '"IdSistemaInformatico":"' + cIdSI + '",' + ;
      '"Version":"' + cVersion + '",' + ;
      '"NumeroInstalacion":"1",' + ;
      '"TipoUsoPosibleSoloVerifactu":"S",' + ;
      '"TipoUsoPosibleMultiOT":"N",' + ;
      '"IndicadorMultiplesOT":"N"}'

STATIC FUNCTION GenerarFacturasRectificadasJson(db, nFacturaRectificadaId)
   LOCAL aFR := ObtenerFacturaRectificadaData(db, nFacturaRectificadaId)
   IF aFR == NIL
      RETURN NIL
   ENDIF
   RETURN '[{"IDEmisorFactura":"' + aFR[1] + '","NumSerieFactura":"' + aFR[2] + '",' + ;
      '"FechaExpedicionFactura":"' + aFR[3] + '"}]'

STATIC FUNCTION ObtenerFacturaRectificadaData(db, nId)
   LOCAL stmt, aData
   stmt := sqlite3_prepare(db, ;
      "SELECT c.Nif, f.NumeroFactura, f.FechaEmision " + ;
      "FROM Facturas f JOIN Clientes c ON f.ClienteId = c.Id WHERE f.Id = ?")
   sqlite3_bind_int(stmt, 1, nId)
   aData := NIL
   IF sqlite3_step(stmt) == SQLITE_ROW
      aData := { sqlite3_column_text(stmt, 0), sqlite3_column_text(stmt, 1), ;
         FechaDDMMYYYY(SqlDateToDate(sqlite3_column_text(stmt, 2))) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aData
