#include "hwgui.ch"

FUNCTION FacturasView(db)
   LOCAL oDlg, oBrw, aData

   aData := ObtenerFacturas(db)

   INIT DIALOG oDlg ;
      TITLE L("FacturasTitle") ;
      AT 0, 0 ;
      SIZE 850, 520 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 20 BROWSE oBrw ARRAY SIZE 700, 400 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("FacturasNroFacturaHead"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("FacturasFechaHead"), {|v,o| (v), DToC(o:aArray[o:nCurrent, 3])}, "C", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("FacturasCliente"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New(L("FacturasTipoHead"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 6, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("CommonBase"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("FacturasTotalLinea"), {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("FacturasEstadoHead"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 8] == 0, "Emitida", "Anulada")}, "C", 10, 0, .F., DT_CENTER))

   @ 30, 450 BUTTON "Nueva" SIZE 70, 28 ON CLICK {|| FacturaNueva(db, @aData, oBrw)}
   @ 110, 450 BUTTON L("CommonEditar") SIZE 70, 28 ON CLICK {|| FacturaEditar(db, @aData, oBrw)}
   @ 190, 450 BUTTON L("FacturasImprimir") SIZE 70, 28 ON CLICK {|| FacturaImprimir(db, aData, oBrw)}
   @ 270, 450 BUTTON L("FacturasAnular") SIZE 70, 28 ON CLICK {|| FacturaAnular(db, @aData, oBrw)}
   @ 700, 450 BUTTON L("FacturasVolver") SIZE 70, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION FacturaNueva(db, aData, oBrw)
   LOCAL nId := FacturaCrearDialog(db, 0)
   IF nId > 0
      aData := ObtenerFacturas(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaEditar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL nId
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione una factura", "Aviso")
      RETURN
   ENDIF
   nId := FacturaCrearDialog(db, aData[nRow][1])
   IF nId > 0
      aData := ObtenerFacturas(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaAnular(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL nId
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione una factura", "Aviso")
      RETURN
   ENDIF
   IF aData[nRow][8] != 0
      hwg_MsgInfo(L("ServiceFacturaYaAnulada"), "Aviso")
      RETURN
   ENDIF
   IF hwg_MsgYesNo("¿Anular " + aData[nRow][2] + "?", "Confirmar")
      IF AnularFactura(db, aData[nRow][1])
         aData := ObtenerFacturas(db)
         oBrw:aArray := aData
         oBrw:Refresh()
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaImprimir(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL cRuta, nId
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione una factura", "Aviso")
      RETURN
   ENDIF
   nId := aData[nRow][1]
   cRuta := "/tmp/Facturas/" + aData[nRow][2] + ".pdf"
   IF !hb_DirExists("/tmp/Facturas")
      hb_DirBuild("/tmp/Facturas")
   ENDIF
   IF GenerarPdfFactura(db, nId, cRuta)
      hwg_MsgInfo("PDF generado: " + cRuta, "Información")
   ELSE
      hwg_MsgInfo("Error al generar PDF", "Error")
   ENDIF
RETURN NIL
