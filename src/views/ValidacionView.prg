#include "hwgui.ch"

FUNCTION ValidacionView(db, oParent, nX, nY, nW, nH)
   LOCAL cNif := Space(15), cNombre := Space(50), aResult

   @ nX+20, nY+20 SAY L("ValidacionNifLabel") SIZE 120, 22 OF oParent
   @ nX+150, nY+18 GET cNif SIZE 150, 26 OF oParent

   @ nX+20, nY+55 SAY L("ValidacionNombreOpcional") SIZE 120, 22 OF oParent
   @ nX+150, nY+53 GET cNombre SIZE 250, 26 OF oParent

   @ nX+150, nY+120 BUTTON L("CommonConsultar") SIZE 90, 28 OF oParent ON CLICK {;
      aResult := ComprobarNif(db, AllTrim(cNif), AllTrim(cNombre)), ;
      Iif(aResult[1], ;
         hwg_MsgInfo(L("ValidacionValido") + aResult[2], L("ValidacionResultadoAeat")), ;
         hwg_MsgInfo(L("ValidacionError") + aResult[4], L("ValidacionResultadoAeat"))) ;
   }
RETURN NIL
