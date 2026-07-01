#include "hwgui.ch"

FUNCTION ValidacionView(db, oParent, nX, nY, nW, nH)
   LOCAL cNif := Space(15), cNombre := Space(50), aResult

   @ nX+20, nY+20 SAY "NIF a consultar:" SIZE 120, 22 OF oParent
   @ nX+150, nY+18 GET cNif SIZE 150, 26 OF oParent

   @ nX+20, nY+55 SAY "Nombre (opcional):" SIZE 120, 22 OF oParent
   @ nX+150, nY+53 GET cNombre SIZE 250, 26 OF oParent

   @ nX+150, nY+120 BUTTON "Consultar" SIZE 90, 28 OF oParent ON CLICK {;
      aResult := ComprobarNif(db, AllTrim(cNif), AllTrim(cNombre)), ;
      Iif(aResult[1], ;
         hwg_MsgInfo("VÁLIDO: " + aResult[2], "Resultado AEAT"), ;
         hwg_MsgInfo("ERROR: " + aResult[4], "Resultado AEAT")) ;
   }
RETURN NIL
