FUNCTION L(cKey)
   RETURN LocalizationGet(cKey)

FUNCTION LocalizationNew()
   PUBLIC oLoc := {=>}
   oLoc["hStrings"] := {=>}
   oLoc["cLang"] := "es"
   LocalizationLoad("es")
   LocalizationLoad("en")
   LocalizationLoad("fr")
   LocalizationLoad("ca")
   LocalizationLoad("eu")
   oLoc["hFallback"] := oLoc["hStrings"]["es"]
RETURN NIL

FUNCTION LocalizationGet(cKey)
   LOCAL h := NIL
   IF hb_HHasKey(oLoc["hStrings"], oLoc["cLang"])
      h := oLoc["hStrings"][oLoc["cLang"]]
      IF hb_HHasKey(h, cKey)
         RETURN h[cKey]
      ENDIF
   ENDIF
   IF hb_HHasKey(oLoc["hFallback"], cKey)
      RETURN oLoc["hFallback"][cKey]
   ENDIF
   RETURN "[[" + cKey + "]]"

FUNCTION LocalizationSetLang(cCode)
   IF hb_HHasKey(oLoc["hStrings"], cCode)
      oLoc["cLang"] := cCode
   ENDIF
RETURN NIL

FUNCTION LocalizationLoad(cCode)
   LOCAL h := NIL
   SWITCH cCode
   CASE "es"; h := LoadStrings_es()
   CASE "en"; h := LoadStrings_en()
   CASE "fr"; h := LoadStrings_fr()
   CASE "ca"; h := LoadStrings_ca()
   CASE "eu"; h := LoadStrings_eu()
   ENDSWITCH
   IF h != NIL
      oLoc["hStrings"][cCode] := h
   ENDIF
RETURN NIL

