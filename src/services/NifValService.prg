#require "hbcurl"
#include "hbcurl.ch"

FUNCTION ComprobarNif(db, cNif, cNombre)
   LOCAL cCert, cPass, cSoap, cResponse := "", nResult
   LOCAL cNifClean := Upper(AllTrim(cNif))
   IF Left(cNifClean, 2) == "ES" .AND. Len(cNifClean) > 2 .AND. IsAlpha(SubStr(cNifClean, 3, 1))
      cNifClean := SubStr(cNifClean, 3)
   ENDIF
   cCert := ObtenerConfiguracion(db, "VeriFactu.CertificadoRuta")
   cPass := ObtenerConfiguracion(db, "VeriFactu.CertificadoPassword")
   IF Empty(cCert) .OR. !hb_FileExists(cCert)
      RETURN { .F., NIL, NIL, "Certificado no configurado" }
   ENDIF
   cSoap := ConstruirSoapVnif(cNifClean, cNombre)
   nResult := LlamarVnif(cCert, cPass, cSoap, @cResponse)
   IF nResult != 0
      RETURN { .F., NIL, NIL, "Error de conexión con AEAT VNifV2: " + hb_ntos(nResult) }
   ENDIF
   RETURN ProcesarVnifRespuesta(cResponse)

STATIC FUNCTION ConstruirSoapVnif(cNif, cNombre)
   LOCAL cXml
   cXml := '<?xml version="1.0" encoding="UTF-8"?>' + hb_eol()
   cXml += '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:vnif="http://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/burt/jdit/ws/VNifV2Ent.xsd">' + hb_eol()
   cXml += '<s:Body>' + hb_eol()
   cXml += '<vnif:VNifV2Ent>' + hb_eol()
   cXml += '<vnif:Contribuyente>' + hb_eol()
   cXml += '<vnif:Nif>' + EscapeXmlVnif(cNif) + '</vnif:Nif>' + hb_eol()
   IF !Empty(cNombre)
      cXml += '<vnif:Nombre>' + EscapeXmlVnif(Upper(AllTrim(cNombre))) + '</vnif:Nombre>' + hb_eol()
   ENDIF
   cXml += '</vnif:Contribuyente>' + hb_eol()
   cXml += '</vnif:VNifV2Ent>' + hb_eol()
   cXml += '</s:Body>' + hb_eol()
   cXml += '</s:Envelope>' + hb_eol()
   RETURN cXml

STATIC FUNCTION LlamarVnif(cCert, cPass, cSoap, cResponse)
   LOCAL hCurl, aHeaders, nResult
   hCurl := curl_easy_init()
   IF hCurl == NIL
      RETURN -1
   ENDIF
   curl_easy_setopt(hCurl, HB_CURLOPT_URL, "https://www1.agenciatributaria.gob.es/wlpl/BURT-JDIT/ws/VNifV2SOAP")
   curl_easy_setopt(hCurl, HB_CURLOPT_POST, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_COPYPOSTFIELDS, cSoap)
   curl_easy_setopt(hCurl, HB_CURLOPT_TIMEOUT, 30)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYPEER, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_NOSIGNAL, 1)
   aHeaders := { "Content-Type: text/xml; charset=utf-8", 'SOAPAction: ""' }
   curl_easy_setopt(hCurl, HB_CURLOPT_HTTPHEADER, aHeaders)
   IF !Empty(cCert) .AND. hb_FileExists(cCert)
      curl_easy_setopt(hCurl, HB_CURLOPT_SSLCERT, cCert)
      curl_easy_setopt(hCurl, HB_CURLOPT_SSLCERTTYPE, "P12")
      IF !Empty(cPass)
         curl_easy_setopt(hCurl, HB_CURLOPT_SSLCERTPASSWD, cPass)
      ENDIF
   ENDIF
   curl_easy_setopt(hCurl, HB_CURLOPT_WRITEFUNCTION, {|cData| CargaRespuesta(cData, @cResponse)})
   nResult := curl_easy_perform(hCurl)
   curl_easy_cleanup(hCurl)
   RETURN nResult

STATIC FUNCTION CargaRespuesta(cData, cResponse)
   cResponse += cData
   RETURN Len(cData)

STATIC FUNCTION ProcesarVnifRespuesta(cXml)
   LOCAL cNif, cNombre, cResultado, cError
   LOCAL nPos

   nPos := At("<faultstring>", cXml)
   IF nPos > 0
      cError := SubStr(cXml, nPos + 13)
      cError := Left(cError, At("</faultstring>", cError) - 1)
      RETURN { .F., NIL, NIL, cError }
   ENDIF

   nPos := At("<Nif>", cXml)
   IF nPos > 0
      cNif := SubStr(cXml, nPos + 5)
      cNif := Left(cNif, At("</Nif>", cNif) - 1)
   ENDIF

   nPos := At("<Nombre>", cXml)
   IF nPos > 0
      cNombre := SubStr(cXml, nPos + 8)
      cNombre := Left(cNombre, At("</Nombre>", cNombre) - 1)
   ENDIF

   nPos := At("<Resultado>", cXml)
   IF nPos > 0
      cResultado := SubStr(cXml, nPos + 11)
      cResultado := Left(cResultado, At("</Resultado>", cResultado) - 1)
   ENDIF

   DO CASE
   CASE cResultado == "Identificado"
      RETURN { .T., cNif, cNombre, NIL }
   CASE cResultado == "No identificado-similar"
      RETURN { .T., cNif, cNombre, "Nombre no coincide: " + cNombre }
   CASE cResultado == "No identificado"
      RETURN { .F., cNif, cNombre, "NIF no identificado en censo AEAT" }
   OTHERWISE
      RETURN { .F., cNif, cNombre, "Resultado: " + cResultado }
   ENDCASE
RETURN { .F., NIL, NIL, "Error al procesar respuesta" }

STATIC FUNCTION EscapeXmlVnif(cText)
   IF cText == NIL; RETURN ""; ENDIF
   cText := StrTran(cText, "&", "&amp;")
   cText := StrTran(cText, "<", "&lt;")
   cText := StrTran(cText, ">", "&gt;")
   cText := StrTran(cText, '"', "&quot;")
   RETURN cText
