#require "hbcurl"
#include "hbcurl.ch"

#define SOAP_NS_SOAP     'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
#define SOAP_NS_LR       'xmlns:sfLR="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroLR.xsd"'
#define SOAP_NS_SF       'xmlns:sf="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd"'

FUNCTION EnviarRegistroAlta(db, nRegistroId)
   LOCAL aReg, cEndpoint, cSoap, nResult, cResponse, cCsv, cError
   LOCAL nFacturaId

   aReg := ObtenerRegistroPorId(db, nRegistroId)
   IF aReg == NIL
      RETURN NIL
   ENDIF

   cEndpoint := ObtenerEndpoint(db)
   cSoap := ConstruirSoapAlta(aReg)

   nResult := LlamarSoap(cEndpoint, cSoap, db, @cResponse)
   IF nResult != 0
      RETURN { .F., "", "Error HTTP: " + hb_ntos(nResult) }
   ENDIF

   cCsv := ExtraerValorXml(cResponse, "CSV")
   IF !Empty(cCsv)
      ActualizarRegistroEnviado(db, nRegistroId, cCsv, cResponse)
      nFacturaId := aReg[2]
      RegistrarEvento(db, 1, "Factura enviada a AEAT. CSV: " + cCsv, NIL)
      RETURN { .T., cCsv, "Registro enviado correctamente" }
   ENDIF

   cError := ExtraerErroresXml(cResponse)
   IF !Empty(cError)
      GuardarRespuestaAEAT(db, nRegistroId, cResponse)
      RegistrarEvento(db, 7, "Error envío AEAT: " + Left(cError, 200), NIL)
      RETURN { .F., "", cError }
   ENDIF

   GuardarRespuestaAEAT(db, nRegistroId, cResponse)
   RETURN { .F., "", "Respuesta sin CSV ni errores reconocibles" }

FUNCTION EnviarRegistroAnulacion(db, nRegistroId)
   LOCAL aReg, cEndpoint, cSoap, nResult, cResponse, cCsv, cError

   aReg := ObtenerRegistroPorId(db, nRegistroId)
   IF aReg == NIL
      RETURN NIL
   ENDIF

   cEndpoint := ObtenerEndpoint(db)
   cSoap := ConstruirSoapAnulacion(aReg)

   nResult := LlamarSoap(cEndpoint, cSoap, db, @cResponse)
   IF nResult != 0
      RETURN { .F., "", "Error HTTP: " + hb_ntos(nResult) }
   ENDIF

   cCsv := ExtraerValorXml(cResponse, "CSV")
   IF !Empty(cCsv)
      ActualizarRegistroEnviado(db, nRegistroId, cCsv, cResponse)
      RegistrarEvento(db, 1, "Anulación enviada a AEAT. CSV: " + cCsv, NIL)
      RETURN { .T., cCsv, "Anulación enviada correctamente" }
   ENDIF

   cError := ExtraerErroresXml(cResponse)
   IF !Empty(cError)
      GuardarRespuestaAEAT(db, nRegistroId, cResponse)
      RETURN { .F., "", cError }
   ENDIF

   GuardarRespuestaAEAT(db, nRegistroId, cResponse)
   RETURN { .F., "", "Respuesta sin CSV ni errores reconocibles" }

FUNCTION VerificarEstadoAEAT(db, nRegistroId)
   LOCAL aReg, cEndpoint, cSoap, nResult, cResponse, cCsv, cError

   aReg := ObtenerRegistroPorId(db, nRegistroId)
   IF aReg == NIL
      RETURN NIL
   ENDIF

   cEndpoint := ObtenerEndpointConsulta(db)
   cSoap := ConstruirSoapConsulta(aReg)

   nResult := LlamarSoap(cEndpoint, cSoap, db, @cResponse)
   IF nResult != 0
      RETURN { .F., "", "Error HTTP: " + hb_ntos(nResult) }
   ENDIF

   RETURN { .T., "", cResponse }

STATIC FUNCTION ConstruirSoapAlta(aReg)
   LOCAL cXml

   cXml := '<?xml version="1.0" encoding="UTF-8"?>' + Chr(10)
   cXml += '<soap:Envelope ' + SOAP_NS_SOAP + ' ' + SOAP_NS_LR + ' ' + SOAP_NS_SF + '>' + Chr(10)
   cXml += '<soap:Body>' + Chr(10)
   cXml += '<sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += ConstruirCabecera(aReg)
   cXml += '<sfLR:RegistroFactura>' + Chr(10)
   cXml += '<sf:RegistroAlta>' + Chr(10)
   cXml += '<sf:IDVersion>1.0</sf:IDVersion>' + Chr(10)
   cXml += '<sf:IDFactura>' + Chr(10)
   cXml += '<sf:IDEmisorFactura>' + EscapeXml(aReg[9]) + '</sf:IDEmisorFactura>' + Chr(10)
   cXml += '<sf:NumSerieFactura>' + EscapeXml(aReg[10]) + '</sf:NumSerieFactura>' + Chr(10)
   cXml += '<sf:FechaExpedicionFactura>' + aReg[11] + '</sf:FechaExpedicionFactura>' + Chr(10)
   cXml += '</sf:IDFactura>' + Chr(10)
   cXml += '<sf:NombreRazonEmisor>' + EscapeXml(aReg[28]) + '</sf:NombreRazonEmisor>' + Chr(10)
   cXml += '<sf:TipoFactura>' + EscapeXml(aReg[32]) + '</sf:TipoFactura>' + Chr(10)
   cXml += '<sf:FechaOperacion>' + aReg[11] + '</sf:FechaOperacion>' + Chr(10)
   cXml += '<sf:DescripcionOperacion>' + EscapeXml(aReg[37]) + '</sf:DescripcionOperacion>' + Chr(10)
   cXml += '<sf:FacturaSimplificadaArt7273>N</sf:FacturaSimplificadaArt7273>' + Chr(10)
   cXml += '<sf:FacturaSinIdentifDestinatarioArt61d>N</sf:FacturaSinIdentifDestinatarioArt61d>' + Chr(10)
   cXml += '<sf:Macrodato>N</sf:Macrodato>' + Chr(10)
   cXml += aReg[33]
   cXml += '<sf:CuotaTotal>' + aReg[12] + '</sf:CuotaTotal>' + Chr(10)
   cXml += '<sf:ImporteTotal>' + aReg[13] + '</sf:ImporteTotal>' + Chr(10)
   IF !Empty(aReg[36])
      cXml += '<sf:Encadenamiento>' + aReg[36] + '</sf:Encadenamiento>' + Chr(10)
   ENDIF
   IF !Empty(aReg[35])
      cXml += aReg[35] + Chr(10)
   ENDIF
   cXml += '<sf:FechaHoraHusoGenRegistro>' + aReg[31] + '</sf:FechaHoraHusoGenRegistro>' + Chr(10)
   cXml += '<sf:TipoHuella>' + Iif(Empty(aReg[39]), "01", aReg[39]) + '</sf:TipoHuella>' + Chr(10)
   cXml += '<sf:Huella>' + aReg[24] + '</sf:Huella>' + Chr(10)
   cXml += '</sf:RegistroAlta>' + Chr(10)
   cXml += '</sfLR:RegistroFactura>' + Chr(10)
   cXml += '</sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += '</soap:Body>' + Chr(10)
   cXml += '</soap:Envelope>' + Chr(10)
   RETURN cXml

STATIC FUNCTION ConstruirSoapAnulacion(aReg)
   LOCAL cXml

   cXml := '<?xml version="1.0" encoding="UTF-8"?>' + Chr(10)
   cXml += '<soap:Envelope ' + SOAP_NS_SOAP + ' ' + SOAP_NS_LR + ' ' + SOAP_NS_SF + '>' + Chr(10)
   cXml += '<soap:Body>' + Chr(10)
   cXml += '<sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += ConstruirCabecera(aReg)
   cXml += '<sfLR:RegistroFactura>' + Chr(10)
   cXml += '<sf:RegistroAnulacion>' + Chr(10)
   cXml += '<sf:IDVersion>1.0</sf:IDVersion>' + Chr(10)
   cXml += '<sf:IDFactura>' + Chr(10)
   cXml += '<sf:IDEmisorFacturaAnulada>' + EscapeXml(aReg[9]) + '</sf:IDEmisorFacturaAnulada>' + Chr(10)
   cXml += '<sf:NumSerieFacturaAnulada>' + EscapeXml(aReg[10]) + '</sf:NumSerieFacturaAnulada>' + Chr(10)
   cXml += '<sf:FechaExpedicionFacturaAnulada>' + aReg[11] + '</sf:FechaExpedicionFacturaAnulada>' + Chr(10)
   cXml += '</sf:IDFactura>' + Chr(10)
   IF !Empty(aReg[36])
      cXml += '<sf:Encadenamiento>' + aReg[36] + '</sf:Encadenamiento>' + Chr(10)
   ENDIF
   IF !Empty(aReg[35])
      cXml += aReg[35] + Chr(10)
   ENDIF
   cXml += '<sf:FechaHoraHusoGenRegistro>' + aReg[31] + '</sf:FechaHoraHusoGenRegistro>' + Chr(10)
   cXml += '<sf:TipoHuella>' + Iif(Empty(aReg[39]), "01", aReg[39]) + '</sf:TipoHuella>' + Chr(10)
   cXml += '<sf:Huella>' + aReg[24] + '</sf:Huella>' + Chr(10)
   cXml += '</sf:RegistroAnulacion>' + Chr(10)
   cXml += '</sfLR:RegistroFactura>' + Chr(10)
   cXml += '</sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += '</soap:Body>' + Chr(10)
   cXml += '</soap:Envelope>' + Chr(10)
   RETURN cXml

STATIC FUNCTION ConstruirSoapConsulta(aReg)
   LOCAL cXml

   cXml := '<?xml version="1.0" encoding="UTF-8"?>' + Chr(10)
   cXml += '<soap:Envelope ' + SOAP_NS_SOAP + ' ' + SOAP_NS_LR + ' ' + SOAP_NS_SF + '>' + Chr(10)
   cXml += '<soap:Body>' + Chr(10)
   cXml += '<sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += ConstruirCabecera(aReg)
   cXml += '<sfLR:RegistroFactura>' + Chr(10)
   cXml += '<sf:RegistroAlta>' + Chr(10)
   cXml += '<sf:IDVersion>1.0</sf:IDVersion>' + Chr(10)
   cXml += '<sf:IDFactura>' + Chr(10)
   cXml += '<sf:IDEmisorFactura>' + EscapeXml(aReg[9]) + '</sf:IDEmisorFactura>' + Chr(10)
   cXml += '<sf:NumSerieFactura>' + EscapeXml(aReg[10]) + '</sf:NumSerieFactura>' + Chr(10)
   cXml += '<sf:FechaExpedicionFactura>' + aReg[11] + '</sf:FechaExpedicionFactura>' + Chr(10)
   cXml += '</sf:IDFactura>' + Chr(10)
   cXml += '<sf:Huella>' + aReg[24] + '</sf:Huella>' + Chr(10)
   cXml += '</sf:RegistroAlta>' + Chr(10)
   cXml += '</sfLR:RegistroFactura>' + Chr(10)
   cXml += '</sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += '</soap:Body>' + Chr(10)
   cXml += '</soap:Envelope>' + Chr(10)
   RETURN cXml

STATIC FUNCTION ConstruirCabecera(aReg)
   RETURN '<sfLR:Cabecera>' + Chr(10) + ;
      '<sf:ObligadoEmision>' + Chr(10) + ;
      '<sf:NombreRazon>' + EscapeXml(aReg[28]) + '</sf:NombreRazon>' + Chr(10) + ;
      '<sf:NIF>' + EscapeXml(aReg[9]) + '</sf:NIF>' + Chr(10) + ;
      '</sf:ObligadoEmision>' + Chr(10) + ;
      '</sfLR:Cabecera>' + Chr(10)

STATIC FUNCTION LlamarSoap(cUrl, cSoap, db, cResponse)
   LOCAL hCurl, aHeaders, nResult

   hCurl := curl_easy_init()
   IF hCurl == NIL
      RETURN -1
   ENDIF

   curl_easy_setopt(hCurl, HB_CURLOPT_URL, cUrl)
   curl_easy_setopt(hCurl, HB_CURLOPT_POST, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_COPYPOSTFIELDS, cSoap)
   curl_easy_setopt(hCurl, HB_CURLOPT_TIMEOUT, 60)
   curl_easy_setopt(hCurl, HB_CURLOPT_CONNECTTIMEOUT, 10)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYPEER, 0)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYHOST, 0)
   curl_easy_setopt(hCurl, HB_CURLOPT_NOSIGNAL, 1)

   aHeaders := { "Content-Type: text/xml; charset=utf-8", 'SOAPAction: ""' }
   curl_easy_setopt(hCurl, HB_CURLOPT_HTTPHEADER, aHeaders)

   ConfigurarCertificadoSoap(hCurl, db)
   curl_easy_setopt(hCurl, HB_CURLOPT_WRITEFUNCTION, {|cData| CargaRespuesta(cData, @cResponse)})

   nResult := curl_easy_perform(hCurl)
   curl_easy_cleanup(hCurl)
   RETURN nResult

STATIC FUNCTION CargaRespuesta(cData, cResponse)
   cResponse += cData
   RETURN Len(cData)

STATIC FUNCTION ConfigurarCertificadoSoap(curl, db)
   LOCAL cRuta, cPass

   cRuta := ObtenerConfiguracion(db, "VeriFactu.CertificadoRuta")
   cPass := ObtenerConfiguracion(db, "VeriFactu.CertificadoPassword")

   IF !Empty(cRuta) .AND. hb_FileExists(cRuta)
      curl_easy_setopt(curl, HB_CURLOPT_SSLCERT, cRuta)
      curl_easy_setopt(curl, HB_CURLOPT_SSLCERTTYPE, "P12")
      IF !Empty(cPass)
         curl_easy_setopt(curl, HB_CURLOPT_SSLCERTPASSWD, cPass)
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION ObtenerEndpoint(db)
   LOCAL cEntorno := ObtenerConfiguracion(db, "VeriFactu.Ambiente")
   IF cEntorno == "1"
      RETURN "https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
   ENDIF
   RETURN "https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"

STATIC FUNCTION ObtenerEndpointConsulta(db)
   LOCAL cEntorno := ObtenerConfiguracion(db, "VeriFactu.Ambiente")
   IF cEntorno == "1"
      RETURN "https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
   ENDIF
   RETURN "https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"

STATIC FUNCTION ObtenerRegistroPorId(db, nId)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT * FROM RegistrosFacturacion WHERE Id = ?")
   LOCAL aResult := NIL
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      aResult := Array(40)
      aResult[1]  := sqlite3_column_int(stmt, 0)
      aResult[2]  := sqlite3_column_int(stmt, 1)
      aResult[3]  := sqlite3_column_int(stmt, 2)
      aResult[4]  := sqlite3_column_text(stmt, 3)
      aResult[5]  := sqlite3_column_text(stmt, 4)
      aResult[6]  := sqlite3_column_text(stmt, 5)
      aResult[7]  := sqlite3_column_text(stmt, 6)
      aResult[8]  := sqlite3_column_text(stmt, 7)
      aResult[9]  := sqlite3_column_text(stmt, 8)
      aResult[10] := sqlite3_column_text(stmt, 9)
      aResult[11] := sqlite3_column_text(stmt, 10)
      aResult[12] := sqlite3_column_text(stmt, 11)
      aResult[13] := sqlite3_column_text(stmt, 12)
      aResult[14] := sqlite3_column_text(stmt, 13)
      aResult[15] := sqlite3_column_text(stmt, 14)
      aResult[16] := sqlite3_column_text(stmt, 15)
      aResult[17] := sqlite3_column_text(stmt, 16)
      aResult[18] := sqlite3_column_text(stmt, 17)
      aResult[19] := sqlite3_column_text(stmt, 18)
      aResult[20] := sqlite3_column_text(stmt, 19)
      aResult[21] := sqlite3_column_text(stmt, 20)
      aResult[22] := sqlite3_column_text(stmt, 21)
      aResult[23] := sqlite3_column_text(stmt, 22)
      aResult[24] := sqlite3_column_text(stmt, 23)
      aResult[25] := sqlite3_column_text(stmt, 24)
      aResult[26] := sqlite3_column_text(stmt, 25)
      aResult[27] := sqlite3_column_text(stmt, 26)
      aResult[28] := sqlite3_column_text(stmt, 27)
      aResult[29] := sqlite3_column_text(stmt, 28)
      aResult[30] := sqlite3_column_text(stmt, 29)
      aResult[31] := sqlite3_column_text(stmt, 30)
      aResult[32] := sqlite3_column_text(stmt, 31)
      aResult[33] := sqlite3_column_text(stmt, 32)
      aResult[34] := sqlite3_column_text(stmt, 33)
      aResult[35] := sqlite3_column_text(stmt, 34)
      aResult[36] := sqlite3_column_text(stmt, 35)
      aResult[37] := sqlite3_column_text(stmt, 36)
      aResult[38] := sqlite3_column_text(stmt, 37)
      aResult[39] := sqlite3_column_text(stmt, 38)
      aResult[40] := sqlite3_column_text(stmt, 39)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN aResult

STATIC FUNCTION ActualizarRegistroEnviado(db, nId, cCsv, cRespuesta)
   LOCAL stmt := sqlite3_prepare(db, ;
      "UPDATE RegistrosFacturacion SET CSV=?, EnviadoAEAT=1, " + ;
      "FechaEnvioAEAT=datetime('now'), RespuestaAEAT=? WHERE Id=?")
   sqlite3_bind_text(stmt, 1, cCsv)
   sqlite3_bind_text(stmt, 2, cRespuesta)
   sqlite3_bind_int(stmt, 3, nId)
   sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN NIL

STATIC FUNCTION GuardarRespuestaAEAT(db, nId, cRespuesta)
   LOCAL stmt := sqlite3_prepare(db, ;
      "UPDATE RegistrosFacturacion SET RespuestaAEAT=? WHERE Id=?")
   sqlite3_bind_text(stmt, 1, cRespuesta)
   sqlite3_bind_int(stmt, 2, nId)
   sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN NIL

STATIC FUNCTION ExtraerValorXml(cXml, cElemento)
   LOCAL cPatron := "<[^:]*:" + cElemento + "[^>]*>(.*?)</[^:]*:" + cElemento + "[^>]*>"
   LOCAL nIni, nFin
   nIni := RAt("<" + cElemento, cXml)
   IF nIni == 0
      nIni := RAt(":" + cElemento, cXml)
   ENDIF
   IF nIni > 0
      nIni := hb_At(">", cXml, nIni) + 1
      nFin := hb_At("</", cXml, nIni)
      IF nFin > 0
         RETURN SubStr(cXml, nIni, nFin - nIni)
      ENDIF
   ENDIF
   RETURN ""

STATIC FUNCTION ExtraerErroresXml(cXml)
   LOCAL cErrores := "", cErr
   LOCAL nPos := 1, nIni, nFin
   DO WHILE .T.
      nIni := hb_At("<Error", cXml, nPos)
      IF nIni == 0
         EXIT
      ENDIF
      nIni := hb_At(">", cXml, nIni) + 1
      nFin := hb_At("</Error", cXml, nIni)
      IF nFin == 0
         EXIT
      ENDIF
      cErr := SubStr(cXml, nIni, nFin - nIni)
      IF !Empty(cErr)
         IF !Empty(cErrores)
            cErrores += "; "
         ENDIF
         cErrores += cErr
      ENDIF
      nPos := nFin + 7
   ENDDO
   RETURN cErrores

STATIC FUNCTION EscapeXml(cText)
   IF cText == NIL
      RETURN ""
   ENDIF
   cText := StrTran(cText, "&", "&amp;")
   cText := StrTran(cText, "<", "&lt;")
   cText := StrTran(cText, ">", "&gt;")
   cText := StrTran(cText, '"', "&quot;")
   cText := StrTran(cText, "'", "&apos;")
   RETURN cText
