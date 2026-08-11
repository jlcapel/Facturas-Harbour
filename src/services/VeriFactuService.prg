#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION CalcularHashVeriFactu(cNifEmisor, cNumFactura, dFechaExpedicion, cTipoFactura, nCuotaTotal, nImporteTotal, cHashAnterior, dFechaHoraHuso)
   LOCAL cData, cAnterior, cFechaStr, cFechaHusoStr, cImporte, cCuota

   cAnterior := Iif(cHashAnterior == NIL, "", cHashAnterior)
   cFechaStr := FechaDDMMYYYY(dFechaExpedicion)
   cFechaHusoStr := FechaISO8601ConTimeZone(dFechaHoraHuso)
   cCuota := DecimalAPuntoSinEspacios(nCuotaTotal)
   cImporte := DecimalAPuntoSinEspacios(nImporteTotal)

   cData := "IDEmisorFactura=" + cNifEmisor + ;
      "&NumSerieFactura=" + cNumFactura + ;
      "&FechaExpedicionFactura=" + cFechaStr + ;
      "&TipoFactura=" + cTipoFactura + ;
      "&CuotaTotal=" + cCuota + ;
      "&ImporteTotal=" + cImporte + ;
      "&Huella=" + cAnterior + ;
      "&FechaHoraHusoGenRegistro=" + cFechaHusoStr

   RETURN Upper(hb_SHA256(cData, 1))

FUNCTION CrearRegistroAlta(db, nFacturaId, nFacturaVersionFiscalId, cNifEmisor, cNombreEmisor, cNumFactura, dFechaEmision, ;
      nBaseImponible, nIvaImporte, nTotal, cTipoFactura, cTipoRectificativa, ;
      nFacturaRectificadaId, cDescripcion, dFechaOperacion, ;
      cNifCliente, cNombreCliente, cCodigoPais, cCodigoAEAT, ;
      aLineas, lEsNacional)

   LOCAL cHashAnterior, nIdRegistroAnterior, dNtpTime
   LOCAL cHash, cEncadenamiento, cDestinatarios, cDesglose, cSistemaInfo
   LOCAL cFacturasRectificadas := NIL, stmt, nRes, nRegistroId

   dNtpTime := ObtenerFechaHoraOficial()

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
      "FacturaId, FacturaVersionFiscalId, TipoRegistro, Hash, HashAnterior, IdRegistroAnterior, " + ;
      "NifEmisor, NumeroFactura, FechaEmision, " + ;
      "BaseImponible, IvaImporte, Total, " + ;
      "NombreRazonEmisor, IDVersion, TipoFactura, TipoRectificativa, " + ;
      "FacturasRectificadas, FechaOperacion, DescripcionOperacion, " + ;
      "FechaHoraHusoGenRegistro, TipoHuella, FechaRegistro, " + ;
      "Destinatarios, Desglose, SistemaInformatico, Encadenamiento, " + ;
      "EnviadoAEAT) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)")

   sqlite3_bind_int(stmt, 1, nFacturaId)
   IF nFacturaVersionFiscalId == NIL .OR. nFacturaVersionFiscalId == 0
      sqlite3_bind_null(stmt, 2)
   ELSE
      sqlite3_bind_int(stmt, 2, nFacturaVersionFiscalId)
   ENDIF
   sqlite3_bind_int(stmt, 3, 0)
   sqlite3_bind_text(stmt, 4, cHash)
   IF Empty(cHashAnterior)
      sqlite3_bind_null(stmt, 5)
   ELSE
      sqlite3_bind_text(stmt, 5, cHashAnterior)
   ENDIF
   IF nIdRegistroAnterior == 0
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_int(stmt, 6, nIdRegistroAnterior)
   ENDIF
   sqlite3_bind_text(stmt, 7, cNifEmisor)
   sqlite3_bind_text(stmt, 8, cNumFactura)
   sqlite3_bind_text(stmt, 9, FechaISO8601(dFechaEmision))
   sqlite3_bind_text(stmt, 10, Str(nBaseImponible, 12, 2))
   sqlite3_bind_text(stmt, 11, Str(nIvaImporte, 12, 2))
   sqlite3_bind_text(stmt, 12, Str(nBaseImponible + nIvaImporte, 12, 2))
   sqlite3_bind_text(stmt, 13, cNombreEmisor)
   sqlite3_bind_text(stmt, 14, "1.0")
   sqlite3_bind_text(stmt, 15, cTipoFactura)
   sqlite3_bind_text(stmt, 16, cTipoRectificativa)
   IF cFacturasRectificadas == NIL
      sqlite3_bind_null(stmt, 17)
   ELSE
      sqlite3_bind_text(stmt, 17, cFacturasRectificadas)
   ENDIF
   IF dFechaOperacion == NIL
      sqlite3_bind_text(stmt, 18, FechaISO8601(dFechaEmision))
   ELSE
      sqlite3_bind_text(stmt, 18, FechaISO8601(dFechaOperacion))
   ENDIF
   IF cDescripcion == NIL .OR. Empty(cDescripcion)
      sqlite3_bind_text(stmt, 19, "Operacion")
   ELSE
      sqlite3_bind_text(stmt, 19, cDescripcion)
   ENDIF
   sqlite3_bind_text(stmt, 20, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 21, "01")
   sqlite3_bind_text(stmt, 22, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 23, cDestinatarios)
   sqlite3_bind_text(stmt, 24, cDesglose)
   sqlite3_bind_text(stmt, 25, cSistemaInfo)
   sqlite3_bind_text(stmt, 26, cEncadenamiento)

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   IF nRes != SQLITE_DONE
      RETURN 0
   ENDIF
   nRegistroId := sqlite3_last_insert_rowid(db)
RETURN nRegistroId

FUNCTION CrearRegistroSustitutivo(db, nFacturaId, nFacturaVersionFiscalId, cNifEmisor, cNombreEmisor, ;
      cNumFactura, dFechaEmision, nBaseImponible, nIvaImporte, cTipoFactura, ;
      nBaseOriginal, nIvaOriginal, cDescripcion, dFechaOperacion, ;
      cNifCliente, cNombreCliente, cCodigoPais, cCodigoAEAT, aLineas, lEsNacional)

   LOCAL cHashAnterior := ObtenerUltimoHashRegistro(db), nIdRegistroAnterior := ObtenerUltimoIdRegistro(db)
   LOCAL dNtpTime := ObtenerFechaHoraOficial(), cHash, cEncadenamiento, cDestinatarios, cDesglose, cSistemaInfo
   LOCAL cImporteRectificacion, stmt, nRes, nRegistroId

   cHash := CalcularHashVeriFactu(cNifEmisor, cNumFactura, dFechaEmision, ;
      cTipoFactura, nIvaImporte, nBaseImponible + nIvaImporte, cHashAnterior, dNtpTime)
   cEncadenamiento := GenerarEncadenamiento(cHashAnterior, cNifEmisor, cNumFactura, dFechaEmision)
   cDestinatarios := GenerarDestinatariosJson(cNifCliente, cNombreCliente, cCodigoPais, cCodigoAEAT, lEsNacional)
   cDesglose := GenerarDesgloseJson(aLineas)
   cSistemaInfo := GenerarSistemaInformaticoJson(db)
   cImporteRectificacion := '{"BaseRectificada":' + DecimalAPuntoSinEspacios(nBaseOriginal) + ;
      ',"CuotaRectificada":' + DecimalAPuntoSinEspacios(nIvaOriginal) + '}'

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO RegistrosFacturacion(" + ;
      "FacturaId, FacturaVersionFiscalId, TipoRegistro, Hash, HashAnterior, IdRegistroAnterior, " + ;
      "NifEmisor, NumeroFactura, FechaEmision, BaseImponible, IvaImporte, Total, " + ;
      "NombreRazonEmisor, IDVersion, TipoFactura, TipoRectificativa, Subsanacion, ImporteRectificacion, " + ;
      "FechaOperacion, DescripcionOperacion, FechaHoraHusoGenRegistro, TipoHuella, FechaRegistro, " + ;
      "Destinatarios, Desglose, SistemaInformatico, Encadenamiento, EnviadoAEAT) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)")
   IF Empty(stmt)
      RETURN 0
   ENDIF
   sqlite3_bind_int(stmt, 1, nFacturaId)
   sqlite3_bind_int(stmt, 2, nFacturaVersionFiscalId)
   sqlite3_bind_int(stmt, 3, 2)
   sqlite3_bind_text(stmt, 4, cHash)
   IF Empty(cHashAnterior)
      sqlite3_bind_null(stmt, 5)
   ELSE
      sqlite3_bind_text(stmt, 5, cHashAnterior)
   ENDIF
   IF nIdRegistroAnterior == 0
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_int(stmt, 6, nIdRegistroAnterior)
   ENDIF
   sqlite3_bind_text(stmt, 7, cNifEmisor)
   sqlite3_bind_text(stmt, 8, cNumFactura)
   sqlite3_bind_text(stmt, 9, FechaISO8601(dFechaEmision))
   sqlite3_bind_text(stmt, 10, DecimalAPuntoSinEspacios(nBaseImponible))
   sqlite3_bind_text(stmt, 11, DecimalAPuntoSinEspacios(nIvaImporte))
   sqlite3_bind_text(stmt, 12, DecimalAPuntoSinEspacios(nBaseImponible + nIvaImporte))
   sqlite3_bind_text(stmt, 13, cNombreEmisor)
   sqlite3_bind_text(stmt, 14, "1.0")
   sqlite3_bind_text(stmt, 15, cTipoFactura)
   sqlite3_bind_text(stmt, 16, "S")
   sqlite3_bind_text(stmt, 17, "S")
   sqlite3_bind_text(stmt, 18, cImporteRectificacion)
   IF dFechaOperacion == NIL
      sqlite3_bind_text(stmt, 19, FechaISO8601(dFechaEmision))
   ELSE
      sqlite3_bind_text(stmt, 19, FechaISO8601(dFechaOperacion))
   ENDIF
   IF cDescripcion == NIL .OR. Empty(cDescripcion)
      sqlite3_bind_text(stmt, 20, "Operacion")
   ELSE
      sqlite3_bind_text(stmt, 20, cDescripcion)
   ENDIF
   sqlite3_bind_text(stmt, 21, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 22, "01")
   sqlite3_bind_text(stmt, 23, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 24, cDestinatarios)
   sqlite3_bind_text(stmt, 25, cDesglose)
   sqlite3_bind_text(stmt, 26, cSistemaInfo)
   sqlite3_bind_text(stmt, 27, cEncadenamiento)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   IF nRes != SQLITE_DONE
      RETURN 0
   ENDIF
   nRegistroId := sqlite3_last_insert_rowid(db)
RETURN nRegistroId

FUNCTION CrearRegistroAnulacion(db, nFacturaId, nFacturaVersionFiscalId, cNifEmisor, ;
      cNumFacturaAnulacion, dFechaAnulacion, nBaseAnulacion, nIvaAnulacion, ;
      cNumFacturaOriginal, dFechaOriginal, nBaseOriginal, nIvaOriginal)

   LOCAL cHashAnterior, nIdRegistroAnterior, dNtpTime, cHash
   LOCAL cEncadenamiento, cSistemaInfo, stmt, nRes, nRegistroId

   dNtpTime := ObtenerFechaHoraOficial()
   cHashAnterior := ObtenerUltimoHashRegistro(db)
   nIdRegistroAnterior := ObtenerUltimoIdRegistro(db)
   cHash := CalcularHashVeriFactu(cNifEmisor, cNumFacturaAnulacion, dFechaAnulacion, ;
      "R5", nIvaOriginal, nBaseOriginal + nIvaOriginal, ;
      cHashAnterior, dNtpTime)
   cEncadenamiento := GenerarEncadenamiento(cHashAnterior, cNifEmisor, cNumFacturaAnulacion, dFechaAnulacion)
   cSistemaInfo := GenerarSistemaInformaticoJson(db)

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO RegistrosFacturacion(" + ;
      "FacturaId, FacturaVersionFiscalId, TipoRegistro, Hash, HashAnterior, IdRegistroAnterior, " + ;
      "NifEmisor, NumeroFactura, FechaEmision, " + ;
      "BaseImponible, IvaImporte, Total, " + ;
      "IdFacturaAnulada, FechaFacturaAnulada, " + ;
      "FechaRegistro, TipoFactura, IDVersion, " + ;
      "FechaHoraHusoGenRegistro, TipoHuella, " + ;
      "SinRegistroPrevio, RechazoPrevioAnulacion, GeneradoPor, " + ;
      "SistemaInformatico, Encadenamiento, EnviadoAEAT) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)")

   sqlite3_bind_int(stmt, 1, nFacturaId)
   sqlite3_bind_int(stmt, 2, nFacturaVersionFiscalId)
   sqlite3_bind_int(stmt, 3, 1)
   sqlite3_bind_text(stmt, 4, cHash)
   IF Empty(cHashAnterior)
      sqlite3_bind_null(stmt, 5)
   ELSE
      sqlite3_bind_text(stmt, 5, cHashAnterior)
   ENDIF
   IF nIdRegistroAnterior == 0
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_int(stmt, 6, nIdRegistroAnterior)
   ENDIF
   sqlite3_bind_text(stmt, 7, cNifEmisor)
   sqlite3_bind_text(stmt, 8, cNumFacturaAnulacion)
   sqlite3_bind_text(stmt, 9, FechaISO8601(dFechaAnulacion))
   sqlite3_bind_text(stmt, 10, DecimalAPuntoSinEspacios(nBaseAnulacion))
   sqlite3_bind_text(stmt, 11, DecimalAPuntoSinEspacios(nIvaAnulacion))
   sqlite3_bind_text(stmt, 12, DecimalAPuntoSinEspacios(nBaseOriginal + nIvaOriginal))
   sqlite3_bind_text(stmt, 13, cNumFacturaOriginal)
   sqlite3_bind_text(stmt, 14, FechaISO8601(dFechaOriginal))
   sqlite3_bind_text(stmt, 15, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 16, "R5")
   sqlite3_bind_text(stmt, 17, "1.0")
   sqlite3_bind_text(stmt, 18, FechaISO8601ConTimeZone(dNtpTime))
   sqlite3_bind_text(stmt, 19, "01")
   sqlite3_bind_text(stmt, 20, "N")
   sqlite3_bind_text(stmt, 21, "N")
   sqlite3_bind_text(stmt, 22, "E")
   sqlite3_bind_text(stmt, 23, cSistemaInfo)
   sqlite3_bind_text(stmt, 24, cEncadenamiento)
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   IF nRes != SQLITE_DONE
      RETURN 0
   ENDIF
   nRegistroId := sqlite3_last_insert_rowid(db)
RETURN nRegistroId

FUNCTION VerificarCadenaRegistros(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Id, Hash, HashAnterior, NifEmisor, NumeroFactura, " + ;
      "FechaEmision, IvaImporte, BaseImponible, Total, TipoFactura, FechaHoraHusoGenRegistro, IdRegistroAnterior " + ;
      "FROM RegistrosFacturacion ORDER BY Id")
   LOCAL cHashAnterior := "", nIdRegistroAnterior := NIL
   LOCAL nId, cHash, cHashAnteriorActual, cIdAnterior, nIdAnteriorActual, cHashEsperado

   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nId := sqlite3_column_int(stmt, 1)
      cHash := sqlite3_column_text(stmt, 2)
      cHashAnteriorActual := sqlite3_column_text(stmt, 3)
      cIdAnterior := sqlite3_column_text(stmt, 12)
      nIdAnteriorActual := Iif(cIdAnterior == NIL .OR. Empty(cIdAnterior), NIL, Val(cIdAnterior))
      IF Iif(cHashAnteriorActual == NIL, "", cHashAnteriorActual) != cHashAnterior .OR. ;
            nIdAnteriorActual != nIdRegistroAnterior
         sqlite3_finalize(stmt)
         RETURN .F.
      ENDIF
      cHashEsperado := CalcularHashVeriFactu(;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5), ;
         SqlDateToDate(sqlite3_column_text(stmt, 6)), ;
         sqlite3_column_text(stmt, 10), ;
         Val(sqlite3_column_text(stmt, 7)), ;
         Val(sqlite3_column_text(stmt, 9)), ;
         cHashAnterior, ;
         SqlDateTimeToDateTime(sqlite3_column_text(stmt, 11)))
      IF cHash != cHashEsperado
         sqlite3_finalize(stmt)
         RETURN .F.
      ENDIF
      cHashAnterior := cHash
      nIdRegistroAnterior := nId
   ENDDO
   sqlite3_finalize(stmt)
   RETURN .T.

FUNCTION GenerarDesgloseJson(aLineas)
   LOCAL nI, nGrupo, nTipoIvaId, nIvaPct, nImporte
   LOCAL cTipoIvaNombre, cImpuesto, cClaveRegimen, cCalificacion, cExenta
   LOCAL aGrupos := {}, cLineas := ""

   FOR nI := 1 TO Len(aLineas)
      nTipoIvaId := NumeroDesglose(aLineas[nI][3])
      IF nTipoIvaId == 0
         nTipoIvaId := NIL
      ENDIF
      cTipoIvaNombre := TextoDesglose(aLineas[nI][13])
      cImpuesto := CodigoDesglose(aLineas[nI][14], "01")
      cClaveRegimen := CodigoDesglose(aLineas[nI][15], "01")
      cCalificacion := CodigoDesglose(aLineas[nI][16], NIL)
      cExenta := CodigoDesglose(aLineas[nI][17], NIL)
      nIvaPct := NumeroDesglose(aLineas[nI][7])
      nImporte := NumeroDesglose(aLineas[nI][8])
      nGrupo := BuscarGrupoDesglose(aGrupos, nTipoIvaId, nIvaPct, cImpuesto, cClaveRegimen, cCalificacion, cExenta)
      IF nGrupo == 0
         AAdd(aGrupos, {nTipoIvaId, cTipoIvaNombre, cImpuesto, cClaveRegimen, cCalificacion, cExenta, nIvaPct, 0, 0})
         nGrupo := Len(aGrupos)
      ELSEIF aGrupos[nGrupo][2] == NIL .AND. cTipoIvaNombre != NIL
         aGrupos[nGrupo][2] := cTipoIvaNombre
      ENDIF
      aGrupos[nGrupo][8] := aGrupos[nGrupo][8] + nImporte
      aGrupos[nGrupo][9] := aGrupos[nGrupo][9] + CalcularIvaLinea(nImporte, nIvaPct)
   NEXT

   FOR nI := 1 TO Len(aGrupos)
      aGrupos[nI][8] := RoundFiscal(aGrupos[nI][8])
      aGrupos[nI][9] := RoundFiscal(aGrupos[nI][9])
   NEXT
   ASort(aGrupos, , , {|a,b| GrupoDesgloseAntes(a, b)})

   FOR nI := 1 TO Len(aGrupos)
      IF nI > 1
         cLineas += ","
      ENDIF
      cLineas += JsonGrupoDesglose(aGrupos[nI])
   NEXT
RETURN '{"DetalleDesglose":[' + cLineas + ']}'

STATIC FUNCTION BuscarGrupoDesglose(aGrupos, nTipoIvaId, nIvaPct, cImpuesto, cClaveRegimen, cCalificacion, cExenta)
   LOCAL nI

   FOR nI := 1 TO Len(aGrupos)
      IF aGrupos[nI][1] == nTipoIvaId .AND. aGrupos[nI][3] == cImpuesto .AND. ;
            aGrupos[nI][4] == cClaveRegimen .AND. aGrupos[nI][5] == cCalificacion .AND. ;
            aGrupos[nI][6] == cExenta .AND. aGrupos[nI][7] == nIvaPct
         RETURN nI
      ENDIF
   NEXT
RETURN 0

STATIC FUNCTION GrupoDesgloseAntes(aIzquierda, aDerecha)
   LOCAL nComparacion

   nComparacion := CompararNumeroDesglose(aIzquierda[1], aDerecha[1])
   IF nComparacion != 0; RETURN nComparacion < 0; ENDIF
   nComparacion := CompararNumeroDesglose(aIzquierda[7], aDerecha[7])
   IF nComparacion != 0; RETURN nComparacion < 0; ENDIF
   nComparacion := CompararTextoDesglose(aIzquierda[5], aDerecha[5])
   IF nComparacion != 0; RETURN nComparacion < 0; ENDIF
   nComparacion := CompararTextoDesglose(aIzquierda[6], aDerecha[6])
   IF nComparacion != 0; RETURN nComparacion < 0; ENDIF
   nComparacion := CompararTextoDesglose(aIzquierda[3], aDerecha[3])
   IF nComparacion != 0; RETURN nComparacion < 0; ENDIF
RETURN CompararTextoDesglose(aIzquierda[4], aDerecha[4]) < 0

STATIC FUNCTION CompararNumeroDesglose(nIzquierda, nDerecha)
   IF nIzquierda == NIL .AND. nDerecha != NIL; RETURN -1; ENDIF
   IF nIzquierda != NIL .AND. nDerecha == NIL; RETURN 1; ENDIF
   IF nIzquierda == NIL; RETURN 0; ENDIF
   IF nIzquierda < nDerecha; RETURN -1; ENDIF
   IF nIzquierda > nDerecha; RETURN 1; ENDIF
RETURN 0

STATIC FUNCTION CompararTextoDesglose(cIzquierda, cDerecha)
   IF cIzquierda == NIL .AND. cDerecha != NIL; RETURN -1; ENDIF
   IF cIzquierda != NIL .AND. cDerecha == NIL; RETURN 1; ENDIF
   IF cIzquierda == NIL; RETURN 0; ENDIF
   IF cIzquierda < cDerecha; RETURN -1; ENDIF
   IF cIzquierda > cDerecha; RETURN 1; ENDIF
RETURN 0

STATIC FUNCTION NumeroDesglose(xValor)
   IF ValType(xValor) == "N"
      RETURN xValor
   ENDIF
   IF ValType(xValor) == "C"
      RETURN Val(xValor)
   ENDIF
RETURN 0

STATIC FUNCTION TextoDesglose(cValor)
   IF cValor == NIL .OR. Empty(AllTrim(cValor))
      RETURN NIL
   ENDIF
RETURN AllTrim(cValor)

STATIC FUNCTION CodigoDesglose(cValor, cDefecto)
   LOCAL cCodigo := TextoDesglose(cValor)

   IF cCodigo == NIL
      RETURN cDefecto
   ENDIF
RETURN Upper(cCodigo)

STATIC FUNCTION JsonGrupoDesglose(aGrupo)
   RETURN '{"TipoIvaId":' + JsonNumeroONull(aGrupo[1]) + ;
      ',"TipoIvaNombre":' + JsonTextoONull(aGrupo[2]) + ;
      ',"Impuesto":' + JsonTextoONull(aGrupo[3]) + ;
      ',"ClaveRegimen":' + JsonTextoONull(aGrupo[4]) + ;
      ',"CalificacionOperacion":' + JsonTextoONull(aGrupo[5]) + ;
      ',"OperacionExenta":' + JsonTextoONull(aGrupo[6]) + ;
      ',"TipoImpositivo":' + DecimalAPuntoSinEspacios(aGrupo[7]) + ;
      ',"BaseImponibleOimporteNoSujeto":' + DecimalAPuntoSinEspacios(aGrupo[8]) + ;
      ',"CuotaRepercutida":' + DecimalAPuntoSinEspacios(aGrupo[9]) + '}'

STATIC FUNCTION JsonNumeroONull(nValor)
   IF nValor == NIL
      RETURN "null"
   ENDIF
RETURN LTrim(Str(nValor, 12, 0))

STATIC FUNCTION JsonTextoONull(cValor)
   IF cValor == NIL
      RETURN "null"
   ENDIF
RETURN hb_jsonEncode(cValor, .F.)

STATIC FUNCTION ObtenerUltimoHashRegistro(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Hash FROM RegistrosFacturacion ORDER BY Id DESC LIMIT 1")
   LOCAL cHash := ""
   IF sqlite3_step(stmt) == SQLITE_ROW
      cHash := sqlite3_column_text(stmt, 1)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cHash

STATIC FUNCTION ObtenerUltimoIdRegistro(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id FROM RegistrosFacturacion ORDER BY Id DESC LIMIT 1")
   LOCAL nId := 0
   IF sqlite3_step(stmt) == SQLITE_ROW
      nId := sqlite3_column_int(stmt, 1)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN nId

STATIC FUNCTION ObtenerHashPorOrden(db, nOrden)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Hash FROM RegistrosFacturacion ORDER BY Id LIMIT 1 OFFSET ?")
   LOCAL cHash
   sqlite3_bind_int(stmt, 1, nOrden - 1)
   IF sqlite3_step(stmt) == SQLITE_ROW
      cHash := sqlite3_column_text(stmt, 1)
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
      aData := { sqlite3_column_text(stmt, 1), sqlite3_column_text(stmt, 2), ;
         FechaDDMMYYYY(SqlDateToDate(sqlite3_column_text(stmt, 3))) }
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aData

// --- Eventos VERI*FACTU (hash chain) ---

FUNCTION CalcularHashEvento(cTipo, cDesc, cUsuario, dHuso, nIdEventoAnterior, cAnt)
   LOCAL cData := cTipo + "|" + cDesc + "|" + cUsuario + "|" + ;
      FechaISO8601ConTimeZone(dHuso) + "|" + Iif(nIdEventoAnterior == NIL, "", LTrim(Str(nIdEventoAnterior))) + "|" + ;
      Iif(cAnt == NIL, "", cAnt)
   RETURN Upper(hb_SHA256(cData, 1))

FUNCTION ObtenerUltimoEvento(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, Hash FROM RegistrosEvento ORDER BY Id DESC LIMIT 1")
   LOCAL aEvento := NIL
   IF sqlite3_step(stmt) == SQLITE_ROW
      aEvento := {sqlite3_column_int(stmt, 1), sqlite3_column_text(stmt, 2)}
   ENDIF
   sqlite3_finalize(stmt)
RETURN aEvento

FUNCTION RegistrarEvento(db, cTipoEvento, cDescripcion, cUsuario)
   LOCAL aEventoAnterior := ObtenerUltimoEvento(db)
   LOCAL nIdEventoAnterior := Iif(aEventoAnterior == NIL, NIL, aEventoAnterior[1])
   LOCAL cHashAnterior := Iif(aEventoAnterior == NIL, "", aEventoAnterior[2])
   LOCAL cUsuarioFinal := Iif(cUsuario == NIL .OR. Empty(AllTrim(cUsuario)), hb_UserName(), cUsuario)
   LOCAL dFechaHuso := hb_DateTime()
   LOCAL cHash := CalcularHashEvento(cTipoEvento, cDescripcion, cUsuarioFinal, dFechaHuso, nIdEventoAnterior, cHashAnterior)
   LOCAL stmt, nRes

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO RegistrosEvento(TipoEvento, Descripcion, Usuario, FechaHora, Hash, HashAnterior, IdEventoAnterior) " + ;
      "VALUES(?, ?, ?, ?, ?, ?, ?)")

   sqlite3_bind_text(stmt, 1, cTipoEvento)
   sqlite3_bind_text(stmt, 2, cDescripcion)
   sqlite3_bind_text(stmt, 3, cUsuarioFinal)
   sqlite3_bind_text(stmt, 4, FechaISO8601ConTimeZone(dFechaHuso))
   sqlite3_bind_text(stmt, 5, cHash)
   IF Empty(cHashAnterior)
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_text(stmt, 6, cHashAnterior)
   ENDIF
   IF nIdEventoAnterior == NIL
      sqlite3_bind_null(stmt, 7)
   ELSE
      sqlite3_bind_int(stmt, 7, nIdEventoAnterior)
   ENDIF

   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

FUNCTION VerificarCadenaEventos(db)
   LOCAL stmt := sqlite3_prepare(db, "SELECT Id, TipoEvento, Descripcion, Usuario, FechaHora, Hash, HashAnterior, IdEventoAnterior FROM RegistrosEvento ORDER BY Id")
   LOCAL cHashAnterior := "", nIdEventoAnterior := NIL, lOk := .T.
   LOCAL nId, cHash, cHashAnt, cTipo, cDesc, cUsuario, cFecha, cIdAnterior, nIdAnteriorActual, cRecalc

   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nId := sqlite3_column_int(stmt, 1)
      cTipo := sqlite3_column_text(stmt, 2)
      cDesc := sqlite3_column_text(stmt, 3)
      cUsuario := sqlite3_column_text(stmt, 4)
      cFecha := sqlite3_column_text(stmt, 5)
      cHash := sqlite3_column_text(stmt, 6)
      cHashAnt := sqlite3_column_text(stmt, 7)
      cIdAnterior := sqlite3_column_text(stmt, 8)
      nIdAnteriorActual := Iif(cIdAnterior == NIL .OR. Empty(cIdAnterior), NIL, Val(cIdAnterior))
      IF Iif(cHashAnt == NIL, "", cHashAnt) != cHashAnterior .OR. nIdAnteriorActual != nIdEventoAnterior
         lOk := .F.
         EXIT
      ENDIF
      cRecalc := CalcularHashEvento(cTipo, cDesc, Iif(cUsuario == NIL, "", cUsuario), ;
         SqlDateTimeToDateTime(cFecha), nIdAnteriorActual, cHashAnterior)
      IF cRecalc != cHash
         lOk := .F.
         EXIT
      ENDIF
      cHashAnterior := cHash
      nIdEventoAnterior := nId
   ENDDO
   sqlite3_finalize(stmt)
   RETURN lOk
