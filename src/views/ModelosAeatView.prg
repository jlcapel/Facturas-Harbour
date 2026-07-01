REQUEST HB_RUN

#include "hwgui.ch"

FUNCTION ModelosAeatView(db, oParent, nX, nY, nW, nH)
   LOCAL nModelo := 1, cSum := ""
   LOCAL nAnio := Year(Date()), aAnios := {}, nI
   LOCAL nAnioIdx := 1, nTrim := 1
   LOCAL oCbAnio, oCbTrim

   FOR nI := nAnio - 5 TO nAnio
      AAdd(aAnios, nI)
   NEXT
   nAnioIdx := Len(aAnios)

   @ nX+20, nY+20 SAY "Modelos AEAT - Seleccione modelo:" SIZE 300, 22 OF oParent

   @ nX+20, nY+50 BUTTON L("Modelo303Title") SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 1}
   @ nX+250, nY+50 BUTTON "Modelo 390 - IVA Resumen Anual" SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 2}
   @ nX+20, nY+85 BUTTON "Modelo 130 - IRPF Estimación Directa" SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 3}
   @ nX+250, nY+85 BUTTON "Modelo 347 - Operaciones Terceros" SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 4}
   @ nX+20, nY+120 BUTTON "Modelo 111 - IRPF Retenciones" SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 5}
   @ nX+250, nY+120 BUTTON "Modelo 115 - IRPF Alquiler" SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 6}
   @ nX+20, nY+155 BUTTON L("Modelo349Title") SIZE 220, 28 OF oParent ON CLICK {|| nModelo := 7}

   @ nX+20, nY+200 SAY L("M111Ejercicio") SIZE 80, 22 OF oParent
   @ nX+100, nY+197 GET COMBOBOX oCbAnio VAR nAnioIdx ITEMS aAnios SIZE 100, 200 OF oParent

   @ nX+220, nY+200 SAY L("M111Trimestre") SIZE 80, 22 OF oParent
   @ nX+300, nY+197 GET COMBOBOX oCbTrim VAR nTrim ITEMS {1, 2, 3, 4} SIZE 80, 200 OF oParent

   @ nX+20, nY+240 BUTTON L("CommonGenerar") SIZE 100, 30 OF oParent ON CLICK {|| ;
      GenerarModeloAeat(db, nModelo, aAnios[nAnioIdx], nTrim) }

   @ nX+140, nY+240 BUTTON "Abrir Carpeta" SIZE 100, 30 OF oParent ON CLICK {|| AbrirCarpetaModelo(nModelo) }
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
