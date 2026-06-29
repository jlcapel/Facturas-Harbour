FUNCTION ObtenerNumericConfig(db)
   LOCAL aConfig := { ;
      {"AmountDecimals", "2"}, ;
      {"PercentDecimals", "2"}, ;
      {"QuantityDecimals", "2"}, ;
      {"PriceDecimals", "2"}, ;
      {"ThousandSeparator", "0"}, ;
      {"DecimalSeparator", ","}, ;
      {"RoundingMode", "1"}, ;
      {"LineDiscountsEnabled", "0"}, ;
      {"GlobalDiscountsEnabled", "0"}, ;
      {"DiscountType", "Percent"} }
   LOCAL nI, cVal
   FOR nI := 1 TO Len(aConfig)
      cVal := ObtenerConfiguracion(db, "Numeric." + aConfig[nI][1])
      IF cVal != NIL
         aConfig[nI][2] := cVal
      ENDIF
   NEXT
   RETURN aConfig

FUNCTION GuardarNumericConfig(db, aConfig)
   LOCAL nI
   FOR nI := 1 TO Len(aConfig)
      EstablecerConfiguracion(db, "Numeric." + aConfig[nI][1], aConfig[nI][2])
   NEXT
RETURN .T.

FUNCTION ObtenerNumericInt(db, cKey, nDef)
   LOCAL cVal := ObtenerConfiguracion(db, "Numeric." + cKey)
   IF cVal == NIL
      RETURN nDef
   ENDIF
   RETURN Val(cVal)

FUNCTION ObtenerNumericDec(db, cKey, nDef)
   LOCAL cVal := ObtenerConfiguracion(db, "Numeric." + cKey)
   IF cVal == NIL
      RETURN nDef
   ENDIF
   RETURN Val(cVal)

FUNCTION ObtenerNumericStr(db, cKey, cDef)
   LOCAL cVal := ObtenerConfiguracion(db, "Numeric." + cKey)
   IF cVal == NIL
      RETURN cDef
   ENDIF
   RETURN cVal

FUNCTION ObtenerNumericBool(db, cKey, lDef)
   LOCAL cVal := ObtenerConfiguracion(db, "Numeric." + cKey)
   IF cVal == NIL
      RETURN lDef
   ENDIF
   RETURN cVal == "1" .OR. Upper(cVal) == ".T." .OR. Upper(cVal) == "TRUE"
