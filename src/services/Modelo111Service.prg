#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION GenerarModelo111(db, nEjercicio, nTrimestre)
   LOCAL aRango := ObtenerRangoTrimestre(nEjercicio, nTrimestre)
   LOCAL cFechaIni := aRango[1], cFechaFin := aRango[2]
   LOCAL aGastos, aPerceptores := {}, nI, cNifProv, oPer, nTotalBase := 0, nTotalRet := 0
   LOCAL aCfg := ObtenerConfigAeat(db)
   LOCAL cNif := aCfg[1], cRazon := aCfg[2]
   LOCAL stmt, hFile, cBuffer, nCount := 0, cDir, cPath

   stmt := sqlite3_prepare(db, ;
      "SELECT g.BaseImponible, g.RetencionImporte, g.RetencionPorcentaje, " + ;
      "p.Nif, p.Nombre " + ;
      "FROM Gastos g LEFT JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "WHERE g.FechaEmision >= ? AND g.FechaEmision <= ? AND g.RetencionImporte > 0")
   sqlite3_bind_text(stmt, 1, cFechaIni)
   sqlite3_bind_text(stmt, 2, cFechaFin)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cNifProv := sqlite3_column_text(stmt, 3)
      IF Empty(cNifProv); cNifProv := "00000000Z"; ENDIF
      oPer := BuscarPerceptor111(aPerceptores, cNifProv)
      IF oPer == NIL
         oPer := { cNifProv, sqlite3_column_text(stmt, 4), 0, 0 }
         AAdd(aPerceptores, oPer)
      ENDIF
      oPer[3] := oPer[3] + Val(sqlite3_column_text(stmt, 0))
      oPer[4] := oPer[4] + Val(sqlite3_column_text(stmt, 1))
   ENDDO
   sqlite3_finalize(stmt)

   IF Empty(aPerceptores)
      RETURN NIL
   ENDIF

   ASort(aPerceptores, , , {|x, y| x[1] < y[1]})

   cDir := hb_GetEnv("HOME") + "/Facturas/modelos111"
   hb_DirBuild(cDir)
   cPath := cDir + "/" + AllTrim(cNif) + "_" + LTrim(Str(nEjercicio)) + "_" + LTrim(Str(nTrimestre)) + "T.111"
   hFile := FCreate(cPath, 0)
   IF hFile == -1
      RETURN NIL
   ENDIF

   cBuffer := Buffer1500()
   cBuffer := RellenarBuffer(cBuffer, 1, "1")
   cBuffer := RellenarBuffer(cBuffer, 2, PadR(cNif, 9))
   cBuffer := RellenarBuffer(cBuffer, 11, PadR(cRazon, 80))
   cBuffer := RellenarBuffer(cBuffer, 91, Str(nEjercicio, 4))
   cBuffer := RellenarBuffer(cBuffer, 95, LTrim(Str(nTrimestre)))
   cBuffer := RellenarBuffer(cBuffer, 96, "N")
   cBuffer := RellenarBuffer(cBuffer, 97, "F")
   cBuffer := RellenarBuffer(cBuffer, 98, PadL(LTrim(Str(Len(aPerceptores))), 5, "0"))
   EscribirLinea(hFile, cBuffer)

   FOR nI := 1 TO Len(aPerceptores)
      oPer := aPerceptores[nI]
      nTotalBase := nTotalBase + oPer[3]
      nTotalRet := nTotalRet + oPer[4]
      nCount++
      cBuffer := Buffer1500()
      cBuffer := RellenarBuffer(cBuffer, 1, "2")
      cBuffer := RellenarBuffer(cBuffer, 2, PadR(oPer[1], 9))
      cBuffer := RellenarBuffer(cBuffer, 11, PadR(oPer[2], 80))
      cBuffer := RellenarBuffer(cBuffer, 91, "01")
      cBuffer := RellenarBuffer(cBuffer, 93, FormatearImporte(oPer[3]))
      cBuffer := RellenarBuffer(cBuffer, 110, FormatearImporte(oPer[4]))
      EscribirLinea(hFile, cBuffer)
   NEXT

   FClose(hFile)

   RETURN { ;
      "Ejercicio", nEjercicio, ;
      "Trimestre", nTrimestre, ;
      "Nif", cNif, ;
      "RazonSocial", cRazon, ;
      "TotalPerceptores", nCount, ;
      "TotalBase", nTotalBase, ;
      "TotalRetencion", nTotalRet, ;
      "Fichero", cPath }

STATIC FUNCTION BuscarPerceptor111(aList, cNif)
   LOCAL nI
   FOR nI := 1 TO Len(aList)
      IF aList[nI][1] == cNif
         RETURN aList[nI]
      ENDIF
   NEXT
   RETURN NIL
