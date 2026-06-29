FUNCTION LogError(cCaller, cMsg)
   LOCAL cLogDir := ObtenerLogDir(), cPath, hFile
   hb_DirBuild(cLogDir)
   cPath := cLogDir + "/error.log"
   hFile := FOpen(cPath, FO_WRITE + FO_APPEND)
   IF hFile != -1
      FWrite(hFile, "[" + hb_TToC(hb_DateTime(), 2) + "] ERROR en " + cCaller + ": " + cMsg + hb_eol())
      FClose(hFile)
   ENDIF
RETURN NIL

FUNCTION LogInfo(cMsg)
   LOCAL cLogDir := ObtenerLogDir(), cPath, hFile
   hb_DirBuild(cLogDir)
   cPath := cLogDir + "/error.log"
   hFile := FOpen(cPath, FO_WRITE + FO_APPEND)
   IF hFile != -1
      FWrite(hFile, "[" + hb_TToC(hb_DateTime(), 2) + "] INFO: " + cMsg + hb_eol())
      FClose(hFile)
   ENDIF
RETURN NIL

FUNCTION ObtenerLogDir()
   RETURN hb_GetEnv("HOME") + "/.local/share/Facturas/logs"
