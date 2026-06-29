FUNCTION GenerarUrlVerificacion(cNif, cNumSerie, dFechaEmision, nBaseImponible, nIvaImporte, cEntorno)
   LOCAL cBaseUrl, nTotal
   IF cEntorno == NIL; cEntorno := "Preproduccion"; ENDIF
   cBaseUrl := Iif(cEntorno == "Produccion", ;
      "https://www.agenciatributaria.gob.es", ;
      "https://prewww2.aeat.es")
   nTotal := nBaseImponible + nIvaImporte
   RETURN cBaseUrl + "/wlpl/TIKE-CONT/ValidarQR" + ;
      "?nif=" + cNif + ;
      "&numserie=" + cNumSerie + ;
      "&fecha=" + FechaADDMMYYYY(dFechaEmision) + ;
      "&importe=" + StrTran(Str(nTotal, 12, 2), ",", ".")

FUNCTION FechaADDMMYYYY(dFecha)
   RETURN PadL(Day(dFecha), 2, "0") + "-" + PadL(Month(dFecha), 2, "0") + "-" + Str(Year(dFecha), 4)
