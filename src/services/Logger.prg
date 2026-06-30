#include "fileio.ch"
FUNCTION LogError(cCaller, cMsg)
   LOCAL cLogDir := ObtenerLogDir(), cPath, hFile
   hb_DirBuild(cLogDir)
   cPath := cLogDir + "/error.log"
   hFile := FOpen(cPath, FO_WRITE)
   IF hFile != -1
      FSeek(hFile, 0, FS_END)
      FWrite(hFile, "[" + hb_TToC(hb_DateTime(), 2) + "] ERROR en " + cCaller + ": " + cMsg + hb_eol())
      FClose(hFile)
   ENDIF
RETURN NIL

FUNCTION LogInfo(cMsg)
   LOCAL cLogDir := ObtenerLogDir(), cPath, hFile
   hb_DirBuild(cLogDir)
   cPath := cLogDir + "/error.log"
   hFile := FOpen(cPath, FO_WRITE)
   IF hFile != -1
      FSeek(hFile, 0, FS_END)
      FWrite(hFile, "[" + hb_TToC(hb_DateTime(), 2) + "] INFO: " + cMsg + hb_eol())
      FClose(hFile)
   ENDIF
RETURN NIL

FUNCTION ObtenerLogDir()
   RETURN hb_GetEnv("HOME") + "/.local/share/Facturas/logs"
