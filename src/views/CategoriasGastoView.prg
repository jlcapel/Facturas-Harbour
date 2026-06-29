#include "hwgui.ch"

FUNCTION CategoriasGastoView(db)
   LOCAL oDlg, oBrw, aData
   aData := ObtenerCategoriasGasto(db)
   INIT DIALOG oDlg TITLE "Categorías de gasto" AT 0,0 SIZE 650, 500 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER
   @ 20, 20 BROWSE oBrw ARRAY SIZE 480, 400 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL
   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New("Nombre", {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 28, 0))
   oBrw:AddColumn(HColumn():New("% Deducible IRPF", {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 16, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("IVA Deducible", {|v,o| (v), Iif(o:aArray[o:nCurrent, 4], "Sí", "No")}, "C", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New("Orden", {|v,o| (v), o:aArray[o:nCurrent, 5]}, "N", 6, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("Activo", {|v,o| (v), Iif(o:aArray[o:nCurrent, 6], "Sí", "No")}, "C", 8, 0, .F., DT_CENTER))
   @ 30, 440 BUTTON "Nuevo" SIZE 70, 28 ON CLICK {|| CatNuevo(db, @aData, oBrw)}
   @ 110, 440 BUTTON "Editar" SIZE 70, 28 ON CLICK {|| CatEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 440 BUTTON "Eliminar" SIZE 70, 28 ON CLICK {|| CatEliminar(db, @aData, oBrw)}
   @ 270, 440 BUTTON "PDF" SIZE 50, 28 ON CLICK {|| ExportPdfCategorias(db, aData)}
   @ 520, 440 BUTTON "Volver" SIZE 70, 28 ON CLICK {|| oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION CatNuevo(db, aData, oBrw)
   LOCAL aR := CatEditDialog(db, 0)
   IF aR != NIL
      GuardarCategoriaGasto(db, 0, aR[1], aR[2], aR[3], aR[4], .T.)
      aData := ObtenerCategoriasGasto(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION CatEditar(db, aData, oBrw, nRow)
   LOCAL aC, aR
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione una categoría", "Aviso"); RETURN; ENDIF
   aC := aData[nRow]
   aR := CatEditDialog(db, aC[1])
   IF aR != NIL
      GuardarCategoriaGasto(db, aC[1], aR[1], aR[2], aR[3], aR[4], .T.)
      aData := ObtenerCategoriasGasto(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ExportPdfCategorias(db, aData)
   LOCAL aCols := { ;
      {"Nombre", 200, 2}, ;
      {"% Deducible", 100, 3, .T.}, ;
      {"IVA Deduc.", 80, 4, .T.}, ;
      {"Orden", 50, 5, .T.}, ;
      {"Activo", 50, 6, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, "CategoriasGasto", aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, "Exportar"); ENDIF
RETURN NIL

STATIC FUNCTION CatEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione una categoría", "Aviso"); RETURN; ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][2] + "?", "Confirmar")
      EliminarCategoriaGasto(db, aData[nRow][1])
      aData := ObtenerCategoriasGasto(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION CatEditDialog(db, nId)
   LOCAL oDlg, lCancel := .F.
   LOCAL cNombre := Space(40), cPctDeducible := "15.00"
   LOCAL lIvaDeducible := .T., nOrden := 0
   LOCAL aCat

   IF nId != 0
      aCat := ObtenerCategoriaGastoPorId(db, nId)
      IF aCat != NIL
         cNombre := PadR(aCat[2], 40); cPctDeducible := PadR(aCat[3], 8)
         lIvaDeducible := aCat[4]; nOrden := aCat[5]
      ENDIF
   ENDIF

   INIT DIALOG oDlg TITLE Iif(nId==0, "Nueva categoría", "Editar categoría") AT 0,0 SIZE 400, 200 STYLE DS_CENTER
   @ 20, 15 SAY "Nombre:" SIZE 80, 22
   @ 110, 13 GET cNombre SIZE 260, 26
   @ 20, 48 SAY "% Deducible IRPF:" SIZE 120, 22
   @ 140, 46 GET cPctDeducible SIZE 80, 26
   @ 140, 79 CHECKBOX lIvaDeducible CAPTION "IVA Deducible" SIZE 130, 26
   @ 100, 150 BUTTON "Guardar" SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 220, 150 BUTTON "Cancelar" SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
   IF lCancel; RETURN NIL; ENDIF
   RETURN { AllTrim(cNombre), AllTrim(cPctDeducible), lIvaDeducible, nOrden }
