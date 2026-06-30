#include "hwgui.ch"

FUNCTION BienesInversionView(db)
   LOCAL oDlg, oBrw, aData
   aData := ObtenerBienesInversion(db)
   INIT DIALOG oDlg TITLE "Bienes de inversión" AT 0,0 SIZE 900, 500 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER
   @ 20, 20 BROWSE oBrw ARRAY SIZE 700, 400 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL
   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("BienesNombre"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 22, 0))
   oBrw:AddColumn(HColumn():New(L("BienesFechaAdq"), {|v,o| (v), DToC(o:aArray[o:nCurrent, 3])}, "D", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New("Valor Adq.", {|v,o| (v), Str(o:aArray[o:nCurrent, 4], 10, 2)}, "N", 12, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("BienesPctUso"), {|v,o| (v), Str(o:aArray[o:nCurrent, 5], 6, 2)}, "N", 8, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("BienesAmortAnual"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "N", 12, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("V.Amortizado", {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 10, 2)}, "N", 12, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("V.Neto", {|v,o| (v), Str(o:aArray[o:nCurrent, 8], 10, 2)}, "N", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New("En uso", {|v,o| (v), Iif(o:aArray[o:nCurrent, 11], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))
   @ 30, 440 BUTTON L("BienesNuevo") SIZE 70, 28 ON CLICK {|| BienNuevo(db, @aData, oBrw)}
   @ 110, 440 BUTTON L("BienesEditar") SIZE 70, 28 ON CLICK {|| BienEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 440 BUTTON L("CommonEliminar") SIZE 70, 28 ON CLICK {|| BienEliminar(db, @aData, oBrw)}
   @ 270, 440 BUTTON "PDF" SIZE 50, 28 ON CLICK {|| ExportPdfBienes(db, aData)}
   @ 740, 440 BUTTON L("BienesVolver") SIZE 70, 28 ON CLICK {|| oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION BienNuevo(db, aData, oBrw)
   LOCAL aR := BienEditDialog(db, 0)
   IF aR != NIL
      GuardarBienInversion(db, 0, aR[1], aR[2], aR[3], aR[4], aR[5], aR[6], aR[7], aR[8], aR[9], .T., aR[10])
      aData := ObtenerBienesInversion(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION BienEditar(db, aData, oBrw, nRow)
   LOCAL aB, aR
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un bien", "Aviso"); RETURN; ENDIF
   aB := aData[nRow]
   aR := BienEditDialog(db, aB[1])
   IF aR != NIL
      GuardarBienInversion(db, aB[1], aR[1], aR[2], aR[3], aR[4], aR[5], aR[6], aR[7], aR[8], aR[9], .T., aR[10])
      aData := ObtenerBienesInversion(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ExportPdfBienes(db, aData)
   LOCAL aCols := { ;
      {L("BienesNombre"), 180, 2}, ;
      {"FechaAdq.", 90, 3}, ;
      {"ValorAdq.", 80, 4, .T.}, ;
      {"%Uso", 50, 5, .T.}, ;
      {"Amort.Anual", 80, 6, .T.}, ;
      {"V.Amortiz.", 80, 7, .T.}, ;
      {"V.Neto", 70, 8, .T.}, ;
      {"EnUso", 50, 11, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, "BienesInversion", aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION BienEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un bien", "Aviso"); RETURN; ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][2] + "?", "Confirmar")
      EliminarBienInversion(db, aData[nRow][1])
      aData := ObtenerBienesInversion(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION BienEditDialog(db, nId)
   LOCAL oDlg, lCancel := .F.
   LOCAL cNombre := Space(50), dFechaAdq := Date(), nValorAdq := 0.00, nPctUso := 100.00
   LOCAL nAmortAnual := 0.00, nValorAmort := 0.00, nValorNeto := 0.00
   LOCAL cCategoria := Space(30), dFechaIniAmort := Date(), dFechaBaja := CToD("")
   LOCAL aBien

   IF nId != 0
      aBien := ObtenerBienInversionPorId(db, nId)
      IF aBien != NIL
         cNombre := PadR(aBien[2], 50)
         IF !Empty(aBien[3]); dFechaAdq := CToD(aBien[3]); ENDIF
         nValorAdq := Val(aBien[4]); nPctUso := Val(aBien[5]); nAmortAnual := Val(aBien[6])
         nValorAmort := Val(aBien[7]); nValorNeto := Val(aBien[8])
         cCategoria := PadR(aBien[9], 30)
         IF !Empty(aBien[10]); dFechaIniAmort := CToD(aBien[10]); ENDIF
         IF !Empty(aBien[12]); dFechaBaja := CToD(aBien[12]); ENDIF
      ENDIF
   ENDIF

   INIT DIALOG oDlg TITLE Iif(nId==0, "Nuevo bien", "Editar bien") AT 0,0 SIZE 520, 380 STYLE DS_CENTER
   @ 20, 15 SAY L("BienesNombreLabel") SIZE 80, 22; @ 110, 13 GET cNombre SIZE 370, 26
   @ 20, 48 SAY "Fecha adquisición:" SIZE 120, 22; @ 140, 46 GET dFechaAdq SIZE 120, 26
   @ 20, 81 SAY "Valor adquisición:" SIZE 120, 22; @ 140, 79 GET nValorAdq PICTURE "9999999.99" SIZE 120, 26
   @ 20, 114 SAY "% Uso actividad:" SIZE 120, 22; @ 140, 112 GET nPctUso PICTURE "999.99" SIZE 100, 26
   @ 20, 147 SAY L("BienesCategoria") SIZE 80, 22; @ 110, 145 GET cCategoria SIZE 200, 26
   @ 20, 180 SAY "Amort. anual:" SIZE 100, 22; @ 140, 178 GET nAmortAnual PICTURE "9999999.99" SIZE 120, 26
   @ 300, 180 SAY "V.Amortizado:" SIZE 100, 22; @ 400, 178 GET nValorAmort PICTURE "9999999.99" SIZE 100, 26
   @ 20, 213 SAY "V.Neto contable:" SIZE 120, 22; @ 140, 211 GET nValorNeto PICTURE "9999999.99" SIZE 120, 26
   @ 20, 246 SAY "Inicio amort.:" SIZE 100, 22; @ 140, 244 GET dFechaIniAmort SIZE 120, 26
   @ 300, 246 SAY "Fecha baja:" SIZE 100, 22; @ 400, 244 GET dFechaBaja SIZE 100, 26
   @ 140, 330 BUTTON L("BienesGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 280, 330 BUTTON L("BienesCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
   IF lCancel; RETURN NIL; ENDIF
   RETURN { AllTrim(cNombre), dFechaAdq, nValorAdq, nPctUso, nAmortAnual, nValorAmort, nValorNeto, ;
      Iif(Empty(cCategoria), NIL, AllTrim(cCategoria)), dFechaIniAmort, ;
      Iif(Empty(dFechaBaja), NIL, dFechaBaja) }
