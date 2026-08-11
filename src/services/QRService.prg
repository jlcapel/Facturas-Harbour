#require "hbcurl"

FUNCTION GenerarUrlVerificacion(cNif, cNumSerie, dFechaEmision, nBaseImponible, nIvaImporte, cEntorno)
   LOCAL cBaseUrl, nTotal
   IF cEntorno == NIL; cEntorno := "Preproduccion"; ENDIF
   cBaseUrl := Iif(cEntorno == "Produccion", ;
      "https://www.agenciatributaria.gob.es", ;
      "https://prewww2.aeat.es")
   nTotal := nBaseImponible + nIvaImporte
   RETURN cBaseUrl + "/wlpl/TIKE-CONT/ValidarQR" + ;
      "?nif=" + EscaparComponenteUrl(cNif) + ;
      "&numserie=" + EscaparComponenteUrl(cNumSerie) + ;
      "&fecha=" + FechaADDMMYYYY(dFechaEmision) + ;
      "&importe=" + DecimalAPuntoSinEspacios(nTotal)

FUNCTION FechaADDMMYYYY(dFecha)
   RETURN PadL(Day(dFecha), 2, "0") + "-" + PadL(Month(dFecha), 2, "0") + "-" + Str(Year(dFecha), 4)

STATIC FUNCTION EscaparComponenteUrl(cValor)
   LOCAL hCurl := curl_easy_init()
   LOCAL cEscapado

   IF Empty(hCurl)
      RETURN cValor
   ENDIF
   cEscapado := curl_easy_escape(hCurl, cValor)
   curl_easy_cleanup(hCurl)
RETURN cEscapado
