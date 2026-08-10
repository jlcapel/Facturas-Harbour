#include "hwgui.ch"

FUNCTION ViesView(db, oParent, nX, nY, nW, nH)
   LOCAL cCodPais := "ES", cVat := Space(15), aResult
   LOCAL aPaisesUE := ObtenerPaisesUE(db)
   LOCAL nPaisSel := 1

   @ nX+20, nY+20 SAY L("ClientesPais") SIZE 80, 22 OF oParent
   @ nX+110, nY+18 GET COMBOBOX nPaisSel ITEMS ListaPaisUENombres(aPaisesUE) SIZE 150, 200 OF oParent

   @ nX+20, nY+55 SAY L("ViesVatLabel") SIZE 80, 22 OF oParent
   @ nX+110, nY+53 GET cVat SIZE 150, 26 OF oParent

   @ nX+150, nY+120 BUTTON L("CommonConsultar") SIZE 90, 28 OF oParent ON CLICK {;
      aResult := ComprobarVat(aPaisesUE[nPaisSel][2], AllTrim(cVat)), ;
      Iif(aResult[1], ;
         hwg_MsgInfo(L("ViesValido") + Iif(!Empty(aResult[3]), hb_eol() + L("ViesNombre") + aResult[3], "") + Iif(!Empty(aResult[4]), hb_eol() + L("ViesDireccion") + aResult[4], ""), L("ViesResultado")), ;
         hwg_MsgInfo(L("ViesNoValido") + Iif(!Empty(aResult[5]), hb_eol() + aResult[5], ""), L("ViesResultado"))) ;
   }
RETURN NIL

STATIC FUNCTION ListaPaisUENombres(aPaises)
   LOCAL aN := {}, nI
   FOR nI := 1 TO Len(aPaises)
      AAdd(aN, aPaises[nI][3] + " (" + aPaises[nI][2] + ")")
   NEXT
   RETURN aN
