#include "hwgui.ch"

FUNCTION ViesView(db)
   LOCAL oDlg
   LOCAL cCodPais := "ES", cVat := Space(15), aResult
   LOCAL aPaisesUE := ObtenerPaisesUE(db)
   LOCAL nPaisSel := 1

   INIT DIALOG oDlg TITLE "Validación VAT (VIES)" AT 0,0 SIZE 500, 200 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 20 SAY "País:" SIZE 80, 22
   @ 110, 18 COMBOBOX nPaisSel ITEMS ListaPaisUENombres(aPaisesUE) SIZE 150, 200

   @ 20, 55 SAY "Nº VAT:" SIZE 80, 22
   @ 110, 53 GET cVat SIZE 150, 26

   @ 150, 120 BUTTON "Consultar" SIZE 90, 28 ON CLICK {;
      aResult := ComprobarVat(aPaisesUE[nPaisSel][2], AllTrim(cVat)), ;
      Iif(aResult[1], ;
         hwg_MsgInfo("VÁLIDO" + Iif(!Empty(aResult[3]), hb_eol() + "Nombre: " + aResult[3], "") + Iif(!Empty(aResult[4]), hb_eol() + "Dirección: " + aResult[4], ""), "Resultado VIES"), ;
         hwg_MsgInfo("NO VÁLIDO" + Iif(!Empty(aResult[5]), hb_eol() + aResult[5], ""), "Resultado VIES")) ;
   }

   @ 280, 120 BUTTON "Cerrar" SIZE 90, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION ListaPaisUENombres(aPaises)
   LOCAL aN := {}, nI
   FOR nI := 1 TO Len(aPaises)
      AAdd(aN, aPaises[nI][3] + " (" + aPaises[nI][2] + ")")
   NEXT
   RETURN aN
