#include "hbsqlit3.ch"
FUNCTION HacerBackup()
   LOCAL cDbPath := ObtenerDbPath(), cTimestamp, cBakName
   LOCAL cDir1 := hb_GetEnv("HOME") + "/Facturas/backups"
   LOCAL cDir2 := hb_GetEnv("HOME") + "/.local/share/Facturas/backups"
   IF !hb_FileExists(cDbPath)
      RETURN .F.
   ENDIF
   cTimestamp := hb_TToC(hb_DateTime(), 3)
   cTimestamp := StrTran(cTimestamp, ":", "")
   cTimestamp := StrTran(cTimestamp, "-", "")
   cTimestamp := StrTran(cTimestamp, "T", "_")
   cBakName := "facturas_" + Left(cTimestamp, 15) + ".db"
   hb_DirBuild(cDir1)
   hb_DirBuild(cDir2)
   IF hb_FileExists(cDir1 + "/" + cBakName)
      hb_FileDelete(cDir1 + "/" + cBakName)
   ENDIF
   hb_FCopy(cDbPath, cDir1 + "/" + cBakName)
   IF hb_FileExists(cDir2 + "/" + cBakName)
      hb_FileDelete(cDir2 + "/" + cBakName)
   ENDIF
   hb_FCopy(cDbPath, cDir2 + "/" + cBakName)
   LimpiarBackups(cDir1)
   LimpiarBackups(cDir2)
   LogInfo("Backup creado: " + cBakName)
   RETURN .T.

STATIC FUNCTION LimpiarBackups(cDir)
   LOCAL aFiles, nI
   IF !hb_DirExists(cDir)
      RETURN
   ENDIF
   aFiles := hb_DirScan(cDir, "facturas_*.db")
   IF Len(aFiles) <= 10
      RETURN
   ENDIF
   ASort(aFiles)
   FOR nI := 1 TO Len(aFiles) - 10
      hb_FileDelete(cDir + "/" + aFiles[nI])
   NEXT
RETURN

FUNCTION EncontrarBackup()
   LOCAL aDirs := { ;
      hb_GetEnv("HOME") + "/Facturas/backups", ;
      hb_GetEnv("HOME") + "/.local/share/Facturas/backups" }
   LOCAL nD, aFiles := {}, nF, cFile
   FOR nD := 1 TO Len(aDirs)
      IF hb_DirExists(aDirs[nD])
          aFiles := hb_DirScan(aDirs[nD], "facturas_*.db")
          IF !Empty(aFiles)
             ASort(aFiles,,, {|x,y| x[1] < y[1]})
             cFile := aDirs[nD] + "/" + aFiles[Len(aFiles)][1]
            IF hb_FileExists(cFile)
               RETURN cFile
            ENDIF
         ENDIF
      ENDIF
   NEXT
   RETURN NIL

FUNCTION VerificarIntegridad()
   LOCAL db := AbrirBaseDatos(), stmt, cResult := "ok"
   IF Empty(db)
      RETURN .F.
   ENDIF
   stmt := sqlite3_prepare(db, "PRAGMA integrity_check")
   IF sqlite3_step(stmt) == SQLITE_ROW
      cResult := sqlite3_column_text(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   IF cResult != "ok"
      LogInfo("VerificarIntegridad: BD corrupta (" + cResult + ")")
      RETURN .F.
   ENDIF
   RETURN .T.

FUNCTION VerificarIntegridadRuta(cDbPath)
   LOCAL db, stmt, cResult := "ok"
   IF !hb_FileExists(cDbPath)
      RETURN .F.
   ENDIF
   db := sqlite3_open(cDbPath, .F.)
   IF Empty(db)
      RETURN .F.
   ENDIF
   stmt := sqlite3_prepare(db, "PRAGMA integrity_check")
   IF sqlite3_step(stmt) == SQLITE_ROW
      cResult := sqlite3_column_text(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cResult == "ok"

FUNCTION RestaurarBackup(cBakPath)
   LOCAL cDbPath := ObtenerDbPath(), cDir
   IF cBakPath == NIL
      cBakPath := EncontrarBackup()
   ENDIF
   IF cBakPath == NIL .OR. !hb_FileExists(cBakPath)
      LogInfo("RestaurarBackup: no hay backup disponible")
      RETURN .F.
   ENDIF
   LogInfo("Restaurando backup: " + cBakPath)
   cDir := hb_FNameDir(cDbPath)
   IF !hb_DirExists(cDir)
      hb_DirBuild(cDir)
   ENDIF
   IF hb_FileExists(cDbPath)
      hb_FileDelete(cDbPath)
   ENDIF
   hb_FCopy(cBakPath, cDbPath)
   IF hb_FileExists(cDbPath) .AND. VerificarIntegridadRuta(cDbPath)
      LogInfo("Backup restaurado correctamente")
      RETURN .T.
   ENDIF
   LogInfo("RestaurarBackup: fallo al restaurar")
   RETURN .F.

FUNCTION EnsureDbReady()
   LOCAL cDbPath := ObtenerDbPath(), cBakPath
   IF hb_FileExists(cDbPath)
      IF VerificarIntegridadRuta(cDbPath)
         RETURN .T.
      ENDIF
      LogInfo("EnsureDbReady: BD corrupta, restaurando desde backup")
      hb_FileDelete(cDbPath)
   ENDIF
   cBakPath := EncontrarBackup()
   IF cBakPath == NIL
      RETURN .F.
   ENDIF
   RETURN RestaurarBackup(cBakPath)
