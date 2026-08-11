#include "hwgui.ch"

FUNCTION FacturasView(db, oParent, nX, nY, nW, nH)
   LOCAL oBrw, aData

   aData := ObtenerFacturas(db)

   @ nX+20, nY+20 BROWSE oBrw ARRAY SIZE nW-40, nH-90 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL OF oParent

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("FacturasNroFacturaHead"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("FacturasFechaHead"), {|v,o| (v), DToC(o:aArray[o:nCurrent, 3])}, "C", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("FacturasCliente"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New(L("FacturasTipoHead"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 6, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("CommonBase"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("FacturasTotalLinea"), {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("FacturasEstadoHead"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 8] == 0, L("FacturasEstadoEmitida"), L("FacturasEstadoAnulada"))}, "C", 10, 0, .F., DT_CENTER))

   @ nX+30, nY+nH-55 BUTTON L("FacturasBtnNueva") SIZE 70, 28 OF oParent ON CLICK {|| FacturaNueva(db, @aData, oBrw)}
   @ nX+110, nY+nH-55 BUTTON L("FacturasSubsanar") SIZE 70, 28 OF oParent ON CLICK {|| FacturaSubsanar(db, @aData, oBrw)}
   @ nX+190, nY+nH-55 BUTTON L("FacturasImprimir") SIZE 70, 28 OF oParent ON CLICK {|| FacturaImprimir(db, aData, oBrw)}
   @ nX+270, nY+nH-55 BUTTON L("FacturasAnular") SIZE 70, 28 OF oParent ON CLICK {|| FacturaAnular(db, @aData, oBrw)}
RETURN NIL

STATIC FUNCTION FacturaNueva(db, aData, oBrw)
   LOCAL nId := FacturaCrearDialog(db, 0)
   IF nId > 0
      aData := ObtenerFacturas(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaSubsanar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL nId
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("FacturasMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF
   nId := FacturaCrearDialog(db, aData[nRow][1], .T.)
   IF nId > 0
      aData := ObtenerFacturas(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaAnular(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL nFacturaId, cNumFactura, nAnulacion

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("FacturasMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF
   IF aData[nRow][8] != 0
      hwg_MsgInfo(L("ServiceFacturaYaAnulada"), L("CommonAviso"))
      RETURN
   ENDIF

   nFacturaId := aData[nRow][1]
   cNumFactura := aData[nRow][2]

   IF hwg_MsgYesNo(StrTran(L("FacturasMsgAnular"), "{1}", cNumFactura), L("CommonConfirmar"))
      nAnulacion := AnularFactura(db, nFacturaId, L("FacturaAnulacionVoluntaria"))
      IF nAnulacion > 0
         aData := ObtenerFacturas(db)
         oBrw:aArray := aData
         oBrw:Refresh()
      ELSE
         hwg_MsgInfo(StrTran(L("FacturaEditErrorGuardar"), "{0}", "DB Error"), L("CommonError"))
      ENDIF
   ENDIF
RETURN NIL
STATIC FUNCTION FacturaImprimir(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL cRuta, nId, cEntorno

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("FacturasMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF

   nId := aData[nRow][1]
   cRuta := "/tmp/Facturas/" + aData[nRow][2] + ".pdf"
   IF !hb_DirExists("/tmp/Facturas")
      hb_DirBuild("/tmp/Facturas")
   ENDIF

   cEntorno := Iif(ObtenerConfiguracion(db, "VeriFactu.Ambiente") == "2", "Preproduccion", "Produccion")
   IF GenerarPdfFactura(db, nId, cRuta, cEntorno)
      hwg_MsgInfo(StrTran(L("FacturasMsgPdfGenerado"), "{1}", cRuta), L("CommonInformacion"))
   ELSE
      hwg_MsgInfo(L("FacturasMsgErrorPdf"), L("CommonError"))
   ENDIF
RETURN NIL
