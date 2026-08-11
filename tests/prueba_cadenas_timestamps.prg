#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cRutaDb := hb_GetEnv("FACTURAS_PRUEBA_DB")
   LOCAL db := sqlite3_open(cRutaDb, .T.)
   LOCAL dFecha := hb_SToD("20260713")
   LOCAL dtRegistro := hb_DateTime(2026, 7, 13, 10, 53, 48)
   LOCAL dtModificado := hb_DateTime(2026, 7, 13, 10, 53, 49)
   LOCAL cHashUno, cHashDos
   LOCAL lAbierta, lRegistrosValidos, lHashModificado, lAnteriorModificado, lTimestampModificado
   LOCAL lEventosValidos, lEventoModificado

   lAbierta := !Empty(db)
   HBTEST lAbierta IS .T.
   IF !lAbierta
      ErrorLevel(1)
      RETURN
   ENDIF
   CrearTablasCadena(db)

   cHashUno := CalcularHashVeriFactu("B12345674", "F2026-000001", dFecha, "F1", 2.59, 14.93, "", dtRegistro)
   cHashDos := CalcularHashVeriFactu("B12345674", "F2026-000002", dFecha, "F1", 4.20, 24.20, cHashUno, dtRegistro)
   InsertarRegistro(db, cHashUno, NIL, NIL, "F2026-000001", dFecha, 12.34, 2.59, dtRegistro)
   InsertarRegistro(db, cHashDos, cHashUno, 1, "F2026-000002", dFecha, 20.00, 4.20, dtRegistro)

   lRegistrosValidos := VerificarCadenaRegistros(db)
   sqlite3_exec(db, "UPDATE RegistrosFacturacion SET Hash='HASH_INVALIDO' WHERE Id=1")
   lHashModificado := !VerificarCadenaRegistros(db)
   sqlite3_exec(db, "UPDATE RegistrosFacturacion SET Hash='" + cHashUno + "' WHERE Id=1")
   sqlite3_exec(db, "UPDATE RegistrosFacturacion SET HashAnterior='HASH_ANTERIOR_INVALIDO' WHERE Id=2")
   lAnteriorModificado := !VerificarCadenaRegistros(db)
   sqlite3_exec(db, "UPDATE RegistrosFacturacion SET HashAnterior='" + cHashUno + "' WHERE Id=2")
   sqlite3_exec(db, "UPDATE RegistrosFacturacion SET FechaHoraHusoGenRegistro='" + FechaISO8601ConTimeZone(dtModificado) + "' WHERE Id=1")
   lTimestampModificado := !VerificarCadenaRegistros(db)

   RegistrarEvento(db, "Login", "Inicio", "operador")
   RegistrarEvento(db, "Exportacion", "Resultado", "operador")
   lEventosValidos := VerificarCadenaEventos(db)
   sqlite3_exec(db, "UPDATE RegistrosEvento SET Descripcion='Manipulado' WHERE Id=1")
   lEventoModificado := !VerificarCadenaEventos(db)

   HBTEST lRegistrosValidos IS .T.
   HBTEST lHashModificado IS .T.
   HBTEST lAnteriorModificado IS .T.
   HBTEST lTimestampModificado IS .T.
   HBTEST lEventosValidos IS .T.
   HBTEST lEventoModificado IS .T.
   db := NIL
   ErrorLevel(Iif(lRegistrosValidos .AND. lHashModificado .AND. lAnteriorModificado .AND. ;
      lTimestampModificado .AND. lEventosValidos .AND. lEventoModificado, 0, 1))
RETURN

FUNCTION EnviarRegistroAnulacion(db, nRegistroId)
RETURN NIL

FUNCTION ObtenerFechaHoraOficial()
RETURN hb_DateTime(2026, 7, 13, 10, 53, 48)

STATIC FUNCTION CrearTablasCadena(db)
   sqlite3_exec(db, "CREATE TABLE RegistrosFacturacion(Id INTEGER PRIMARY KEY AUTOINCREMENT, Hash TEXT NOT NULL, HashAnterior TEXT, NifEmisor TEXT NOT NULL, NumeroFactura TEXT NOT NULL, FechaEmision TEXT NOT NULL, IvaImporte TEXT NOT NULL, BaseImponible TEXT NOT NULL, Total TEXT NOT NULL, TipoFactura TEXT NOT NULL, FechaHoraHusoGenRegistro TEXT NOT NULL, IdRegistroAnterior INTEGER)")
   sqlite3_exec(db, "CREATE TABLE RegistrosEvento(Id INTEGER PRIMARY KEY AUTOINCREMENT, TipoEvento TEXT NOT NULL, Descripcion TEXT NOT NULL, Usuario TEXT, FechaHora TEXT NOT NULL, Hash TEXT, HashAnterior TEXT, IdEventoAnterior INTEGER)")
RETURN NIL

STATIC FUNCTION InsertarRegistro(db, cHash, cHashAnterior, nIdRegistroAnterior, cNumeroFactura, dFecha, nBase, nIva, dtRegistro)
   LOCAL stmt := sqlite3_prepare(db, "INSERT INTO RegistrosFacturacion(Hash, HashAnterior, NifEmisor, NumeroFactura, FechaEmision, IvaImporte, BaseImponible, Total, TipoFactura, FechaHoraHusoGenRegistro, IdRegistroAnterior) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")

   sqlite3_bind_text(stmt, 1, cHash)
   IF cHashAnterior == NIL
      sqlite3_bind_null(stmt, 2)
   ELSE
      sqlite3_bind_text(stmt, 2, cHashAnterior)
   ENDIF
   sqlite3_bind_text(stmt, 3, "B12345674")
   sqlite3_bind_text(stmt, 4, cNumeroFactura)
   sqlite3_bind_text(stmt, 5, FechaISO8601(dFecha))
   sqlite3_bind_text(stmt, 6, DecimalAPuntoSinEspacios(nIva))
   sqlite3_bind_text(stmt, 7, DecimalAPuntoSinEspacios(nBase))
   sqlite3_bind_text(stmt, 8, DecimalAPuntoSinEspacios(nBase + nIva))
   sqlite3_bind_text(stmt, 9, "F1")
   sqlite3_bind_text(stmt, 10, FechaISO8601ConTimeZone(dtRegistro))
   IF nIdRegistroAnterior == NIL
      sqlite3_bind_null(stmt, 11)
   ELSE
      sqlite3_bind_int(stmt, 11, nIdRegistroAnterior)
   ENDIF
   sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN NIL
