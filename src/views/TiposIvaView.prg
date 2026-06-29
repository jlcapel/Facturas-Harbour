#include "hwgui.ch"

FUNCTION TiposIvaView(db)
   LOCAL oDlg, oBrw, aData

   aData := ObtenerTiposIva(db)

   INIT DIALOG oDlg ;
      TITLE "Tipos de IVA" ;
      AT 0, 0 ;
      SIZE 600, 400 ;
      STYLE WS_POPUP + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 20, 20 BROWSE oBrw ARRAY SIZE 400, 300 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New("Nombre", {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New("% IVA", {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("Activo", {|v,o| (v), iif(o:aArray[o:nCurrent, 4], "Sí", "No")}, "C", 8, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New("Desde", {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 14, 0, .F., DT_CENTER))

   @ 30, 350 BUTTON "Nuevo" SIZE 70, 28 ON CLICK {|| TipoIvaNuevo(db, @aData, oBrw)}
   @ 110, 350 BUTTON "Editar" SIZE 70, 28 ON CLICK {|| TipoIvaEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 350 BUTTON "Eliminar" SIZE 70, 28 ON CLICK {|| TipoIvaEliminar(db, @aData, oBrw)}
   @ 270, 350 BUTTON "PDF" SIZE 50, 28 ON CLICK {|| ExportPdfTiposIva(db, aData)}
   @ 460, 350 BUTTON "Volver" SIZE 70, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION TipoIvaNuevo(db, aData, oBrw)
   LOCAL oDlg, cNombre := Space(30), cPorcentaje := Space(6), lCancel := .F.

   INIT DIALOG oDlg TITLE "Nuevo tipo de IVA" AT 0,0 SIZE 350, 180 STYLE DS_CENTER

   @ 20, 20 SAY "Nombre:" SIZE 80, 22
   @ 110, 18 GET cNombre SIZE 200, 26
   @ 20, 55 SAY "% IVA:" SIZE 80, 22
   @ 110, 53 GET cPorcentaje SIZE 100, 26 PICTURE "99.99"

   @ 80, 120 BUTTON "Guardar" SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 190, 120 BUTTON "Cancelar" SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel .AND. !Empty(cNombre)
      GuardarTipoIva(db, 0, AllTrim(cNombre), AllTrim(cPorcentaje), .T., DToS(Date()), NIL)
      aData := ObtenerTiposIva(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION TipoIvaEditar(db, aData, oBrw, nRow)
   LOCAL aTipo, oDlg, cNombre, cPorcentaje, lCancel := .F.

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un tipo de IVA", "Aviso")
      RETURN
   ENDIF

   aTipo := aData[nRow]
   cNombre := PadR(aTipo[2], 30)
   cPorcentaje := PadR(aTipo[3], 6)

   INIT DIALOG oDlg TITLE "Editar tipo de IVA" AT 0,0 SIZE 350, 180 STYLE DS_CENTER

   @ 20, 20 SAY "Nombre:" SIZE 80, 22
   @ 110, 18 GET cNombre SIZE 200, 26
   @ 20, 55 SAY "% IVA:" SIZE 80, 22
   @ 110, 53 GET cPorcentaje SIZE 100, 26 PICTURE "99.99"

   @ 80, 120 BUTTON "Guardar" SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 190, 120 BUTTON "Cancelar" SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel
      GuardarTipoIva(db, aTipo[1], AllTrim(cNombre), AllTrim(cPorcentaje), .T., aTipo[5], aTipo[6])
      aData := ObtenerTiposIva(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ExportPdfTiposIva(db, aData)
   LOCAL aCols := { ;
      {"Nombre", 200, 2}, ;
      {"% IVA", 80, 3, .T.}, ;
      {"Activo", 50, 4, .T.}, ;
      {"Desde", 120, 5} }
   LOCAL cPath := AbrirListadoPdf(db, "TiposIVA", aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, "Exportar"); ENDIF
RETURN NIL

STATIC FUNCTION TipoIvaEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un tipo de IVA", "Aviso")
      RETURN
   ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][2] + "?", "Confirmar")
      aData := ObtenerTiposIva(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL
