#include "hwgui.ch"

FUNCTION PaisesView(db)
   LOCAL oDlg, oBrw, aData
   LOCAL lSalir := .F.

   aData := ObtenerPaises(db)

   INIT DIALOG oDlg ;
      TITLE L("PaisesTitle") ;
      AT 0, 0 ;
      SIZE 650, 450 ;
      STYLE WS_POPUP + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 20, 20 BROWSE oBrw ARRAY SIZE 450, 350 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("PaisesCodigo"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 8, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("PaisesNombre"), {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 30, 0))
   oBrw:AddColumn(HColumn():New(L("PaisesNacionalidad"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 20, 0))
   oBrw:AddColumn(HColumn():New(L("PaisesUe"), {|v,o| (v), iif(o:aArray[o:nCurrent, 5], L("CommonSi"), L("CommonNo"))}, "C", 6, 0, .F., DT_CENTER))

   @ 30, 400 BUTTON L("PaisesNuevo") SIZE 70, 28 ON CLICK {|| PaisNuevo(db, @aData, oBrw)}
   @ 110, 400 BUTTON L("PaisesEditar") SIZE 70, 28 ON CLICK {|| PaisEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 400 BUTTON L("PaisesEliminar") SIZE 70, 28 ON CLICK {|| PaisEliminar(db, @aData, oBrw)}
   @ 270, 400 BUTTON "PDF" SIZE 50, 28 ON CLICK {|| ExportPdfPaises(db, aData)}
   @ 520, 400 BUTTON L("PaisesVolver") SIZE 70, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION PaisNuevo(db, aData, oBrw)
   LOCAL oDlg, cCodigo := Space(2), cNombre := Space(30), cNacionalidad := Space(25)
   LOCAL lEsUE := .F., lCancel := .F.

   INIT DIALOG oDlg TITLE "Nuevo país" AT 0,0 SIZE 350, 220 STYLE DS_CENTER

   @ 20, 20 SAY L("ArticulosCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 60, 26
   @ 20, 55 SAY L("PaisesNombreLabel") SIZE 80, 22
   @ 110, 53 GET cNombre SIZE 200, 26
   @ 20, 90 SAY L("PaisesNacionalidadLabel") SIZE 80, 22
   @ 110, 88 GET cNacionalidad SIZE 200, 26
   @ 20, 125 SAY "UE:" SIZE 80, 22
   @ 110, 123 CHECKBOX lEsUE CAPTION "Miembro UE" SIZE 150, 26

   @ 80, 170 BUTTON L("PaisesGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 190, 170 BUTTON L("PaisesCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel .AND. !Empty(cCodigo)
      GuardarPais(db, 0, AllTrim(cCodigo), AllTrim(cNombre), AllTrim(cNacionalidad), lEsUE, .T.)
      aData := ObtenerPaises(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION PaisEditar(db, aData, oBrw, nRow)
   LOCAL aPais, oDlg, cCodigo, cNombre, cNacionalidad, lEsUE, lCancel := .F.

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un país", "Aviso")
      RETURN
   ENDIF

   aPais := aData[nRow]
   cCodigo := PadR(aPais[2], 2)
   cNombre := PadR(aPais[3], 30)
   cNacionalidad := PadR(aPais[4], 25)
   lEsUE := aPais[5]

   INIT DIALOG oDlg TITLE "Editar país" AT 0,0 SIZE 350, 220 STYLE DS_CENTER

   @ 20, 20 SAY L("ArticulosCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 60, 26
   @ 20, 55 SAY L("PaisesNombreLabel") SIZE 80, 22
   @ 110, 53 GET cNombre SIZE 200, 26
   @ 20, 90 SAY L("PaisesNacionalidadLabel") SIZE 80, 22
   @ 110, 88 GET cNacionalidad SIZE 200, 26
   @ 20, 125 SAY "UE:" SIZE 80, 22
   @ 110, 123 CHECKBOX lEsUE CAPTION "Miembro UE" SIZE 150, 26

   @ 80, 170 BUTTON L("PaisesGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 190, 170 BUTTON L("PaisesCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

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
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION PaisEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un país", "Aviso")
      RETURN
   ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][3] + "?", "Confirmar")
      GuardarPais(db, aData[nRow][1], aData[nRow][2], aData[nRow][3], aData[nRow][4], aData[nRow][5], .F.)
      aData := ObtenerPaises(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL
