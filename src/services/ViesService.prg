#require "hbcurl"
#include "hbcurl.ch"

FUNCTION ComprobarVat(cPais, cNumero)
   LOCAL cSoap, cResponse := "", nResult, aResult

   cSoap := '<?xml version="1.0" encoding="UTF-8"?>' + ;
      '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:ec.europa.eu:taxud:vies:services:checkVat:types">' + ;
      '<soap:Body><urn:checkVat><urn:countryCode>' + EscapeXmlVies(cPais) + '</urn:countryCode><urn:vatNumber>' + EscapeXmlVies(cNumero) + '</urn:vatNumber></urn:checkVat></soap:Body></soap:Envelope>'

   nResult := LlamarVies(cSoap, @cResponse)
   IF nResult != 0
      RETURN { .F., NIL, NIL, NIL, "Error de conexión VIES: " + hb_ntos(nResult) }
   ENDIF

   aResult := ProcesarRespuestaVies(cResponse)
   RETURN aResult

STATIC FUNCTION LlamarVies(cSoap, cResponse)
   LOCAL hCurl, aHeaders, nResult

   hCurl := curl_easy_init()
   IF hCurl == NIL
      RETURN -1
   ENDIF

   curl_easy_setopt(hCurl, HB_CURLOPT_URL, "https://ec.europa.eu/taxation_customs/vies/services/checkVatService")
   curl_easy_setopt(hCurl, HB_CURLOPT_POST, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_COPYPOSTFIELDS, cSoap)
   curl_easy_setopt(hCurl, HB_CURLOPT_TIMEOUT, 15)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYPEER, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_NOSIGNAL, 1)

   aHeaders := { "Content-Type: text/xml; charset=utf-8", 'SOAPAction: ""' }
   curl_easy_setopt(hCurl, HB_CURLOPT_HTTPHEADER, aHeaders)
   curl_easy_setopt(hCurl, HB_CURLOPT_WRITEFUNCTION, {|cData| CargaVies(cData, @cResponse)})

   nResult := curl_easy_perform(hCurl)
   curl_easy_cleanup(hCurl)
   RETURN nResult

STATIC FUNCTION CargaVies(cData, cResponse)
   cResponse += cData
   RETURN Len(cData)

STATIC FUNCTION ProcesarRespuestaVies(cXml)
   LOCAL cValid, cNombre, cDireccion, cError, nPos

   nPos := At("<faultstring>", cXml)
   IF nPos > 0
      cError := SubStr(cXml, nPos + 13)
      cError := Left(cError, At("</faultstring>", cError) - 1)
      RETURN { .F., NIL, NIL, NIL, cError }
   ENDIF

   nPos := At("<valid>", cXml)
   IF nPos > 0
      cValid := SubStr(cXml, nPos + 7)
      cValid := Left(cValid, At("</valid>", cValid) - 1)
   ENDIF

   nPos := At("<name>", cXml)
   IF nPos > 0
      cNombre := SubStr(cXml, nPos + 6)
      cNombre := Left(cNombre, At("</name>", cNombre) - 1)
   ENDIF

   nPos := At("<address>", cXml)
   IF nPos > 0
      cDireccion := SubStr(cXml, nPos + 9)
      cDireccion := Left(cDireccion, At("</address>", cDireccion) - 1)
   ENDIF

   IF cValid == "true"
      RETURN { .T., cPais, cNombre, cDireccion, NIL }
   ENDIF
   RETURN { .F., cPais, cNombre, cDireccion, "VAT no válido en VIES" }

STATIC FUNCTION EscapeXmlVies(cText)
   IF cText == NIL; RETURN ""; ENDIF
   cText := StrTran(cText, "&", "&amp;")
   cText := StrTran(cText, "<", "&lt;")
   cText := StrTran(cText, ">", "&gt;")
   RETURN cText
