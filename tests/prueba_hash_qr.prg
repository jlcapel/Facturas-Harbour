#require "hbtest"
#include "hbtest.ch"

PROCEDURE Main()
   LOCAL dFechaHash := hb_SToD("20260704")
   LOCAL dtFechaHash := hb_DateTime(2026, 7, 4, 10, 0, 0)
   LOCAL dFechaQr := hb_SToD("20260623")
   LOCAL cFechaHora, cHash, cUrlPreproduccion, cUrlProduccion

   cFechaHora := FechaISO8601ConTimeZone(dtFechaHash)
   cHash := CalcularHashVeriFactu("B12345678", "F2026-000001", dFechaHash, "F1", 21.00, 121.00, "", dtFechaHash)
   cUrlPreproduccion := GenerarUrlVerificacion("B12345678", "F2026-000001", dFechaQr, 1000, 210, "Preproduccion")
   cUrlProduccion := GenerarUrlVerificacion("B12345678", "F2026-000001", dFechaQr, 1000, 210, "Produccion")
   HBTEST cFechaHora IS "2026-07-04T10:00:00Z"
   HBTEST cHash IS "5CCF8FE789742FE35E5F340B789C38DA7569EC697C7D8AD1FF28250140726457"
   HBTEST cUrlPreproduccion IS "https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR?nif=B12345678&numserie=F2026-000001&fecha=23-06-2026&importe=1210.00"
   HBTEST cUrlProduccion IS "https://www.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR?nif=B12345678&numserie=F2026-000001&fecha=23-06-2026&importe=1210.00"
   ErrorLevel(Iif(cFechaHora == "2026-07-04T10:00:00Z" .AND. ;
      cHash == "5CCF8FE789742FE35E5F340B789C38DA7569EC697C7D8AD1FF28250140726457" .AND. ;
      cUrlPreproduccion == "https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR?nif=B12345678&numserie=F2026-000001&fecha=23-06-2026&importe=1210.00" .AND. ;
      cUrlProduccion == "https://www.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR?nif=B12345678&numserie=F2026-000001&fecha=23-06-2026&importe=1210.00", 0, 1))
RETURN
