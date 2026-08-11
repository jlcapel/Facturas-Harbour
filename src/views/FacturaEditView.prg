#include "hwgui.ch"

FUNCTION FacturaCrearDialog(db, nFacturaId, lSubsanando)
   LOCAL oDlg, lCancel := .F., nResult := 0
   LOCAL aFactura, aLineas := {}
   LOCAL cNumero := "", dFecha := Date(), cDescripcion := ""
   LOCAL aClientes, nClienteSel := 0, nClienteId := 0
   LOCAL aArticulos, aTiposIva
   LOCAL oBrwLineas
   LOCAL nBaseImp := 0, nIvaImp := 0, nIrpf := 0, nIrpfImp := 0, nTotal := 0
   LOCAL aTiposFactura := {L("FacturaTipoNormal"), L("FacturaTipoRectificativa"), L("FacturaTipoAnulacion")}
   LOCAL nTipoFactura := 1, cAeatTipo := "F1"

   IF lSubsanando == NIL
      lSubsanando := .F.
   ENDIF

   aClientes := ObtenerClientes(db)
   aArticulos := ObtenerArticulos(db)
   aTiposIva := ObtenerTiposIva(db)

   IF nFacturaId != 0
      aFactura := ObtenerFacturaPorId(db, nFacturaId)
      IF aFactura == NIL
         hwg_MsgInfo(L("ServiceFacturaNoEncontrada"), "Error")
         RETURN 0
      ENDIF
      IF !lSubsanando
         hwg_MsgInfo(L("FacturaEditNoModificar"), L("CommonAviso"))
         RETURN 0
      ENDIF
      IF aFactura[25] == 0
         hwg_MsgInfo(L("ServiceFacturaSinRegistro"), L("CommonAviso"))
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
      TITLE Iif(nFacturaId == 0, L("FacturasNueva"), StrTran(L("FacturaEditSubsanando"), "{0}", cNumero)) ;
      AT 0, 0 ;
      SIZE 780, 600 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 15 SAY L("FacturasNumFactura") SIZE 80, 22
   @ 110, 13 SAY cNumero SIZE 150, 26

   @ 280, 15 SAY L("FacturasFecha") SIZE 50, 22
   @ 340, 13 GET dFecha SIZE 110, 26

   @ 20, 50 SAY L("ClientesClienteLabel") SIZE 80, 22
   @ 110, 48 GET COMBOBOX nClienteSel ITEMS ListaNombresClientes(aClientes) SIZE 300, 200

   @ 20, 85 SAY L("ArticulosDescripcionLabel") SIZE 80, 22
   @ 110, 83 GET cDescripcion SIZE 500, 26

   @ 20, 120 SAY L("FacturasTipoLabel") SIZE 50, 22
   @ 80, 118 GET COMBOBOX nTipoFactura ITEMS aTiposFactura SIZE 130, 200

   @ 20, 155 GROUPBOX L("FacturaEditLineas") SIZE 730, 280

   @ 30, 175 BROWSE oBrwLineas ARRAY SIZE 600, 220 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL
   oBrwLineas:aArray := aLineas
   oBrwLineas:AddColumn(HColumn():New(L("FacturasArticulo"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 2] > 0, "", "")}, "C", 0, 0))
   oBrwLineas:AddColumn(HColumn():New(L("CommonDescripcion"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 28, 0))
   oBrwLineas:AddColumn(HColumn():New(L("FacturaEditCantHead"), {|v,o| (v), Str(o:aArray[o:nCurrent, 5], 8, 2)}, "C", 8, 0, .F., DT_RIGHT))
   oBrwLineas:AddColumn(HColumn():New(L("FacturasPrecio"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrwLineas:AddColumn(HColumn():New(L("FacturaEditIvaPctHead"), {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 6, 2)}, "C", 6, 0, .F., DT_RIGHT))
   oBrwLineas:AddColumn(HColumn():New(L("CommonImporte"), {|v,o| (v), Str(o:aArray[o:nCurrent, 8], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))

   @ 650, 175 BUTTON L("FacturaEditAnadirLinea") SIZE 70, 22 OF oDlg ON CLICK {|| LineaAdd(db, aArticulos, aTiposIva, @aLineas, oBrwLineas)}
   @ 650, 205 BUTTON L("FacturaEditQuitarLinea") SIZE 70, 22 OF oDlg ON CLICK {|| LineaRemove(@aLineas, oBrwLineas)}

   @ 500, 455 SAY L("FacturasBaseImponible") SIZE 120, 22
   @ 630, 453 SAY Str(nBaseImp, 12, 2) SIZE 110, 26
   @ 500, 485 SAY L("FacturasIvaLabel") SIZE 120, 22
   @ 630, 483 SAY Str(nIvaImp, 12, 2) SIZE 110, 26
   @ 500, 515 SAY StrTran(L("FacturaEditIrpfLabel"), "{1}", Str(nIrpf, 5, 1)) SIZE 120, 22
   @ 630, 513 SAY Str(nIrpfImp, 12, 2) SIZE 110, 26
   @ 500, 545 SAY L("PdfTotalLabel") SIZE 120, 22
   @ 630, 543 SAY Str(nTotal, 12, 2) SIZE 110, 26

   @ 180, 570 BUTTON L("CommonGuardar") SIZE 90, 28 ON CLICK {;
      nResult := GuardarFacturaDesdeDialog(db, nFacturaId, cNumero, dFecha, cDescripcion, ;
         aClientes, nClienteSel, nTipoFactura, cAeatTipo, nIrpf, aLineas, lSubsanando), ;
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
   LOCAL aTratamientos := ObtenerTratamientosIva(), nTratamientoSel := 1, aTratamiento

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
      nTratamientoSel := BuscarIndiceTratamiento(aTratamientos, aLinea[16], aLinea[17])
   ENDIF

   INIT DIALOG oDlg TITLE Iif(aLinea == NIL, L("FacturaEditAnadirLinea"), L("FacturaEditTitleEditarLinea")) ;
      AT 0,0 SIZE 480, 350 STYLE DS_CENTER

   @ 20, 20 SAY L("ArticulosDescripcionLabel") SIZE 80, 22
   @ 110, 18 GET COMBOBOX nArtSel ITEMS ListaNombresArticulos(aArticulos) SIZE 250, 200 ;
      ON CHANGE {|| ActualizarDatosLinea(aArticulos, @cDescripcion, @cPrecio, @nIvaSel, ;
         aTiposIva, nArtSel, @nIvaPct, aTratamientos, @nTratamientoSel)}

   @ 20, 60 SAY L("ArticulosDescripcionLabel") SIZE 80, 22
   @ 110, 58 GET cDescripcion SIZE 320, 26

   @ 20, 100 SAY L("FacturaEditCantidadLabel") SIZE 80, 22
   @ 110, 98 GET nCantidad SIZE 80, 26 PICTURE "9999.99"

   @ 250, 100 SAY L("FacturaEditPrecioLabel") SIZE 50, 22
   @ 310, 98 GET cPrecio SIZE 120, 26 PICTURE "999999.99"

   @ 20, 140 SAY L("ArticulosTipoIva") SIZE 80, 22
   @ 110, 138 GET COMBOBOX nIvaSel ITEMS ListaNombresIva(aTiposIva) SIZE 200, 200 ;
      ON CHANGE {|| ActualizarTratamientoDesdeTipo(aTiposIva, nIvaSel, aTratamientos, @nTratamientoSel)}

   @ 20, 175 SAY L("FacturasTratamientoIva") SIZE 80, 22
   @ 110, 173 GET COMBOBOX nTratamientoSel ITEMS ListaNombresTratamientos(aTratamientos) SIZE 320, 200

   @ 150, 250 BUTTON L("CommonAceptar") SIZE 90, 30 ON CLICK {|| oDlg:Close()}
   @ 280, 250 BUTTON L("CommonCancelar") SIZE 90, 30 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF lCancel
      RETURN NIL
   ENDIF

   nCantidad := Max(nCantidad, 0.01)
   nImporte := nCantidad * Val(cPrecio)
   nArtId := Iif(nArtSel > 0 .AND. nArtSel <= Len(aArticulos), aArticulos[nArtSel][1], 0)
   nIvaId := Iif(nIvaSel > 0 .AND. nIvaSel <= Len(aTiposIva), aTiposIva[nIvaSel][1], 0)
   nIvaPct := Val(aTiposIva[nIvaSel][2])
   aTratamiento := aTratamientos[nTratamientoSel]

   RETURN { 0, nArtId, nIvaId, AllTrim(cDescripcion), nCantidad, Val(cPrecio), nIvaPct, nImporte, 0, 0, ;
      NIL, NIL, NIL, aTratamiento[3], aTratamiento[4], aTratamiento[5], aTratamiento[6], aTratamiento[7] }

STATIC FUNCTION ActualizarDatosLinea(aArticulos, cDescripcion, cPrecio, nIvaSel, aTiposIva, nArtSel, nIvaPct, aTratamientos, nTratamientoSel)
   LOCAL aArt
   IF nArtSel > 0 .AND. nArtSel <= Len(aArticulos)
      aArt := aArticulos[nArtSel]
      cDescripcion := PadR(aArt[3], 50)
      cPrecio := Str(Val(aArt[4]), 10, 2)
      IF aArt[7] > 0
         nIvaSel := AScan(aTiposIva, {|x| x[1] == aArt[7]})
         IF nIvaSel == 0; nIvaSel := 1; ENDIF
         nIvaPct := Val(aTiposIva[nIvaSel][2])
         ActualizarTratamientoDesdeTipo(aTiposIva, nIvaSel, aTratamientos, @nTratamientoSel)
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

STATIC FUNCTION ListaNombresTratamientos(aTratamientos)
   LOCAL aNombres := {}, nI

   FOR nI := 1 TO Len(aTratamientos)
      AAdd(aNombres, aTratamientos[nI][1] + " - " + aTratamientos[nI][2])
   NEXT
RETURN aNombres

STATIC FUNCTION BuscarIndiceTratamiento(aTratamientos, cCalificacionOperacion, cOperacionExenta)
   LOCAL aTratamiento := BuscarTratamientoIva(cCalificacionOperacion, cOperacionExenta)
   LOCAL nIndice

   IF aTratamiento == NIL
      aTratamiento := aTratamientos[1]
   ENDIF
   nIndice := AScan(aTratamientos, {|a| a[1] == aTratamiento[1]})
   IF nIndice == 0
      nIndice := 1
   ENDIF
RETURN nIndice

STATIC FUNCTION ActualizarTratamientoDesdeTipo(aTiposIva, nIvaSel, aTratamientos, nTratamientoSel)
   LOCAL aTratamiento

   IF nIvaSel < 1 .OR. nIvaSel > Len(aTiposIva)
      RETURN NIL
   ENDIF
   aTratamiento := TratamientoIvaDesdeTipo(aTiposIva[nIvaSel])
   IF aTratamiento != NIL
      nTratamientoSel := AScan(aTratamientos, {|a| a[1] == aTratamiento[1]})
      IF nTratamientoSel == 0
         nTratamientoSel := 1
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION GuardarFacturaDesdeDialog(db, nFacturaId, cNumero, dFecha, cDescripcion, ;
      aClientes, nClienteSel, nTipoFactura, cAeatTipo, nIrpf, aLineas, lSubsanando)
   LOCAL aFactura, nClienteId, nResult, nI, aTratamiento

   IF nClienteSel < 1 .OR. nClienteSel > Len(aClientes)
      hwg_MsgInfo(L("ClientesMsgSeleccione"), L("CommonAviso"))
      RETURN 0
   ENDIF

   IF Len(aLineas) == 0
      hwg_MsgInfo(L("FacturaEditMinLineas"), L("CommonAviso"))
      RETURN 0
   ENDIF

   FOR nI := 1 TO Len(aLineas)
      aTratamiento := BuscarTratamientoIva(aLineas[nI][16], aLineas[nI][17])
      IF aTratamiento != NIL .AND. TratamientoIvaExigeIvaCero(aTratamiento) .AND. aLineas[nI][7] != 0
         hwg_MsgInfo(StrTran(StrTran(L("FacturaEditTratamientoIvaRequiereCero"), "{0}", LTrim(Str(nI))), "{1}", aTratamiento[1]), L("CommonAviso"))
         RETURN 0
      ENDIF
   NEXT

   nClienteId := aClientes[nClienteSel][1]

   aFactura := Array(17)
   aFactura[1] := cNumero
   aFactura[2] := dFecha
   aFactura[3] := Iif(lSubsanando, dFecha, NIL)
   aFactura[4] := nClienteId
   aFactura[5] := nTipoFactura - 1
   aFactura[6] := 0
   aFactura[7] := NIL
   aFactura[8] := cDescripcion
   aFactura[9] := cAeatTipo
   aFactura[10] := ""
   aFactura[16] := 0
   aFactura[17] := 0

   IF lSubsanando
      nResult := SubsanarFactura(db, nFacturaId, aFactura, aLineas)
   ELSE
      nResult := CrearFactura(db, aFactura, aLineas)
   ENDIF
   IF nResult > 0
      IF lSubsanando
         hwg_MsgInfo(L("FacturaEditGuardada"), L("CommonInformacion"))
      ELSE
         hwg_MsgInfo(StrTran(L("FacturaEditMsgGuardada"), "{1}", cNumero), L("CommonInformacion"))
      ENDIF
   ELSE
      hwg_MsgInfo(StrTran(L("FacturaEditErrorGuardar"), "{1}", "DB Error"), L("CommonError"))
   ENDIF
   RETURN nResult
