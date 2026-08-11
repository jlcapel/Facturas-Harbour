#require "hbtest"
#include "hbtest.ch"

PROCEDURE Main()
   LOCAL aTipos, aRedondeo, aCero, aExenta
   LOCAL aDetalleTipos, aDetalleRedondeo, aDetalleCero, aDetalleExenta
   LOCAL lTipos, lRedondeo, lCero, lExenta, lEstructura

   aTipos := { ;
      Linea(2, "IVA Reducido", 10, 50, "01", "01", "S1", NIL), ;
      Linea(1, "IVA General", 21, 100, "01", "01", "S1", NIL), ;
      Linea(3, "IVA Superreducido", 4, 25, "01", "01", "S1", NIL) }
   aDetalleTipos := ObtenerDetalle(GenerarDesgloseJson(aTipos))
   lTipos := Len(aDetalleTipos) == 3 .AND. ;
      aDetalleTipos[1]["TipoIvaId"] == 1 .AND. aDetalleTipos[1]["TipoImpositivo"] == 21 .AND. ;
      aDetalleTipos[1]["BaseImponibleOimporteNoSujeto"] == 100 .AND. aDetalleTipos[1]["CuotaRepercutida"] == 21 .AND. ;
      aDetalleTipos[2]["TipoIvaId"] == 2 .AND. aDetalleTipos[2]["TipoImpositivo"] == 10 .AND. ;
      aDetalleTipos[2]["BaseImponibleOimporteNoSujeto"] == 50 .AND. aDetalleTipos[2]["CuotaRepercutida"] == 5 .AND. ;
      aDetalleTipos[3]["TipoIvaId"] == 3 .AND. aDetalleTipos[3]["TipoImpositivo"] == 4 .AND. ;
      aDetalleTipos[3]["BaseImponibleOimporteNoSujeto"] == 25 .AND. aDetalleTipos[3]["CuotaRepercutida"] == 1

   aRedondeo := { ;
      Linea(1, "IVA General", 21, 0.01, "01", "01", "S1", NIL), ;
      Linea(1, "IVA General", 21, 0.01, "01", "01", "S1", NIL), ;
      Linea(1, "IVA General", 21, 0.01, "01", "01", "S1", NIL) }
   aDetalleRedondeo := ObtenerDetalle(GenerarDesgloseJson(aRedondeo))
   lRedondeo := Len(aDetalleRedondeo) == 1 .AND. ;
      aDetalleRedondeo[1]["BaseImponibleOimporteNoSujeto"] == 0.03 .AND. ;
      aDetalleRedondeo[1]["CuotaRepercutida"] == 0

   aCero := { ;
      Linea(5, "0% - No sujeta", 0, 200, "01", "01", "N2", NIL), ;
      Linea(4, "0% - Inversión sujeto pasivo", 0, 100, "01", "01", "S2", NIL) }
   aDetalleCero := ObtenerDetalle(GenerarDesgloseJson(aCero))
   lCero := Len(aDetalleCero) == 2 .AND. ;
      aDetalleCero[1]["TipoIvaId"] == 4 .AND. aDetalleCero[1]["CalificacionOperacion"] == "S2" .AND. ;
      aDetalleCero[1]["BaseImponibleOimporteNoSujeto"] == 100 .AND. ;
      aDetalleCero[2]["TipoIvaId"] == 5 .AND. aDetalleCero[2]["CalificacionOperacion"] == "N2" .AND. ;
      aDetalleCero[2]["BaseImponibleOimporteNoSujeto"] == 200

   aExenta := {Linea(6, NIL, 0, 100, "01", "01", NIL, "E5")}
   aDetalleExenta := ObtenerDetalle(GenerarDesgloseJson(aExenta))
   lExenta := Len(aDetalleExenta) == 1 .AND. ;
      aDetalleExenta[1]["CalificacionOperacion"] == NIL .AND. ;
      aDetalleExenta[1]["OperacionExenta"] == "E5"
   lEstructura := hb_HHasKey(aDetalleTipos[1], "TipoIvaId") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "TipoIvaNombre") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "Impuesto") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "ClaveRegimen") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "CalificacionOperacion") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "OperacionExenta") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "TipoImpositivo") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "BaseImponibleOimporteNoSujeto") .AND. ;
      hb_HHasKey(aDetalleTipos[1], "CuotaRepercutida")

   HBTEST lTipos IS .T.
   HBTEST lRedondeo IS .T.
   HBTEST lCero IS .T.
   HBTEST lExenta IS .T.
   HBTEST lEstructura IS .T.
   ErrorLevel(Iif(lTipos .AND. lRedondeo .AND. lCero .AND. lExenta .AND. lEstructura, 0, 1))
RETURN

STATIC FUNCTION Linea(nTipoIvaId, cTipoIvaNombre, nIvaPorcentaje, nImporte, cImpuesto, cClaveRegimen, cCalificacionOperacion, cOperacionExenta)
   RETURN {0, 0, nTipoIvaId, "", 1, nImporte, nIvaPorcentaje, nImporte, 0, 0, NIL, NIL, cTipoIvaNombre, ;
      cImpuesto, cClaveRegimen, cCalificacionOperacion, cOperacionExenta, NIL}

STATIC FUNCTION ObtenerDetalle(cJson)
   LOCAL hJson := {=>}

   IF hb_jsonDecode(cJson, @hJson) == 0 .OR. !hb_HHasKey(hJson, "DetalleDesglose")
      RETURN {}
   ENDIF
RETURN hJson["DetalleDesglose"]
