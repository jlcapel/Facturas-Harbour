#include "hwgui.ch"

FUNCTION FacturaCrearDialog(db, nFacturaId)
   LOCAL oDlg, lCancel := .F., nResult := 0
   LOCAL aFactura, aLineas := {}
   LOCAL cNumero := "", dFecha := Date(), cDescripcion := ""
   LOCAL aClientes, nClienteSel := 0, nClienteId := 0
   LOCAL aArticulos, aTiposIva
   LOCAL oBrwLineas
   LOCAL nBaseImp := 0, nIvaImp := 0, nIrpf := 0, nIrpfImp := 0, nTotal := 0
   LOCAL aTiposFactura := {"Normal", "Rectificativa", "Anulación"}
   LOCAL nTipoFactura := 1, cAeatTipo := "F1"

   aClientes := ObtenerClientes(db)
   aArticulos := ObtenerArticulos(db)
   aTiposIva := ObtenerTiposIva(db)

   IF nFacturaId != 0
      aFactura := ObtenerFacturaPorId(db, nFacturaId)
      IF aFactura == NIL
         hwg_MsgInfo(L("ServiceFacturaNoEncontrada"), "Error")
         RETURN 0
      ENDIF
      cNumero := aFactura[2]
      dFecha := aFactura[3]
      cDescripcion := aFactura[9]
      nClienteId := aFactura[5]
      nTipoFactura := aFactura[6] + 1
      cAeatTipo := aFactura[10]
      nBaseImp := aFactura[12]
      nIvaImp := aFactura[13]
      nIrpf := aFactura[14]
      nIrpfImp := aFactura[15]
      nTotal := aFactura[16]
      aLineas := ACLone(aFactura[32])
      nClienteSel := AScan(aClientes, {|x| x[1] == nClienteId})
      IF nClienteSel == 0; nClienteSel := 1; ENDIF
   ELSE
      cNumero := GenerarNumeroFactura(db)
      nIrpf := ObtenerIrpfPorcentaje(db)
   ENDIF

   INIT DIALOG oDlg ;
      TITLE Iif(nFacturaId == 0, L("FacturasNueva"), "Editar Factura") ;
      AT 0, 0 ;
      SIZE 780, 600 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 15 SAY L("FacturasNumFactura") SIZE 80, 22
   @ 110, 13 SAY cNumero SIZE 150, 26

   @ 280, 15 SAY L("FacturasFecha") SIZE 50, 22
   @ 340, 13 GET dFecha SIZE 110, 26

   @ 20, 50 SAY "Cliente:" SIZE 80, 22
   @ 110, 48 GET COMBOBOX nClienteSel ITEMS ListaNombresClientes(aClientes) SIZE 300, 200

   @ 20, 85 SAY L("ArticulosDescripcionLabel") SIZE 80, 22
   @ 110, 83 GET cDescripcion SIZE 500, 26

   @ 20, 120 SAY "Tipo:" SIZE 50, 22
   @ 80, 118 GET COMBOBOX nTipoFactura ITEMS aTiposFactura SIZE 130, 200

   @ 20, 155 GROUPBOX "Líneas" SIZE 730, 280

   @ 30, 175 BROWSE oBrwLineas ARRAY SIZE 600, 220 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL
   oBrwLineas:aArray := aLineas
   oBrwLineas:AddColumn(HColumn():New(L("FacturasArticulo"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 2] > 0, "", "")}, "C", 0, 0))
   oBrwLineas:AddColumn(HColumn():New(L("CommonDescripcion"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 28, 0))
   oBrwLineas:AddColumn(HColumn():New("Cant.", {|v,o| (v), Str(o:aArray[o:nCurrent, 5], 8, 2)}, "C", 8, 0, .F., DT_RIGHT))
   oBrwLineas:AddColumn(HColumn():New(L("CommonPrecio"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrwLineas:AddColumn(HColumn():New("IVA%", {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 6, 2)}, "C", 6, 0, .F., DT_RIGHT))
   oBrwLineas:AddColumn(HColumn():New(L("CommonImporte"), {|v,o| (v), Str(o:aArray[o:nCurrent, 8], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))

   @ 650, 175 BUTTON "Añadir" SIZE 70, 22 OF oDlg ON CLICK {|| LineaAdd(db, aArticulos, aTiposIva, @aLineas, oBrwLineas)}
   @ 650, 205 BUTTON "Quitar" SIZE 70, 22 OF oDlg ON CLICK {|| LineaRemove(@aLineas, oBrwLineas)}

   @ 500, 455 SAY L("FacturasBaseImponible") SIZE 120, 22
   @ 630, 453 SAY Str(nBaseImp, 12, 2) SIZE 110, 26
   @ 500, 485 SAY L("FacturasIvaLabel") SIZE 120, 22
   @ 630, 483 SAY Str(nIvaImp, 12, 2) SIZE 110, 26
   @ 500, 515 SAY "IRPF (" + Str(nIrpf, 5, 1) + "%):" SIZE 120, 22
   @ 630, 513 SAY Str(nIrpfImp, 12, 2) SIZE 110, 26
   @ 500, 545 SAY L("PdfTotalLabel") SIZE 120, 22
   @ 630, 543 SAY Str(nTotal, 12, 2) SIZE 110, 26

   @ 180, 570 BUTTON L("CommonGuardar") SIZE 90, 28 ON CLICK {;
      nResult := GuardarFacturaDesdeDialog(db, nFacturaId, cNumero, dFecha, cDescripcion, ;
         aClientes, nClienteSel, nTipoFactura, cAeatTipo, nIrpf, aLineas), ;
      Iif(nResult > 0, oDlg:Close(), NIL) }
   @ 320, 570 BUTTON L("CommonCancelar") SIZE 90, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF lCancel
      RETURN 0
   ENDIF
   RETURN nResult

STATIC FUNCTION ListaNombresClientes(aClientes)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aClientes)
      AAdd(aNombres, aClientes[nI][2])
   NEXT
   RETURN aNombres

STATIC FUNCTION LineaAdd(db, aArticulos, aTiposIva, aLineas, oBrw)
   LOCAL aResult := LineaEditDialog(db, aArticulos, aTiposIva, NIL)
   IF aResult != NIL
      AAdd(aLineas, aResult)
      oBrw:aArray := aLineas
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION LineaRemove(aLineas, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aLineas)
      RETURN
   ENDIF
   hb_ADel(aLineas, nRow, .T.)
   oBrw:aArray := aLineas
   oBrw:Refresh()
RETURN NIL

STATIC FUNCTION LineaEditDialog(db, aArticulos, aTiposIva, aLinea)
   LOCAL oDlg, lCancel := .F.
   LOCAL nArtSel := 0, cDescripcion := Space(50)
   LOCAL nCantidad := 1, cPrecio := Space(12)
   LOCAL nIvaSel := 0, nImporte := 0
   LOCAL aArt, nArtId, nIvaId, nIvaPct

   IF aLinea != NIL
      cDescripcion := PadR(aLinea[4], 50)
      nCantidad := aLinea[5]
      cPrecio := Str(aLinea[6], 10, 2)
      nArtId := aLinea[2]
      nIvaId := aLinea[3]
      nIvaPct := aLinea[7]
      nImporte := aLinea[8]
      nArtSel := AScan(aArticulos, {|x| x[1] == nArtId})
      IF nArtSel == 0; nArtSel := 1; ENDIF
      nIvaSel := AScan(aTiposIva, {|x| x[1] == nIvaId})
      IF nIvaSel == 0; nIvaSel := 1; ENDIF
   ENDIF

   INIT DIALOG oDlg TITLE Iif(aLinea == NIL, L("GastoEditAnadirLinea"), "Editar línea") ;
      AT 0,0 SIZE 480, 300 STYLE DS_CENTER

   @ 20, 20 SAY "Artículo:" SIZE 80, 22
   @ 110, 18 GET COMBOBOX nArtSel ITEMS ListaNombresArticulos(aArticulos) SIZE 250, 200 ;
      ON CHANGE {|| ActualizarDatosLinea(aArticulos, @cDescripcion, @cPrecio, @nIvaSel, ;
         aTiposIva, nArtSel, @nIvaPct)}

   @ 20, 60 SAY L("ArticulosDescripcionLabel") SIZE 80, 22
   @ 110, 58 GET cDescripcion SIZE 320, 26

   @ 20, 100 SAY "Cantidad:" SIZE 80, 22
   @ 110, 98 GET nCantidad SIZE 80, 26 PICTURE "9999.99"

   @ 250, 100 SAY "Precio:" SIZE 50, 22
   @ 310, 98 GET cPrecio SIZE 120, 26 PICTURE "999999.99"

   @ 20, 140 SAY L("ArticulosTipoIva") SIZE 80, 22
   @ 110, 138 GET COMBOBOX nIvaSel ITEMS ListaNombresIva(aTiposIva) SIZE 200, 200

   @ 150, 210 BUTTON "Aceptar" SIZE 90, 30 ON CLICK {|| oDlg:Close()}
   @ 280, 210 BUTTON L("CommonCancelar") SIZE 90, 30 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF lCancel
      RETURN NIL
   ENDIF

   nCantidad := Max(nCantidad, 0.01)
   nImporte := nCantidad * Val(cPrecio)
   nArtId := Iif(nArtSel > 0 .AND. nArtSel <= Len(aArticulos), aArticulos[nArtSel][1], 0)
   nIvaId := Iif(nIvaSel > 0 .AND. nIvaSel <= Len(aTiposIva), aTiposIva[nIvaSel][1], 0)
   nIvaPct := Val(aTiposIva[nIvaSel][2])

   RETURN { 0, nArtId, nIvaId, AllTrim(cDescripcion), nCantidad, Val(cPrecio), nIvaPct, nImporte, 0, 0 }

STATIC FUNCTION ActualizarDatosLinea(aArticulos, cDescripcion, cPrecio, nIvaSel, aTiposIva, nArtSel, nIvaPct)
   LOCAL aArt
   IF nArtSel > 0 .AND. nArtSel <= Len(aArticulos)
      aArt := aArticulos[nArtSel]
      cDescripcion := PadR(aArt[3], 50)
      cPrecio := Str(Val(aArt[4]), 10, 2)
      IF aArt[7] > 0
         nIvaSel := AScan(aTiposIva, {|x| x[1] == aArt[7]})
         IF nIvaSel == 0; nIvaSel := 1; ENDIF
         nIvaPct := Val(aTiposIva[nIvaSel][2])
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION ListaNombresArticulos(aArts)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aArts)
      AAdd(aNombres, "[" + aArts[nI][2] + "] " + aArts[nI][3])
   NEXT
   RETURN aNombres

STATIC FUNCTION ListaNombresIva(aTipos)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aTipos)
      AAdd(aNombres, aTipos[nI][2])
   NEXT
   RETURN aNombres

STATIC FUNCTION GuardarFacturaDesdeDialog(db, nFacturaId, cNumero, dFecha, cDescripcion, ;
      aClientes, nClienteSel, nTipoFactura, cAeatTipo, nIrpf, aLineas)
   LOCAL aFactura, nClienteId, nResult

   IF nClienteSel < 1 .OR. nClienteSel > Len(aClientes)
      hwg_MsgInfo("Seleccione un cliente", "Aviso")
      RETURN 0
   ENDIF

   IF Len(aLineas) == 0
      hwg_MsgInfo("Añada al menos una línea", "Aviso")
      RETURN 0
   ENDIF

   nClienteId := aClientes[nClienteSel][1]

   aFactura := Array(17)
   aFactura[1] := cNumero
   aFactura[2] := dFecha
   aFactura[3] := NIL
   aFactura[4] := nClienteId
   aFactura[5] := nTipoFactura - 1
   aFactura[6] := 0
   aFactura[7] := NIL
   aFactura[8] := cDescripcion
   aFactura[9] := cAeatTipo
   aFactura[10] := ""
   aFactura[16] := 0
   aFactura[17] := 0

   nResult := CrearFactura(db, aFactura, aLineas)
   IF nResult > 0
      hwg_MsgInfo("Factura " + cNumero + " guardada", "Información")
   ELSE
      hwg_MsgInfo("Error al guardar la factura", "Error")
   ENDIF
   RETURN nResult
