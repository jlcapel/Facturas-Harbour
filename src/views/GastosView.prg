#include "hwgui.ch"

FUNCTION GastosView(db)
   LOCAL oDlg, oBrw, aData
   aData := ObtenerGastos(db)
   INIT DIALOG oDlg TITLE "Gastos" AT 0,0 SIZE 900, 520 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER
   @ 20, 20 BROWSE oBrw ARRAY SIZE 750, 410 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL
   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New("Nº Factura", {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New("Fecha", {|v,o| (v), DToC(o:aArray[o:nCurrent, 3])}, "D", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New("Tipo", {|v,o| (v), TipoDocStr(o:aArray[o:nCurrent, 4])}, "C", 10, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New("Proveedor", {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 22, 0))
   oBrw:AddColumn(HColumn():New("Base", {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "N", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("Total", {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 10, 2)}, "N", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("Pagado", {|v,o| (v), Iif(o:aArray[o:nCurrent, 8], "Sí", "No")}, "C", 8, 0, .F., DT_CENTER))
   @ 30, 450 BUTTON "Nuevo" SIZE 70, 28 ON CLICK {|| GastoNuevo(db, @aData, oBrw)}
   @ 110, 450 BUTTON "Editar" SIZE 70, 28 ON CLICK {|| GastoEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 450 BUTTON "Eliminar" SIZE 70, 28 ON CLICK {|| GastoEliminar(db, @aData, oBrw)}
   @ 270, 450 BUTTON "Pagado/No" SIZE 80, 28 ON CLICK {|| GastoTogglePago(db, @aData, oBrw)}
   @ 740, 450 BUTTON "Volver" SIZE 70, 28 ON CLICK {|| oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
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

FUNCTION TipoDocStr(nTipo)
   LOCAL aTipos := {"Factura", "Ticket Simplif.", "Recibo", "DUA", "Otro"}
   IF nTipo < 1 .OR. nTipo > Len(aTipos)
      RETURN "Otro"
   ENDIF
   RETURN aTipos[nTipo + 1]

FUNCTION MedioPagoStr(nPago)
   LOCAL aPagos := {"Efectivo", "Transferencia", "Tarjeta", "Domiciliación", "Otro"}
   IF nPago < 1 .OR. nPago > Len(aPagos)
      RETURN "Otro"
   ENDIF
   RETURN aPagos[nPago + 1]
