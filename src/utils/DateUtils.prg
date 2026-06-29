FUNCTION FechaDDMMYYYY(dFecha)
   RETURN PadL(Day(dFecha), 2, "0") + "-" + PadL(Month(dFecha), 2, "0") + "-" + Str(Year(dFecha), 4)

FUNCTION FechaISO8601(dFecha)
   RETURN Str(Year(dFecha), 4) + "-" + PadL(Month(dFecha), 2, "0") + "-" + PadL(Day(dFecha), 2, "0")

FUNCTION FechaISO8601ConTimeZone(dtDateTime)
   LOCAL cFecha, cTime
   cFecha := hb_TToC(dtDateTime, 2)
   cTime := hb_TToC(dtDateTime, 1)
   cTime := SubStr(cTime, 12)
   RETURN cFecha + "T" + cTime + "+01:00"

FUNCTION SqlDateToDate(cSqlDate)
   IF cSqlDate == NIL .OR. Len(cSqlDate) < 10
      RETURN CToD("")
   ENDIF
   RETURN hb_SToD(SubStr(cSqlDate, 1, 4) + SubStr(cSqlDate, 6, 2) + SubStr(cSqlDate, 9, 2))

FUNCTION SqlDateTimeToDateTime(cSqlDateTime)
   IF cSqlDateTime == NIL .OR. Len(cSqlDateTime) < 19
      RETURN hb_DateTime()
   ENDIF
   RETURN hb_DateTime(Val(SubStr(cSqlDateTime, 1, 4)), Val(SubStr(cSqlDateTime, 6, 2)), ;
      Val(SubStr(cSqlDateTime, 9, 2)), Val(SubStr(cSqlDateTime, 12, 2)), ;
      Val(SubStr(cSqlDateTime, 15, 2)), Val(SubStr(cSqlDateTime, 18, 2)))

FUNCTION DecimalAPunto(nValor)
   RETURN StrTran(Str(nValor, 12, 2), ",", ".")

FUNCTION DecimalAPuntoSinEspacios(nValor)
   RETURN AllTrim(StrTran(Str(nValor, 12, 2), ",", "."))

FUNCTION StripTrailingZeros(cValor)
   LOCAL nPos
   nPos := Rat(".", cValor)
   IF nPos > 0
      WHILE Right(cValor, 1) == "0"
         cValor := Left(cValor, Len(cValor) - 1)
      ENDDO
      IF Right(cValor, 1) == "."
         cValor := Left(cValor, Len(cValor) - 1)
      ENDIF
   ENDIF
   RETURN cValor
