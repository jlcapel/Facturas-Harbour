#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cRutaDb := hb_GetEnv("FACTURAS_PRUEBA_DB")
   LOCAL cRutaCertificado := cRutaDb + ".p12"
   LOCAL db := sqlite3_open(cRutaDb, .T.)
   LOCAL nArchivo, aSinCertificado, aCertificadoInexistente, aEntornoInvalido, aPasswordVacia
   LOCAL lAbierta, lSinCertificado, lCertificadoInexistente, lEntornoInvalido, lPasswordVacia, lTlsActivo

   lAbierta := !Empty(db)
   HBTEST lAbierta IS .T.
   IF !lAbierta
      ErrorLevel(1)
      RETURN
   ENDIF
   sqlite3_exec(db, "CREATE TABLE Configuracion(Id INTEGER PRIMARY KEY AUTOINCREMENT, Clave TEXT NOT NULL UNIQUE, Valor TEXT)")

   EstablecerConfigPrueba(db, "VeriFactu.Ambiente", "1")
   EstablecerConfigPrueba(db, "VeriFactu.CertificadoRuta", "")
   EstablecerConfigPrueba(db, "VeriFactu.CertificadoPassword", "secreta")
   aSinCertificado := PrepararEnvioAeat(db)
   lSinCertificado := !aSinCertificado[1] .AND. aSinCertificado[2] == "CERTIFICADO_AUSENTE"

   EstablecerConfigPrueba(db, "VeriFactu.CertificadoRuta", cRutaCertificado + ".inexistente")
   aCertificadoInexistente := PrepararEnvioAeat(db)
   lCertificadoInexistente := !aCertificadoInexistente[1] .AND. aCertificadoInexistente[2] == "CERTIFICADO_INEXISTENTE"

   EstablecerConfigPrueba(db, "VeriFactu.Ambiente", "99")
   aEntornoInvalido := PrepararEnvioAeat(db)
   lEntornoInvalido := !aEntornoInvalido[1] .AND. aEntornoInvalido[2] == "ENTORNO_INVALIDO"

   nArchivo := FCreate(cRutaCertificado)
   IF nArchivo != -1
      FClose(nArchivo)
   ENDIF
   EstablecerConfigPrueba(db, "VeriFactu.Ambiente", "2")
   EstablecerConfigPrueba(db, "VeriFactu.CertificadoRuta", cRutaCertificado)
   EstablecerConfigPrueba(db, "VeriFactu.CertificadoPassword", "")
   aPasswordVacia := PrepararEnvioAeat(db)
   lPasswordVacia := aPasswordVacia[1] .AND. aPasswordVacia[3] == "https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP" .AND. ;
      aPasswordVacia[4] == cRutaCertificado .AND. aPasswordVacia[5] == "" .AND. aPasswordVacia[8] == "P12"
   lTlsActivo := aPasswordVacia[6] == 1 .AND. aPasswordVacia[7] == 2

   HBTEST lSinCertificado IS .T.
   HBTEST lCertificadoInexistente IS .T.
   HBTEST lEntornoInvalido IS .T.
   HBTEST lPasswordVacia IS .T.
   HBTEST lTlsActivo IS .T.
   db := NIL
   IF hb_FileExists(cRutaCertificado)
      FErase(cRutaCertificado)
   ENDIF
   ErrorLevel(Iif(lSinCertificado .AND. lCertificadoInexistente .AND. lEntornoInvalido .AND. ;
      lPasswordVacia .AND. lTlsActivo, 0, 1))
RETURN

STATIC FUNCTION EstablecerConfigPrueba(db, cClave, cValor)
   LOCAL stmt := sqlite3_prepare(db, "INSERT OR REPLACE INTO Configuracion(Clave, Valor) VALUES(?, ?)")

   sqlite3_bind_text(stmt, 1, cClave)
   sqlite3_bind_text(stmt, 2, cValor)
   sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN NIL
