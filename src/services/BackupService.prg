#require "hbsqlit3"
#include "hbsqlit3.ch"

STATIC nSecuenciaBackup := 0

FUNCTION HacerBackup(cDbPath, cDirectorioBackup)
   LOCAL cDir1, cDir2, cNombre, lOk

   IF cDbPath == NIL
      cDbPath := ObtenerDbPath()
   ENDIF
   IF !hb_FileExists(cDbPath)
      RETURN .F.
   ENDIF
   IF cDirectorioBackup != NIL
      hb_DirBuild(cDirectorioBackup)
      cNombre := NombreBackupUnico(cDirectorioBackup, NIL)
      lOk := CrearBackupSqlite(cDbPath, cDirectorioBackup + "/" + cNombre)
      IF lOk
         LimpiarBackups(cDirectorioBackup)
      ENDIF
      RETURN lOk
   ENDIF

   cDir1 := hb_GetEnv("HOME") + "/Facturas/backups"
   cDir2 := hb_GetEnv("HOME") + "/.local/share/Facturas/backups"
   hb_DirBuild(cDir1)
   hb_DirBuild(cDir2)
   cNombre := NombreBackupUnico(cDir1, cDir2)
   lOk := CrearBackupSqlite(cDbPath, cDir1 + "/" + cNombre)
   IF lOk
      lOk := CrearBackupSqlite(cDbPath, cDir2 + "/" + cNombre)
   ENDIF
   IF lOk
      LimpiarBackups(cDir1)
      LimpiarBackups(cDir2)
      LogInfo("Backup creado: " + cNombre)
   ENDIF
RETURN lOk

STATIC FUNCTION NombreBackupUnico(cDir1, cDir2)
   LOCAL cMarca := hb_TToS(hb_DateTime()), cNombre

   DO WHILE .T.
      nSecuenciaBackup++
      cNombre := "facturas_" + cMarca + "_" + PadL(nSecuenciaBackup, 4, "0") + ".db"
      IF !hb_FileExists(cDir1 + "/" + cNombre) .AND. ;
            (cDir2 == NIL .OR. !hb_FileExists(cDir2 + "/" + cNombre))
         EXIT
      ENDIF
   ENDDO
RETURN cNombre

STATIC FUNCTION CrearBackupSqlite(cDbPath, cBakPath)
   LOCAL dbOrigen, dbDestino, hBackup, nResultado, lOk := .F.

   IF hb_FileExists(cBakPath)
      RETURN .F.
   ENDIF
   dbOrigen := sqlite3_open(cDbPath, .F.)
   IF Empty(dbOrigen)
      RETURN .F.
   ENDIF
   dbDestino := sqlite3_open(cBakPath, .T.)
   IF !Empty(dbDestino)
      hBackup := sqlite3_backup_init(dbDestino, "main", dbOrigen, "main")
      IF !Empty(hBackup)
         nResultado := sqlite3_backup_step(hBackup, -1)
         sqlite3_backup_finish(hBackup)
         lOk := nResultado == SQLITE_DONE
      ENDIF
   ENDIF
   dbOrigen := NIL
   dbDestino := NIL
RETURN lOk .AND. hb_FileExists(cBakPath) .AND. VerificarIntegridadRuta(cBakPath)

STATIC FUNCTION LimpiarBackups(cDir)
   LOCAL aArchivos, nI

   IF !hb_DirExists(cDir)
      RETURN NIL
   ENDIF
   aArchivos := hb_DirScan(cDir, "facturas_*.db")
   IF Len(aArchivos) <= 10
      RETURN NIL
   ENDIF
   ASort(aArchivos, , , {|a,b| a[1] < b[1]})
   FOR nI := 1 TO Len(aArchivos) - 10
      hb_FileDelete(cDir + "/" + aArchivos[nI][1])
   NEXT
RETURN NIL

FUNCTION EncontrarBackup(cDirectorioBackup)
   LOCAL aDirectorios, nD, aArchivos, cArchivo

   IF cDirectorioBackup == NIL
      aDirectorios := { ;
         hb_GetEnv("HOME") + "/Facturas/backups", ;
         hb_GetEnv("HOME") + "/.local/share/Facturas/backups" }
   ELSE
      aDirectorios := {cDirectorioBackup}
   ENDIF
   FOR nD := 1 TO Len(aDirectorios)
      IF hb_DirExists(aDirectorios[nD])
         aArchivos := hb_DirScan(aDirectorios[nD], "facturas_*.db")
         IF !Empty(aArchivos)
            ASort(aArchivos, , , {|a,b| a[1] < b[1]})
            cArchivo := aDirectorios[nD] + "/" + aArchivos[Len(aArchivos)][1]
            IF hb_FileExists(cArchivo)
               RETURN cArchivo
            ENDIF
         ENDIF
      ENDIF
   NEXT
RETURN NIL

FUNCTION VerificarIntegridad()
RETURN VerificarIntegridadRuta(ObtenerDbPath())

FUNCTION VerificarIntegridadRuta(cDbPath)
   LOCAL db, stmt, cResultado := "ok"

   IF !hb_FileExists(cDbPath)
      RETURN .F.
   ENDIF
   db := sqlite3_open(cDbPath, .F.)
   IF Empty(db)
      RETURN .F.
   ENDIF
   stmt := sqlite3_prepare(db, "PRAGMA integrity_check")
   IF Empty(stmt)
      db := NIL
      RETURN .F.
   ENDIF
   IF sqlite3_step(stmt) == SQLITE_ROW
      cResultado := sqlite3_column_text(stmt, 1)
   ENDIF
   sqlite3_finalize(stmt)
   db := NIL
RETURN cResultado == "ok"

FUNCTION RestaurarBackup(cBakPath, cDbPath)
   LOCAL cTemporal

   IF cDbPath == NIL
      cDbPath := ObtenerDbPath()
   ENDIF
   IF cBakPath == NIL
      cBakPath := EncontrarBackup()
   ENDIF
   IF cBakPath == NIL .OR. !hb_FileExists(cBakPath) .OR. !VerificarIntegridadRuta(cBakPath)
      LogInfo("RestaurarBackup: no hay backup válido disponible")
      RETURN .F.
   ENDIF
   cTemporal := cDbPath + ".restore"
   IF hb_FileExists(cTemporal)
      hb_FileDelete(cTemporal)
   ENDIF
   IF !CrearBackupSqlite(cBakPath, cTemporal)
      RETURN .F.
   ENDIF
   IF hb_FileExists(cDbPath)
      hb_FileDelete(cDbPath)
   ENDIF
   IF hb_FileExists(cDbPath + "-wal")
      hb_FileDelete(cDbPath + "-wal")
   ENDIF
   IF hb_FileExists(cDbPath + "-shm")
      hb_FileDelete(cDbPath + "-shm")
   ENDIF
   IF !CrearBackupSqlite(cTemporal, cDbPath)
      hb_FileDelete(cTemporal)
      RETURN .F.
   ENDIF
   hb_FileDelete(cTemporal)
   IF VerificarIntegridadRuta(cDbPath)
      LogInfo("Backup restaurado correctamente")
      RETURN .T.
   ENDIF
RETURN .F.

FUNCTION EnsureDbReady()
   LOCAL cDbPath := ObtenerDbPath(), cBakPath

   IF hb_FileExists(cDbPath) .AND. VerificarIntegridadRuta(cDbPath)
      RETURN .T.
   ENDIF
   cBakPath := EncontrarBackup()
   IF cBakPath == NIL
      RETURN .F.
   ENDIF
   LogInfo("EnsureDbReady: restaurando backup " + cBakPath)
RETURN RestaurarBackup(cBakPath, cDbPath)
