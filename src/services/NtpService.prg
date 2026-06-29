#require "hbcurl"
#include "hbcurl.ch"

FUNCTION ObtenerFechaHoraOficial()
   LOCAL cUrl := "https://worldtimeapi.org/api/timezone/Europe/Madrid"
   LOCAL hCurl, nResult, cResponse := ""
   LOCAL nPos, cDatetime, cFecha, cHora, nAno, nMes, nDia, nHora, nMin, nSeg, dFecha, tHora

   hCurl := curl_easy_init()
   IF hCurl == NIL
      LogInfo("NtpService: curl_easy_init fallo, usando reloj local")
      RETURN hb_DateTime()
   ENDIF

   curl_easy_setopt(hCurl, HB_CURLOPT_URL, cUrl)
   curl_easy_setopt(hCurl, HB_CURLOPT_TIMEOUT, 5)
   curl_easy_setopt(hCurl, HB_CURLOPT_CONNECTTIMEOUT, 5)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYPEER, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_NOSIGNAL, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_WRITEFUNCTION, {|cData| CargarRespuesta(cData, @cResponse)})

   nResult := curl_easy_perform(hCurl)
   curl_easy_cleanup(hCurl)

   IF nResult != 0 .OR. Empty(cResponse)
      LogInfo("NtpService: error HTTP " + LTrim(Str(nResult)) + ", usando reloj local")
      RETURN hb_DateTime()
   ENDIF

   nPos := At('"datetime":"', cResponse)
   IF nPos == 0
      LogInfo("NtpService: no se encontro datetime en respuesta, usando reloj local")
      RETURN hb_DateTime()
   ENDIF

   cDatetime := SubStr(cResponse, nPos + 12, 19)
   IF Len(cDatetime) < 19
      LogInfo("NtpService: formato datetime invalido, usando reloj local")
      RETURN hb_DateTime()
   ENDIF

   cFecha := Left(cDatetime, 10)
   cHora := SubStr(cDatetime, 12, 8)
   nAno := Val(Left(cFecha, 4))
   nMes := Val(SubStr(cFecha, 6, 2))
   nDia := Val(SubStr(cFecha, 9, 2))
   nHora := Val(Left(cHora, 2))
   nMin := Val(SubStr(cHora, 4, 2))
   nSeg := Val(SubStr(cHora, 7, 2))

   LogInfo("NtpService: hora oficial obtenida")

   RETURN hb_DateTime(nAno, nMes, nDia, nHora, nMin, nSeg)

STATIC FUNCTION CargarRespuesta(cData, cResponse)
   cResponse += cData
RETURN .T.
