#include "hwgui.ch"

FUNCTION PaisesView(db, oParent, nX, nY, nW, nH)
   LOCAL oBrw, aData

   aData := ObtenerPaises(db)

   @ nX+20, nY+20 BROWSE oBrw ARRAY SIZE nW-40, nH-90 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL OF oParent
    oBrw:aHeadPadding[4] := 10
    oBrw:aPadding[2] := 6
    oBrw:aPadding[4] := 6

    oBrw:aArray := aData
    oBrw:AddColumn(HColumn():New(L("PaisesCodigo"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 8, 0, .F., DT_CENTER))
    oBrw:AddColumn(HColumn():New(L("PaisesNombre"), {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 30, 0))
    oBrw:AddColumn(HColumn():New(L("PaisesNacionalidad"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 25, 0))
    oBrw:AddColumn(HColumn():New(L("PaisesUe"), {|v,o| (v), iif(o:aArray[o:nCurrent, 5], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))

    @ nX+30, nY+nH-55 BUTTON L("PaisesNuevo") SIZE 70, 28 OF oParent ON CLICK {|| PaisNuevo(db, @aData, oBrw)}
    @ nX+110, nY+nH-55 BUTTON L("PaisesEditar") SIZE 70, 28 OF oParent ON CLICK {|| PaisEditar(db, @aData, oBrw, oBrw:nCurrent)}
    @ nX+190, nY+nH-55 BUTTON L("PaisesEliminar") SIZE 70, 28 OF oParent ON CLICK {|| PaisEliminar(db, @aData, oBrw)}
    @ nX+270, nY+nH-55 BUTTON L("PaisesBtnPdf") SIZE 50, 28 OF oParent ON CLICK {|| ExportPdfPaises(db, aData)}
    @ nX+340, nY+nH-55 BUTTON L("PaisesVolver") SIZE 70, 28 OF oParent ON CLICK {|| CerrarVista()}
RETURN NIL

STATIC FUNCTION PaisNuevo(db, aData, oBrw)
   LOCAL oDlg, cCodigo := Space(2), cNombre := Space(30), cNacionalidad := Space(25)
   LOCAL oChkUE, lEsUE := .F., lCancel := .F.

   INIT DIALOG oDlg TITLE L("PaisesTitleNuevo") AT 0,0 SIZE 350, 220 STYLE DS_CENTER

   @ 20, 20 SAY L("PaisesCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 60, 26
   @ 20, 55 SAY L("PaisesNombreLabel") SIZE 80, 22
   @ 110, 53 GET cNombre SIZE 200, 26
   @ 20, 90 SAY L("PaisesNacionalidadLabel") SIZE 80, 22
   @ 110, 88 GET cNacionalidad SIZE 200, 26
   @ 110, 123 CHECKBOX oChkUE CAPTION L("PaisesMiembroUe") SIZE 170, 26

   @ 80, 175 BUTTON L("PaisesGuardar") SIZE 80, 28 ON CLICK {|| lEsUE := oChkUE:Value(), oDlg:Close()}
   @ 190, 175 BUTTON L("PaisesCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel .AND. !Empty(cCodigo)
      GuardarPais(db, 0, AllTrim(cCodigo), AllTrim(cNombre), AllTrim(cNacionalidad), lEsUE, .T.)

      aData := ObtenerPaises(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION PaisEditar(db, aData, oBrw, nRow)
   LOCAL aPais, oDlg, cCodigo, cNombre, cNacionalidad, oChkUE, lEsUEInit, lEsUE := .F., lCancel := .F.
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("PaisesMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF

   aPais := aData[nRow]
   cCodigo := PadR(aPais[2], 2)
   cNombre := PadR(aPais[3], 30)
   cNacionalidad := PadR(aPais[4], 25)
   lEsUEInit := aPais[5]

   INIT DIALOG oDlg TITLE L("PaisesTitleEditar") AT 0,0 SIZE 350, 220 STYLE DS_CENTER

   @ 20, 20 SAY L("PaisesCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 60, 26
   @ 20, 55 SAY L("PaisesNombreLabel") SIZE 80, 22
   @ 110, 53 GET cNombre SIZE 200, 26
   @ 20, 90 SAY L("PaisesNacionalidadLabel") SIZE 80, 22
   @ 110, 88 GET cNacionalidad SIZE 200, 26
   @ 110, 123 CHECKBOX oChkUE CAPTION L("PaisesMiembroUe") SIZE 170, 26 INIT lEsUEInit

   @ 80, 175 BUTTON L("PaisesGuardar") SIZE 80, 28 ON CLICK {|| lEsUE := oChkUE:Value(), oDlg:Close()}
   @ 190, 175 BUTTON L("PaisesCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel
      GuardarPais(db, aPais[1], AllTrim(cCodigo), AllTrim(cNombre), AllTrim(cNacionalidad), lEsUE, .T.)
      aData := ObtenerPaises(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ExportPdfPaises(db, aData)
   LOCAL aCols := { ;
      {L("PaisesCodigo"), 60, 2}, ;
      {L("PaisesNombre"), 250, 3}, ;
      {L("PaisesNacionalidad"), 200, 4}, ;
      {L("PaisesUe"), 60, 5, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, L("PaisesTitle"), aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo(StrTran(L("PaisesMsgPdfGenerado"), "{1}", cPath), L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION PaisEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("PaisesMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF
   IF hwg_MsgYesNo(StrTran(L("PaisesMsgEliminar"), "{1}", aData[nRow][3]), L("CommonConfirmar"))
      GuardarPais(db, aData[nRow][1], aData[nRow][2], aData[nRow][3], aData[nRow][4], aData[nRow][5], .F.)
      aData := ObtenerPaises(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL
