REQUEST HB_RUN

#include "hwgui.ch"

FUNCTION ModelosAeatView(db)
   LOCAL oDlg, nModelo := 1, cSum := ""
   LOCAL nAnio := Year(Date()), aAnios := {}, nI
   LOCAL nAnioIdx := 1, nTrim := 1
   LOCAL oCbAnio, oCbTrim, oTexto

   FOR nI := nAnio - 5 TO nAnio
      AAdd(aAnios, nI)
   NEXT
   nAnioIdx := Len(aAnios)

   INIT DIALOG oDlg TITLE L("ModelosAeatTitle") AT 0,0 SIZE 700, 500 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 20 SAY "Modelos AEAT - Seleccione modelo:" SIZE 300, 22

   @ 20, 50 BUTTON L("Modelo303Title") SIZE 220, 28 ON CLICK {|| nModelo := 1}
   @ 250, 50 BUTTON "Modelo 390 - IVA Resumen Anual" SIZE 220, 28 ON CLICK {|| nModelo := 2}
   @ 20, 85 BUTTON "Modelo 130 - IRPF Estimación Directa" SIZE 220, 28 ON CLICK {|| nModelo := 3}
   @ 250, 85 BUTTON "Modelo 347 - Operaciones Terceros" SIZE 220, 28 ON CLICK {|| nModelo := 4}
   @ 20, 120 BUTTON "Modelo 111 - IRPF Retenciones" SIZE 220, 28 ON CLICK {|| nModelo := 5}
   @ 250, 120 BUTTON "Modelo 115 - IRPF Alquiler" SIZE 220, 28 ON CLICK {|| nModelo := 6}
   @ 20, 155 BUTTON L("Modelo349Title") SIZE 220, 28 ON CLICK {|| nModelo := 7}

   @ 20, 200 SAY L("M111Ejercicio") SIZE 80, 22
   @ 100, 197 GET COMBOBOX oCbAnio VAR nAnioIdx ITEMS aAnios SIZE 100, 200

   @ 220, 200 SAY L("M111Trimestre") SIZE 80, 22
   @ 300, 197 GET COMBOBOX oCbTrim VAR nTrim ITEMS {1, 2, 3, 4} SIZE 80, 200

   @ 20, 240 BUTTON L("CommonGenerar") SIZE 100, 30 ON CLICK {|| ;
      GenerarModeloAeat(db, nModelo, aAnios[nAnioIdx], nTrim) }

   @ 140, 240 BUTTON "Abrir Carpeta" SIZE 100, 30 ON CLICK {|| AbrirCarpetaModelo(nModelo) }

   @ 600, 440 BUTTON L("ModelosAeatVolver") SIZE 70, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION GenerarModeloAeat(db, nModelo, nAnio, nTrim)
   LOCAL aRes, cText := "", nI
   SWITCH nModelo
   CASE 1; aRes := GenerarModelo303(db, nAnio, nTrim); EXIT
   CASE 2; aRes := GenerarModelo390(db, nAnio); EXIT
   CASE 3; aRes := GenerarModelo130(db, nAnio, nTrim); EXIT
   CASE 4; aRes := GenerarModelo347(db, nAnio); EXIT
   CASE 5; aRes := GenerarModelo111(db, nAnio, nTrim); EXIT
   CASE 6; aRes := GenerarModelo115(db, nAnio, nTrim); EXIT
   CASE 7; aRes := GenerarModelo349(db, nAnio); EXIT
   ENDSWITCH
   IF aRes == NIL
      hwg_MsgInfo("No hay datos para el período seleccionado.", "Modelo AEAT")
      RETURN .F.
   ENDIF
   FOR nI := 1 TO Len(aRes) STEP 2
      cText += aRes[nI] + ": " + hb_CStr(aRes[nI + 1]) + Chr(13) + Chr(10)
   NEXT
   hwg_MsgInfo(cText, L("Mode130Resultado"))
   RETURN .T.

STATIC FUNCTION AbrirCarpetaModelo(nModelo)
   LOCAL cDir
   SWITCH nModelo
   CASE 1; cDir := "modelos303"; EXIT
   CASE 2; cDir := "modelos390"; EXIT
   CASE 3; cDir := "modelos130"; EXIT
   CASE 4; cDir := "modelos347"; EXIT
   CASE 5; cDir := "modelos111"; EXIT
   CASE 6; cDir := "modelos115"; EXIT
   CASE 7; cDir := "modelos349"; EXIT
   ENDSWITCH
   hb_Run("xdg-open " + hb_GetEnv("HOME") + "/Facturas/" + cDir + " 2>/dev/null &")
RETURN NIL
