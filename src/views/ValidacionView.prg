#include "hwgui.ch"

FUNCTION ValidacionView(db)
   LOCAL oDlg
   LOCAL cNif := Space(15), cNombre := Space(50), aResult

   INIT DIALOG oDlg TITLE "Validación NIF (AEAT VNifV2)" AT 0,0 SIZE 500, 200 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 20 SAY "NIF a consultar:" SIZE 120, 22
   @ 150, 18 GET cNif SIZE 150, 26

   @ 20, 55 SAY "Nombre (opcional):" SIZE 120, 22
   @ 150, 53 GET cNombre SIZE 250, 26

   @ 150, 120 BUTTON "Consultar" SIZE 90, 28 ON CLICK {;
      aResult := ComprobarNif(db, AllTrim(cNif), AllTrim(cNombre)), ;
      Iif(aResult[1], ;
         hwg_MsgInfo("VÁLIDO: " + aResult[2], "Resultado AEAT"), ;
         hwg_MsgInfo("ERROR: " + aResult[4], "Resultado AEAT")) ;
   }

   @ 280, 120 BUTTON L("CommonCerrar") SIZE 90, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL
