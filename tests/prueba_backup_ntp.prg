#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cDirectorio := hb_GetEnv("FACTURAS_PRUEBA_DIR")
   LOCAL cOrigen := cDirectorio + "/origen.db", cBackups := cDirectorio + "/backups"
   LOCAL cDestino := cDirectorio + "/restaurada.db", cBackup
   LOCAL db, dtOficial, dtLocal := hb_DateTime(2026, 8, 10, 9, 0, 0)
   LOCAL cRespuestaNtp
   LOCAL lHoraDisponible, lHoraNoDisponible, lBackup, lIntegridad, lRestauracion, lRetencion
   LOCAL nI

   cRespuestaNtp := Replicate(Chr(0), 40) + Chr(238) + Chr(36) + Chr(67) + Chr(240) + Replicate(Chr(0), 4)
   dtOficial := ResolverFechaHoraOficial(cRespuestaNtp, dtLocal)
   lHoraDisponible := Left(hb_TToS(dtOficial), 14) == "20260810123456"
   lHoraNoDisponible := ResolverFechaHoraOficial(Replicate(Chr(0), 48), dtLocal) == dtLocal
   db := sqlite3_open(cOrigen, .T.)
   sqlite3_exec(db, "PRAGMA journal_mode=WAL")
   sqlite3_exec(db, "CREATE TABLE Datos(Id INTEGER PRIMARY KEY, Valor TEXT)")
   sqlite3_exec(db, "INSERT INTO Datos(Id, Valor) VALUES(1, 'WAL confirmado')")
   lBackup := HacerBackup(cOrigen, cBackups)
   db := NIL
   cBackup := EncontrarBackup(cBackups)
   lIntegridad := .F.
   IF lBackup
      IF cBackup != NIL
         lIntegridad := VerificarIntegridadRuta(cBackup)
         IF lIntegridad
            lIntegridad := ExisteValor(cBackup, "WAL confirmado")
         ENDIF
      ENDIF
   ENDIF
   lRestauracion := .F.
   IF cBackup != NIL
      lRestauracion := RestaurarBackup(cBackup, cDestino)
      IF lRestauracion
         lRestauracion := VerificarIntegridadRuta(cDestino)
      ENDIF
      IF lRestauracion
         lRestauracion := ExisteValor(cDestino, "WAL confirmado")
      ENDIF
   ENDIF
   FOR nI := 1 TO 10
      HacerBackup(cOrigen, cBackups)
   NEXT
   lRetencion := ContarBackups(cBackups) == 10

   HBTEST lHoraDisponible IS .T.
   HBTEST lHoraNoDisponible IS .T.
   HBTEST lBackup IS .T.
   HBTEST lIntegridad IS .T.
   HBTEST lRestauracion IS .T.
   HBTEST lRetencion IS .T.
   ErrorLevel(Iif(lHoraDisponible .AND. lHoraNoDisponible .AND. lBackup .AND. lIntegridad .AND. lRestauracion .AND. lRetencion, 0, 1))
RETURN

FUNCTION LogInfo(cTexto)
RETURN NIL

FUNCTION LogError(cOrigen, cTexto)
RETURN NIL

STATIC FUNCTION ExisteValor(cDbPath, cValorEsperado)
   LOCAL db := sqlite3_open(cDbPath, .F.)
   LOCAL stmt, cValor := "", lExiste, nPaso

   IF Empty(db)
      RETURN .F.
   ENDIF
   stmt := sqlite3_prepare(db, "SELECT Valor FROM Datos WHERE Id=1")
   IF !Empty(stmt)
      nPaso := sqlite3_step(stmt)
      IF nPaso == SQLITE_ROW
         cValor := sqlite3_column_text(stmt, 1)
      ENDIF
      sqlite3_finalize(stmt)
   ENDIF
   db := NIL
   lExiste := cValor == cValorEsperado
RETURN lExiste

STATIC FUNCTION ContarBackups(cDirectorio)
RETURN Len(hb_DirScan(cDirectorio, "facturas_*.db"))
