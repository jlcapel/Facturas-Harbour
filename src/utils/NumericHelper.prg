FUNCTION RoundDefault(nValor, nDecimals)
   IF nDecimals == NIL; nDecimals := 2; ENDIF
   RETURN Round(nValor, nDecimals)

FUNCTION RoundFiscal(nValor)
   RETURN Round(nValor, 2)

FUNCTION CalcularImporteLinea(nCantidad, nPrecio, nDescPorc, nDescImp)
   LOCAL nBase := nCantidad * nPrecio
   IF nDescPorc != NIL .AND. nDescPorc != 0
      nBase := nBase * (1 - nDescPorc / 100)
   ENDIF
   IF nDescImp != NIL .AND. nDescImp != 0
      nBase := nBase - nDescImp
   ENDIF
   RETURN Round(nBase, 2)

FUNCTION CalcularIvaLinea(nImporte, nIvaPorc)
   RETURN Round(nImporte * nIvaPorc / 100, 2)

FUNCTION FormatAmount(nValor)
   RETURN StrTran(Str(nValor, 12, 2), ".", ",")

FUNCTION FormatPercent(nValor)
   RETURN StrTran(Str(nValor, 6, 2), ".", ",") + "%"

FUNCTION FormatQuantity(nValor)
   RETURN StrTran(Str(nValor, 12, 2), ".", ",")

FUNCTION FormatPrice(nValor)
   RETURN StrTran(Str(nValor, 12, 2), ".", ",")
