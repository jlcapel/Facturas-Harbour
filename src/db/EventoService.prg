#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION RegistrarEvento(db, nTipoEvento, cDescripcion, cUsuario)
   LOCAL cUltimoHash, cData, cHash, stmt, nRes
   LOCAL cFechaHora := hb_TToC(hb_DateTime(), 1)

   cUltimoHash := ObtenerUltimoHashEvento(db)
   cData := hb_ntos(nTipoEvento) + "|" + cDescripcion + "|" + cFechaHora + "|" + cUltimoHash
   cHash := Upper(hb_SHA256(cData, 1))

   stmt := sqlite3_prepare(db, ;
      "INSERT INTO RegistrosEvento(TipoEvento, Descripcion, Usuario, FechaHora, Hash, HashAnterior) " + ;
      "VALUES(?, ?, ?, ?, ?, ?)")
   sqlite3_bind_int(stmt, 1, nTipoEvento)
   sqlite3_bind_text(stmt, 2, cDescripcion)
   IF cUsuario == NIL
      sqlite3_bind_null(stmt, 3)
   ELSE
      sqlite3_bind_text(stmt, 3, cUsuario)
   ENDIF
   sqlite3_bind_text(stmt, 4, cFechaHora)
   sqlite3_bind_text(stmt, 5, cHash)
   IF Empty(cUltimoHash)
      sqlite3_bind_null(stmt, 6)
   ELSE
      sqlite3_bind_text(stmt, 6, cUltimoHash)
   ENDIF
   nRes := sqlite3_step(stmt)
   sqlite3_finalize(stmt)
   RETURN nRes == SQLITE_DONE

STATIC FUNCTION ObtenerUltimoHashEvento(db)
   LOCAL stmt := sqlite3_prepare(db, ;
      "SELECT Hash FROM RegistrosEvento ORDER BY Id DESC LIMIT 1")
   LOCAL cHash := ""
   IF sqlite3_step(stmt) == SQLITE_ROW
      cHash := sqlite3_column_text(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN cHash
