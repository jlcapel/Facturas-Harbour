STATIC aTiposFactura := {"F1", "R1", "R2", "R3", "R4"}
STATIC aTiposRectificacion := {"S", "I"}

FUNCTION AeatTiposFactura()
   RETURN aTiposFactura

FUNCTION AeatTiposRectificacion()
   RETURN aTiposRectificacion

FUNCTION AeatEsRectificativa(cTipo)
   RETURN cTipo == "R1" .OR. cTipo == "R2" .OR. cTipo == "R3" .OR. cTipo == "R4"

FUNCTION AeatUrlValidarQR(cEntorno)
   IF cEntorno == NIL .OR. cEntorno == "Preproduccion"
      RETURN "https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR"
   ENDIF
   RETURN "https://www.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR"

FUNCTION AeatUrlEnvio(cEntorno)
   IF cEntorno == NIL .OR. cEntorno == "Preproduccion"
      RETURN "https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
   ENDIF
   RETURN "https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"

FUNCTION AeatNifUrlVal(cEntorno)
   RETURN "https://www1.agenciatributaria.gob.es/wlpl/BURT-JDIT/ws/VNifV2SOAP"
