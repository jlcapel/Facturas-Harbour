FUNCTION ValidarIdentificacion(cId, cCodigoTipo, cPais)
   LOCAL cLetrasDNI := "TRWAGMYFPDXBNJZSQVHLCKE"

   IF Empty(cId) .OR. Len(cId) < 3
      RETURN { .F., L("ValidationIdentCorta") }
   ENDIF
   cId := Upper(AllTrim(cId))

   DO CASE
   CASE cCodigoTipo == "01"
      RETURN ValidarNIF(cId, @cLetrasDNI)
   CASE cCodigoTipo == "02"
      RETURN ValidarNIFIVA(cId, cPais)
   CASE cCodigoTipo == "03"
      RETURN { .T., "" }
   CASE cCodigoTipo == "04"
      RETURN { .T., "" }
   CASE cCodigoTipo == "05"
      RETURN { .T., "" }
   CASE cCodigoTipo == "06"
      RETURN { .T., "" }
   OTHERWISE
      RETURN { .F., L("ValidationIdentNoSoportado") }
   ENDCASE
RETURN { .F., L("ValidationIdentNoSoportado") }

STATIC FUNCTION ValidarNIF(cId, cLetrasDNI)
   LOCAL cLetra, nNum, cPref
   IF hb_RegexLike(cId, "^[0-9]{8}[A-Z]$")
      nNum := Val(Left(cId, 8))
      cLetra := SubStr(cLetrasDNI, (nNum % 23) + 1, 1)
      IF Right(cId, 1) == cLetra
         RETURN { .T., "" }
      ELSE
         RETURN { .F., StrTran(L("ValidationDniLetra"), "{0}", cLetra) }
      ENDIF
   ENDIF
   IF hb_RegexLike(cId, "^[XYZ][0-9]{7}[A-Z]$")
      cPref := Iif(Left(cId, 1) == "X", "0", Iif(Left(cId, 1) == "Y", "1", "2"))
      nNum = Val(cPref + SubStr(cId, 2, 7))
      cLetra := SubStr(cLetrasDNI, (nNum % 23) + 1, 1)
      IF Right(cId, 1) == cLetra
         RETURN { .T., "" }
      ELSE
         RETURN { .F., StrTran(L("ValidationNieLetra"), "{0}", cLetra) }
      ENDIF
   ENDIF
   IF hb_RegexLike(cId, "^[ABCDEFGHJNPQRSUVW][0-9]{7}[0-9A-J]$")
      RETURN ValidarCIF(cId)
   ENDIF
   RETURN { .F., L("ValidationFormatoIdent") }

STATIC FUNCTION ValidarCIF(cId)
   LOCAL aDig := {}, nPares := 0, nImpares := 0, nSuma, nDecSup, nCtrlEsp
   LOCAL cCtrlReal, cLetrasCIF := "JABCDEFGHI", nI, nD, nDoble
   FOR nI := 2 TO 8
      AAdd(aDig, Val(SubStr(cId, nI, 1)))
   NEXT
   nPares := aDig[2] + aDig[4] + aDig[6]
   FOR nI := 1 TO 7 STEP 2
      nDoble := aDig[nI] * 2
      nImpares += Iif(nDoble >= 10, nDoble - 9, nDoble)
   NEXT
   nSuma := nPares + nImpares
   nDecSup := (Int(nSuma / 10) + Iif(nSuma % 10 == 0, 0, 1)) * 10
   nCtrlEsp := nDecSup - nSuma
   cCtrlReal := Right(cId, 1)
   IF hb_RegexLike(cCtrlReal, "[0-9]")
      IF Val(cCtrlReal) == nCtrlEsp % 10
         RETURN { .T., "" }
      ELSE
         RETURN { .F., StrTran(L("ValidationIdentControlDigito"), "{0}", hb_ntos(nCtrlEsp % 10)) }
      ENDIF
   ELSE
      IF cCtrlReal == SubStr(cLetrasCIF, (nCtrlEsp % 10) + 1, 1)
         RETURN { .T., "" }
      ELSE
         RETURN { .F., StrTran(L("ValidationIdentControlLetra"), "{0}", SubStr(cLetrasCIF, (nCtrlEsp % 10) + 1, 1)) }
      ENDIF
   ENDIF
RETURN { .F., L("ValidationFormatoIdent") }

STATIC FUNCTION ValidarNIFIVA(cId, cPais)
   LOCAL cPrefijo, cNumero
   IF Len(cId) < 4
      RETURN { .F., L("ValidationNifIvaMin") }
   ENDIF
   cPrefijo := Left(cId, 2)
   cNumero := SubStr(cId, 3)
   IF !Empty(cPais) .AND. cPrefijo != cPais
      RETURN { .F., StrTran(StrTran(L("ValidationNifIvaPrefijo"), "{0}", cPais), "{1}", cPrefijo) }
   ENDIF
   DO CASE
   CASE cPrefijo == "AT"
      RETURN Iif(Left(cNumero, 1) == "U" .AND. Len(cNumero) == 9 .AND. hb_RegexLike(SubStr(cNumero, 2), "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtAT") })
   CASE cPrefijo == "BE"
      RETURN Iif(Len(cNumero) == 10 .AND. hb_RegexLike(cNumero, "^0[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtBE") })
   CASE cPrefijo == "BG"
      RETURN Iif((Len(cNumero) == 9 .OR. Len(cNumero) == 10) .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtBG") })
   CASE cPrefijo == "HR"
      RETURN Iif(Len(cNumero) == 11 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtHR") })
   CASE cPrefijo == "CY"
      RETURN Iif(Len(cNumero) == 9 .AND. hb_RegexLike(Left(cNumero, 8), "^[0-9]+$") .AND. hb_RegexLike(Right(cNumero, 1), "^[A-Z]$"), { .T., "" }, { .F., L("ValidationVatFmtCY") })
   CASE cPrefijo == "CZ"
      RETURN Iif(Len(cNumero) >= 8 .AND. Len(cNumero) <= 10 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtCZ") })
   CASE cPrefijo == "DK"
      RETURN Iif(Len(cNumero) == 8 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtDK") })
   CASE cPrefijo == "EE"
      RETURN Iif(Len(cNumero) == 9 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtEE") })
   CASE cPrefijo == "FI"
      RETURN Iif(Len(cNumero) == 8 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtFI") })
   CASE cPrefijo == "FR"
      RETURN Iif(Len(cNumero) == 11 .AND. hb_RegexLike(cNumero, "^[A-Za-z]{2}[0-9]{9}$") .AND. At("O", Left(cNumero, 2)) == 0 .AND. At("I", Left(cNumero, 2)) == 0, { .T., "" }, { .F., L("ValidationVatFmtFR") })
   CASE cPrefijo == "DE"
      RETURN Iif(Len(cNumero) == 9 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtDE") })
   CASE cPrefijo == "EL"
      RETURN Iif(Len(cNumero) == 9 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtEL") })
   CASE cPrefijo == "HU"
      RETURN Iif(Len(cNumero) == 8 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtHU") })
   CASE cPrefijo == "IE"
      IF Len(cNumero) == 8 .AND. hb_RegexLike(Left(cNumero, 7), "^[0-9]+$") .AND. hb_RegexLike(Right(cNumero, 1), "^[A-Z]$"); RETURN { .T., "" }; ENDIF
      IF Len(cNumero) == 9 .AND. hb_RegexLike(Left(cNumero, 7), "^[0-9]+$") .AND. hb_RegexLike(Right(cNumero, 1), "^[A-Z]$"); RETURN { .T., "" }; ENDIF
      RETURN { .F., L("ValidationVatFmtIE") }
   CASE cPrefijo == "IT"
      RETURN Iif(Len(cNumero) == 11 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtIT") })
   CASE cPrefijo == "LV"
      RETURN Iif(Len(cNumero) == 11 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtLV") })
   CASE cPrefijo == "LT"
      RETURN Iif((Len(cNumero) == 9 .OR. Len(cNumero) == 12) .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtLT") })
   CASE cPrefijo == "LU"
      RETURN Iif(Len(cNumero) == 8 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtLU") })
   CASE cPrefijo == "MT"
      RETURN Iif(Len(cNumero) == 8 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtMT") })
   CASE cPrefijo == "NL"
      RETURN Iif(Len(cNumero) == 12 .AND. hb_RegexLike(Left(cNumero, 9), "^[0-9]+$") .AND. SubStr(cNumero, 10, 1) == "B" .AND. hb_RegexLike(SubStr(cNumero, 11), "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtNL") })
   CASE cPrefijo == "PL"
      RETURN Iif(Len(cNumero) == 10 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtPL") })
   CASE cPrefijo == "PT"
      RETURN Iif(Len(cNumero) == 9 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtPT") })
   CASE cPrefijo == "RO"
      RETURN Iif(Len(cNumero) >= 2 .AND. Len(cNumero) <= 10 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtRO") })
   CASE cPrefijo == "SK"
      RETURN Iif(Len(cNumero) == 10 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtSK") })
   CASE cPrefijo == "SI"
      RETURN Iif(Len(cNumero) == 8 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtSI") })
   CASE cPrefijo == "ES"
      RETURN ValidarNIF(cNumero, "TRWAGMYFPDXBNJZSQVHLCKE")
   CASE cPrefijo == "SE"
      RETURN Iif(Len(cNumero) == 12 .AND. hb_RegexLike(cNumero, "^[0-9]+$"), { .T., "" }, { .F., L("ValidationVatFmtSE") })
   CASE cPrefijo == "GB"
      RETURN Iif((Len(cNumero) == 9 .AND. hb_RegexLike(cNumero, "^[0-9]+$")) .OR. Len(cNumero) == 12, { .T., "" }, { .F., L("ValidationVatFmtGB") })
   OTHERWISE
      RETURN { .F., StrTran(L("ValidationVatPrefijoNoReconocido"), "{0}", cPrefijo) }
   ENDCASE
RETURN { .F., L("ValidationFormatoIdent") }
