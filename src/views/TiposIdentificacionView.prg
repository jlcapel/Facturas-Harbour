#include "hwgui.ch"

FUNCTION TiposIdentificacionView(db)
   LOCAL oDlg, oBrw, aData

   aData := ObtenerTiposIdentificacion(db)

   INIT DIALOG oDlg ;
      TITLE "Tipos de identificación" ;
      AT 0, 0 ;
      SIZE 600, 400 ;
      STYLE WS_POPUP + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 20, 20 BROWSE oBrw ARRAY SIZE 400, 300 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("IdentifCodigoAeat"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("IdentifNombre"), {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 40, 0))
   oBrw:AddColumn(HColumn():New(L("CommonActivo"), {|v,o| (v), iif(o:aArray[o:nCurrent, 4], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))

   @ 30, 350 BUTTON L("IdentifNuevo") SIZE 70, 28 ON CLICK {|| TipoIdentNuevo(db, @aData, oBrw)}
   @ 110, 350 BUTTON L("IdentifEditar") SIZE 70, 28 ON CLICK {|| TipoIdentEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 350 BUTTON L("IdentifEliminar") SIZE 70, 28 ON CLICK {|| TipoIdentEliminar(db, @aData, oBrw)}
   @ 270, 350 BUTTON "PDF" SIZE 50, 28 ON CLICK {|| ExportPdfTiposIdent(db, aData)}
   @ 460, 350 BUTTON L("IdentifVolver") SIZE 70, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION TipoIdentNuevo(db, aData, oBrw)
   LOCAL oDlg, cCodigo := Space(10), cNombre := Space(50), lCancel := .F.

   INIT DIALOG oDlg TITLE "Nuevo tipo de identificación" AT 0,0 SIZE 400, 180 STYLE DS_CENTER

   @ 20, 20 SAY L("IdentifCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 100, 26
   @ 20, 55 SAY L("IdentifNombreLabel") SIZE 80, 22
   @ 110, 53 GET cNombre SIZE 250, 26

   @ 100, 120 BUTTON L("IdentifGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 210, 120 BUTTON L("IdentifCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel .AND. !Empty(cCodigo)
      GuardarTipoIdentificacion(db, 0, AllTrim(cCodigo), AllTrim(cNombre), .T.)
      aData := ObtenerTiposIdentificacion(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION TipoIdentEditar(db, aData, oBrw, nRow)
   LOCAL aTipo, oDlg, cCodigo, cNombre, lCancel := .F.

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un tipo de identificación", "Aviso")
      RETURN
   ENDIF

   aTipo := aData[nRow]
   cCodigo := PadR(aTipo[2], 10)
   cNombre := PadR(aTipo[3], 50)

   INIT DIALOG oDlg TITLE "Editar tipo de identificación" AT 0,0 SIZE 400, 180 STYLE DS_CENTER

   @ 20, 20 SAY L("IdentifCodigoLabel") SIZE 80, 22
   @ 110, 18 GET cCodigo SIZE 100, 26
   @ 20, 55 SAY L("IdentifNombreLabel") SIZE 80, 22
   @ 110, 53 GET cNombre SIZE 250, 26

   @ 100, 120 BUTTON L("IdentifGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 210, 120 BUTTON L("IdentifCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel
      GuardarTipoIdentificacion(db, aTipo[1], AllTrim(cCodigo), AllTrim(cNombre), .T.)
      aData := ObtenerTiposIdentificacion(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ExportPdfTiposIdent(db, aData)
   LOCAL aCols := { ;
      {L("IdentifCodigoAeat"), 120, 2}, ;
      {L("IdentifNombre"), 400, 3}, ;
      {L("CommonActivo"), 50, 4, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, "TiposIdentificacion", aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION TipoIdentEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un tipo de identificación", "Aviso")
      RETURN
   ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][3] + "?", "Confirmar")
      GuardarTipoIdentificacion(db, aData[nRow][1], aData[nRow][2], aData[nRow][3], .F.)
      aData := ObtenerTiposIdentificacion(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL
