#include "hwgui.ch"

FUNCTION ValidacionView(db)
   LOCAL oDlg
   LOCAL cNif := Space(15), cNombre := Space(50), aResult
   LOCAL cResultTxt := "", lOk := .F.

   INIT DIALOG oDlg TITLE "Validación NIF (AEAT VNifV2)" AT 0,0 SIZE 500, 300 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 20 SAY "NIF a consultar:" SIZE 120, 22
   @ 150, 18 GET cNif SIZE 150, 26

   @ 20, 55 SAY "Nombre (opcional):" SIZE 120, 22
   @ 150, 53 GET cNombre SIZE 250, 26

   @ 20, 100 SAY "Resultado:" SIZE 80, 22
   @ 20, 125 SAY cResultTxt SIZE 450, 60

   @ 150, 220 BUTTON "Consultar" SIZE 90, 28 ON CLICK {;
      aResult := ComprobarNif(db, AllTrim(cNif), AllTrim(cNombre)), ;
      lOk := aResult[1], ;
      cResultTxt := Iif(lOk, "VÁLIDO: " + aResult[2], "ERROR: " + aResult[4]), ;
      hwg_RedrawWindow(oDlg:handle, 1) ;
   }

   @ 280, 220 BUTTON "Cerrar" SIZE 90, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL
