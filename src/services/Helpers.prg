FUNCTION EsRespuestaHtml(cBody)
   LOCAL cTrim := LTrim(cBody)
   RETURN Left(cTrim, 9) == "<!DOCTYPE" .OR. ;
          Left(cTrim, 6) == "<html " .OR. ;
          Left(cTrim, 5) == "<html"

FUNCTION ValidarIBAN(cIban)
   LOCAL cLimpio, cRevisado, cNumerico, nI, nMod, nDig
   IF Empty(cIban)
      RETURN .T.
   ENDIF
   cLimpio := Upper(StrTran(StrTran(cIban, " ", ""), "-", ""))
   IF Len(cLimpio) < 8 .OR. Len(cLimpio) > 34
      RETURN .F.
   ENDIF
   cRevisado := SubStr(cLimpio, 5) + SubStr(cLimpio, 1, 4)
   cNumerico := ""
   FOR nI := 1 TO Len(cRevisado)
      nDig := Asc(SubStr(cRevisado, nI, 1))
      IF nDig >= 65 .AND. nDig <= 90
         cNumerico += LTrim(Str(nDig - 55))
      ELSEIF nDig >= 48 .AND. nDig <= 57
         cNumerico += Chr(nDig)
      ELSE
         RETURN .F.
      ENDIF
   NEXT
   nMod := 0
   FOR nI := 1 TO Len(cNumerico)
      nMod := (nMod * 10 + Val(SubStr(cNumerico, nI, 1))) % 97
   NEXT
   RETURN nMod == 1

FUNCTION MatchFilter(xValue, cFilter)
   IF Empty(cFilter)
      RETURN .T.
   ENDIF
   IF ValType(xValue) == "C"
      RETURN At(Upper(cFilter), Upper(xValue)) > 0
   ELSEIF ValType(xValue) == "L"
      IF cFilter == "1" .OR. Upper(cFilter) == "SI" .OR. Upper(cFilter) == "SÍ" .OR. Upper(cFilter) == "YES" .OR. Upper(cFilter) == "TRUE"
         RETURN xValue
      ELSEIF cFilter == "0" .OR. Upper(cFilter) == "NO" .OR. Upper(cFilter) == "FALSE"
         RETURN !xValue
      ENDIF
      RETURN .F.
   ELSEIF ValType(xValue) == "N"
      RETURN At(Upper(cFilter), Upper(LTrim(Str(xValue)))) > 0
   ELSEIF ValType(xValue) == "D"
      RETURN At(Upper(cFilter), Upper(DToC(xValue))) > 0
   ENDIF
   RETURN .F.

