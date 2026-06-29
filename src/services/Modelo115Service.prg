#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION GenerarModelo115(db, nEjercicio, nTrimestre)
   LOCAL aRango := ObtenerRangoTrimestre(nEjercicio, nTrimestre)
   LOCAL cFechaIni := aRango[1], cFechaFin := aRango[2]
   LOCAL aGastos, aArr := {}, nI, cNifProv, oArr, nTotalBase := 0, nTotalRet := 0
   LOCAL aCfg := ObtenerConfigAeat(db)
   LOCAL cNif := aCfg[1], cRazon := aCfg[2]
   LOCAL stmt, hFile, cBuffer, nCount := 0, cDir, cPath, cCatNombre
   LOCAL cTieneAlq := "N"

   stmt := sqlite3_prepare(db, ;
      "SELECT g.BaseImponible, g.RetencionImporte, g.RetencionPorcentaje, " + ;
      "p.Nif, p.Nombre, cg.Nombre " + ;
      "FROM Gastos g " + ;
      "LEFT JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "LEFT JOIN CategoriasGasto cg ON g.CategoriaGastoId = cg.Id " + ;
      "WHERE g.FechaEmision >= ? AND g.FechaEmision <= ? AND g.RetencionImporte > 0")
   sqlite3_bind_text(stmt, 1, cFechaIni)
   sqlite3_bind_text(stmt, 2, cFechaFin)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cCatNombre := sqlite3_column_text(stmt, 5)
      IF !Empty(cCatNombre) .AND. "Alquiler" $ Upper(cCatNombre)
         cNifProv := sqlite3_column_text(stmt, 3)
         IF Empty(cNifProv); cNifProv := "00000000Z"; ENDIF
         oArr := BuscarArrendador(aArr, cNifProv)
         IF oArr == NIL
            oArr := { cNifProv, sqlite3_column_text(stmt, 4), 0, 0 }
            AAdd(aArr, oArr)
         ENDIF
         oArr[3] := oArr[3] + Val(sqlite3_column_text(stmt, 0))
         oArr[4] := oArr[4] + Val(sqlite3_column_text(stmt, 1))
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)

   IF Empty(aArr)
      RETURN NIL
   ENDIF

   ASort(aArr, , , {|x, y| x[1] < y[1]})

   cDir := hb_GetEnv("HOME") + "/Facturas/modelos115"
   hb_DirBuild(cDir)
   cPath := cDir + "/" + AllTrim(cNif) + "_" + LTrim(Str(nEjercicio)) + "_" + LTrim(Str(nTrimestre)) + "T.115"
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
   cBuffer := RellenarBuffer(cBuffer, 98, PadL(LTrim(Str(Len(aArr))), 5, "0"))
   EscribirLinea(hFile, cBuffer)

   FOR nI := 1 TO Len(aArr)
      oArr := aArr[nI]
      nTotalBase := nTotalBase + oArr[3]
      nTotalRet := nTotalRet + oArr[4]
      nCount++
      cBuffer := Buffer1500()
      cBuffer := RellenarBuffer(cBuffer, 1, "2")
      cBuffer := RellenarBuffer(cBuffer, 2, PadR(oArr[1], 9))
      cBuffer := RellenarBuffer(cBuffer, 11, PadR(oArr[2], 80))
      cBuffer := RellenarBuffer(cBuffer, 91, "01")
      cBuffer := RellenarBuffer(cBuffer, 93, FormatearImporte(oArr[3]))
      cBuffer := RellenarBuffer(cBuffer, 110, FormatearImporte(oArr[4]))
      EscribirLinea(hFile, cBuffer)
   NEXT

   FClose(hFile)

   RETURN { ;
      "Ejercicio", nEjercicio, ;
      "Trimestre", nTrimestre, ;
      "Nif", cNif, ;
      "RazonSocial", cRazon, ;
      "TotalArrendadores", nCount, ;
      "TotalBase", nTotalBase, ;
      "TotalRetencion", nTotalRet, ;
      "Fichero", cPath }

STATIC FUNCTION BuscarArrendador(aList, cNif)
   LOCAL nI
   FOR nI := 1 TO Len(aList)
      IF aList[nI][1] == cNif
         RETURN aList[nI]
      ENDIF
   NEXT
   RETURN NIL
