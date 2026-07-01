#include "hwgui.ch"

FUNCTION ArticulosView(db, oParent, nX, nY, nW, nH)
   LOCAL oBrw, aData

   aData := ObtenerArticulos(db)

   @ nX+20, nY+20 BROWSE oBrw ARRAY SIZE nW-40, nH-90 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL OF oParent

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("ArticulosCodigo"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 12, 0))
   oBrw:AddColumn(HColumn():New(L("ArticulosDescripcion"), {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 35, 0))
   oBrw:AddColumn(HColumn():New(L("ArticulosPrecio"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 12, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("ArticulosUd"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 8, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("CommonActivo"), {|v,o| (v), iif(o:aArray[o:nCurrent, 6], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))

   @ nX+30, nY+nH-55 BUTTON L("ArticulosNuevo") SIZE 70, 28 OF oParent ON CLICK {|| ArticuloNuevo(db, @aData, oBrw)}
   @ nX+110, nY+nH-55 BUTTON L("ArticulosEditar") SIZE 70, 28 OF oParent ON CLICK {|| ArticuloEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ nX+190, nY+nH-55 BUTTON L("ArticulosEliminar") SIZE 70, 28 OF oParent ON CLICK {|| ArticuloEliminar(db, @aData, oBrw)}
   @ nX+270, nY+nH-55 BUTTON "PDF" SIZE 50, 28 OF oParent ON CLICK {|| ExportPdfArticulos(db, aData)}
RETURN NIL

STATIC FUNCTION ArticuloNuevo(db, aData, oBrw)
   LOCAL aResult := ArticuloEditDialog(db, 0)
   IF aResult != NIL
      GuardarArticulo(db, 0, aResult[1], aResult[2], aResult[3], aResult[4], .T., aResult[5])
      aData := ObtenerArticulos(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ArticuloEditar(db, aData, oBrw, nRow)
   LOCAL aArt, aResult
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un artículo", "Aviso")
      RETURN
   ENDIF
   aArt := aData[nRow]
   aResult := ArticuloEditDialog(db, aArt[1])
   IF aResult != NIL
      GuardarArticulo(db, aArt[1], aResult[1], aResult[2], aResult[3], aResult[4], .T., aResult[5])
      aData := ObtenerArticulos(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ArticuloEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un artículo", "Aviso")
      RETURN
   ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][3] + "?", "Confirmar")
      EliminarArticulo(db, aData[nRow][1])
      aData := ObtenerArticulos(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ArticuloEditDialog(db, nId)
   LOCAL oDlg, lCancel := .F.
   LOCAL cCodigo := Space(15), cDescripcion := Space(50), cPrecio := Space(12)
   LOCAL cUnidad := L("ArticulosUd"), nTipoIvaId := 0
   LOCAL aTiposIva, nTipoIvaSel := 1, aArt

   aTiposIva := ObtenerTiposIva(db)

   IF nId != 0
      aArt := ObtenerArticuloPorId(db, nId)
      IF aArt != NIL
         cCodigo := PadR(aArt[2], 15)
         cDescripcion := PadR(aArt[3], 50)
         cPrecio := PadR(aArt[4], 12)
         cUnidad := aArt[5]
         nTipoIvaId := aArt[7]
         nTipoIvaSel := AScan(aTiposIva, {|x| x[1] == nTipoIvaId})
         IF nTipoIvaSel == 0; nTipoIvaSel := 1; ENDIF
      ENDIF
   ENDIF

   INIT DIALOG oDlg TITLE "Editar artículo" AT 0,0 SIZE 450, 300 STYLE DS_CENTER

   @ 20, 20 SAY L("ArticulosCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 150, 26

   @ 20, 55 SAY L("ArticulosDescripcionLabel") SIZE 80, 22
   @ 110, 53 GET cDescripcion SIZE 300, 26

   @ 20, 90 SAY "Precio:" SIZE 80, 22
   @ 110, 88 GET cPrecio SIZE 120, 26 PICTURE "999999.99"

   @ 20, 125 SAY "Unidad:" SIZE 80, 22
   @ 110, 123 GET cUnidad SIZE 60, 26

   @ 20, 160 SAY L("ArticulosTipoIva") SIZE 80, 22
   @ 110, 158 GET COMBOBOX nTipoIvaSel ITEMS ListaIvaNombres(aTiposIva) SIZE 200, 200

   @ 110, 230 BUTTON L("ArticulosGuardar") SIZE 90, 30 ON CLICK {|| oDlg:Close()}
   @ 240, 230 BUTTON L("ArticulosCancelar") SIZE 90, 30 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF lCancel
      RETURN NIL
   ENDIF

   nTipoIvaId := Iif(nTipoIvaSel > 0 .AND. nTipoIvaSel <= Len(aTiposIva), aTiposIva[nTipoIvaSel][1], 0)

   RETURN { AllTrim(cCodigo), AllTrim(cDescripcion), AllTrim(cPrecio), ;
      Iif(Empty(cUnidad), L("ArticulosUd"), AllTrim(cUnidad)), nTipoIvaId }

STATIC FUNCTION ListaIvaNombres(aTipos)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aTipos)
      AAdd(aNombres, aTipos[nI][2])
   NEXT
   RETURN aNombres

STATIC FUNCTION ExportPdfArticulos(db, aData)
   LOCAL aCols := { ;
      {L("ArticulosCodigo"), 100, 2}, ;
      {L("ArticulosDescripcion"), 250, 3}, ;
      {L("ArticulosPrecio"), 80, 4, .T.}, ;
      {L("ArticulosUd"), 50, 5, .T.}, ;
      {L("CommonActivo"), 50, 6, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, L("ArticulosTitle"), aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, L("CommonExportar")); ENDIF
RETURN NIL
