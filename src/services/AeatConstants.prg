STATIC aTiposFactura := {"F1", "R1", "R2", "R3", "R4"}
STATIC aTiposRectificacion := {"S", "I"}
STATIC aTratamientosIva := { ;
   {"S1", "Sujeta no exenta", "01", "01", "S1", NIL, "Operacion sujeta y no exenta sin inversion del sujeto pasivo."}, ;
   {"S2", "Inversion sujeto pasivo", "01", "01", "S2", NIL, "Operacion sujeta y no exenta con inversion del sujeto pasivo."}, ;
   {"N1", "No sujeta art. 7/14/otros", "01", "01", "N1", NIL, "Operacion no sujeta por articulo 7, articulo 14 u otros supuestos."}, ;
   {"N2", "No sujeta por localizacion", "01", "01", "N2", NIL, "Operacion no sujeta por reglas de localizacion."}, ;
   {"E1", "Exenta art. 20", "01", "01", NIL, "E1", "Operacion exenta por el articulo 20 de la Ley del IVA."}, ;
   {"E2", "Exenta art. 21 exportacion", "01", "02", NIL, "E2", "Operacion exenta por el articulo 21 de la Ley del IVA."}, ;
   {"E3", "Exenta art. 22", "01", "01", NIL, "E3", "Operacion exenta por el articulo 22 de la Ley del IVA."}, ;
   {"E4", "Exenta arts. 23 y 24", "01", "01", NIL, "E4", "Operacion exenta por los articulos 23 y 24 de la Ley del IVA."}, ;
   {"E5", "Exenta art. 25 intracomunitaria", "01", "01", NIL, "E5", "Operacion exenta por el articulo 25 de la Ley del IVA."}, ;
   {"E6", "Exenta otros", "01", "01", NIL, "E6", "Operacion exenta por otros supuestos."} }

FUNCTION AeatTiposFactura()
   RETURN aTiposFactura

FUNCTION AeatTiposRectificacion()
   RETURN aTiposRectificacion

FUNCTION ObtenerTratamientosIva()
   RETURN AClone(aTratamientosIva)

FUNCTION BuscarTratamientoIva(cCalificacionOperacion, cOperacionExenta)
   LOCAL nI, cCodigo

   IF cOperacionExenta != NIL .AND. !Empty(AllTrim(cOperacionExenta))
      cCodigo := Upper(AllTrim(cOperacionExenta))
      FOR nI := 1 TO Len(aTratamientosIva)
         IF aTratamientosIva[nI][6] == cCodigo
            RETURN AClone(aTratamientosIva[nI])
         ENDIF
      NEXT
      RETURN NIL
   ENDIF
   IF cCalificacionOperacion != NIL .AND. !Empty(AllTrim(cCalificacionOperacion))
      cCodigo := Upper(AllTrim(cCalificacionOperacion))
      FOR nI := 1 TO Len(aTratamientosIva)
         IF aTratamientosIva[nI][5] == cCodigo
            RETURN AClone(aTratamientosIva[nI])
         ENDIF
      NEXT
   ENDIF
RETURN NIL

FUNCTION TratamientoIvaDesdeTipo(aTipoIva)
   LOCAL cNombre, aTratamiento

   IF aTipoIva == NIL
      RETURN AClone(aTratamientosIva[1])
   ENDIF
   cNombre := Lower(aTipoIva[2])
   IF At("invers", cNombre) > 0
      RETURN BuscarTratamientoIva("S2", NIL)
   ENDIF
   IF At("no sujeto", cNombre) > 0 .OR. At("no sujeta", cNombre) > 0
      RETURN BuscarTratamientoIva("N2", NIL)
   ENDIF
   IF At("export", cNombre) > 0
      RETURN BuscarTratamientoIva(NIL, "E2")
   ENDIF
   IF At("intracomunit", cNombre) > 0
      RETURN BuscarTratamientoIva(NIL, "E5")
   ENDIF
   IF At("exento", cNombre) > 0
      RETURN BuscarTratamientoIva(NIL, "E6")
   ENDIF
   IF Len(aTipoIva) >= 9
      aTratamiento := BuscarTratamientoIva(aTipoIva[9], NIL)
      IF aTratamiento != NIL
         RETURN aTratamiento
      ENDIF
      IF !Empty(aTipoIva[9])
         RETURN NIL
      ENDIF
   ENDIF
RETURN AClone(aTratamientosIva[1])

FUNCTION TratamientoIvaExigeIvaCero(aTratamiento)
   IF aTratamiento == NIL
      RETURN .F.
   ENDIF
RETURN aTratamiento[1] != "S1"

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
