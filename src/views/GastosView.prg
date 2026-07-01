#include "hwgui.ch"

FUNCTION GastosView(db, oParent, nX, nY, nW, nH)
   LOCAL oBrw, aData
   aData := ObtenerGastos(db)
   @ nX+20, nY+20 BROWSE oBrw ARRAY SIZE nW-40, nH-90 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL OF oParent
   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("GastosNumFactura"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("GastosFecha"), {|v,o| (v), DToC(o:aArray[o:nCurrent, 3])}, "D", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("ClientesTipo"), {|v,o| (v), TipoDocStr(o:aArray[o:nCurrent, 4])}, "C", 10, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("GastosProveedor"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 22, 0))
   oBrw:AddColumn(HColumn():New(L("GastosBase"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "N", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("GastosTotal"), {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 10, 2)}, "N", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("GastosPagado"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 8], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))
   @ nX+30, nY+nH-55 BUTTON L("GastosNuevo") SIZE 70, 28 OF oParent ON CLICK {|| GastoNuevo(db, @aData, oBrw)}
   @ nX+110, nY+nH-55 BUTTON L("GastosEditar") SIZE 70, 28 OF oParent ON CLICK {|| GastoEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ nX+190, nY+nH-55 BUTTON L("GastosEliminar") SIZE 70, 28 OF oParent ON CLICK {|| GastoEliminar(db, @aData, oBrw)}
   @ nX+270, nY+nH-55 BUTTON "Pagado/No" SIZE 80, 28 OF oParent ON CLICK {|| GastoTogglePago(db, @aData, oBrw)}
   @ nX+370, nY+nH-55 BUTTON "PDF" SIZE 50, 28 OF oParent ON CLICK {|| ExportPdfGastos(db, aData)}
RETURN NIL

STATIC FUNCTION GastoNuevo(db, aData, oBrw)
   LOCAL nId := GastoEditDialog(db, 0)
   IF nId > 0
      aData := ObtenerGastos(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION GastoEditar(db, aData, oBrw, nRow)
   LOCAL nId
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un gasto", "Aviso"); RETURN; ENDIF
   nId := GastoEditDialog(db, aData[nRow][1])
   IF nId > 0
      aData := ObtenerGastos(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION GastoEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un gasto", "Aviso"); RETURN; ENDIF
   IF hwg_MsgYesNo("¿Eliminar gasto " + aData[nRow][2] + "?", "Confirmar")
      EliminarGasto(db, aData[nRow][1])
      aData := ObtenerGastos(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION GastoTogglePago(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un gasto", "Aviso"); RETURN; ENDIF
   MarcarGastoPagado(db, aData[nRow][1], !aData[nRow][8])
   aData := ObtenerGastos(db); oBrw:aArray := aData; oBrw:Refresh()
RETURN NIL

STATIC FUNCTION ExportPdfGastos(db, aData)
   LOCAL aCols := { ;
      {L("GastosNumFactura"), 100, 2}, ;
      {L("GastosFecha"), 90, 3}, ;
      {L("ClientesTipo"), 80, 4}, ;
      {L("GastosProveedor"), 160, 5}, ;
      {L("GastosBase"), 80, 6, .T.}, ;
      {L("GastosTotal"), 80, 7, .T.}, ;
      {L("GastosPagado"), 50, 8, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, L("GastosTitle"), aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION TipoDocStr(nTipo)
   LOCAL aTipos := {"Factura", "Ticket Simplif.", "Recibo", "DUA", "Otro"}
   IF nTipo < 1 .OR. nTipo > Len(aTipos)
      RETURN "Otro"
   ENDIF
   RETURN aTipos[nTipo + 1]

STATIC FUNCTION MedioPagoStr(nPago)
   LOCAL aPagos := {"Efectivo", "Transferencia", "Tarjeta", "Domiciliación", "Otro"}
   IF nPago < 1 .OR. nPago > Len(aPagos)
      RETURN "Otro"
   ENDIF
   RETURN aPagos[nPago + 1]
