#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION GenerarModelo347(db, nEjercicio)
   LOCAL aCfg := ObtenerConfigAeat(db)
   LOCAL cNif := aCfg[1], cRazon := aCfg[2]
   LOCAL aEntregas := {}, aAdquis := {}, nI, oOp
   LOCAL cDir, cPath, hFile, cBuffer, nCount := 0, cTipo, nTotalOp := 0
   LOCAL stmt, cNifOp, cNomOp, nTotal, nT1, nT2, nT3, nT4

   stmt := sqlite3_prepare(db, ;
      "SELECT c.Nif, c.Nombre, " + ;
      "CAST(f.BaseImponible AS REAL) + CAST(f.IvaImporte AS REAL), " + ;
      "CAST(f.FechaEmision AS TEXT) " + ;
      "FROM Facturas f LEFT JOIN Clientes c ON f.ClienteId = c.Id " + ;
      "WHERE CAST(SUBSTR(f.FechaEmision, 1, 4) AS INTEGER) = ? AND f.Estado != 'Anulada'")
   sqlite3_bind_int(stmt, 1, nEjercicio)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cNifOp := sqlite3_column_text(stmt, 0)
      IF Empty(cNifOp); cNifOp := "00000000Z"; ENDIF
      nTotal := Val(sqlite3_column_text(stmt, 2))
      nT1 := 0; nT2 := 0; nT3 := 0; nT4 := 0
      DO CASE
      CASE Left(sqlite3_column_text(stmt, 3), 7) >= Str(nEjercicio, 4) + "-04"; nT2 := nTotal
      CASE Left(sqlite3_column_text(stmt, 3), 7) >= Str(nEjercicio, 4) + "-07"; nT3 := nTotal
      CASE Left(sqlite3_column_text(stmt, 3), 7) >= Str(nEjercicio, 4) + "-10"; nT4 := nTotal
      OTHERWISE; nT1 := nTotal
      ENDCASE
      oOp := BuscarOperacion(aEntregas, cNifOp)
      IF oOp == NIL
         oOp := { cNifOp, sqlite3_column_text(stmt, 1), 0, 0, 0, 0, 0 }
         AAdd(aEntregas, oOp)
      ENDIF
      oOp[3] := oOp[3] + nTotal; oOp[4] := oOp[4] + nT1; oOp[5] := oOp[5] + nT2
      oOp[6] := oOp[6] + nT3; oOp[7] := oOp[7] + nT4
   ENDDO
   sqlite3_finalize(stmt)

   stmt := sqlite3_prepare(db, ;
      "SELECT p.Nif, p.Nombre, CAST(g.BaseImponible AS REAL), " + ;
      "CAST(g.FechaEmision AS TEXT) " + ;
      "FROM Gastos g LEFT JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "WHERE CAST(SUBSTR(g.FechaEmision, 1, 4) AS INTEGER) = ?")
   sqlite3_bind_int(stmt, 1, nEjercicio)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cNifOp := sqlite3_column_text(stmt, 0)
      IF Empty(cNifOp); cNifOp := "00000000Z"; ENDIF
      nTotal := Val(sqlite3_column_text(stmt, 2))
      nT1 := 0; nT2 := 0; nT3 := 0; nT4 := 0
      DO CASE
      CASE Left(sqlite3_column_text(stmt, 3), 7) >= Str(nEjercicio, 4) + "-04"; nT2 := nTotal
      CASE Left(sqlite3_column_text(stmt, 3), 7) >= Str(nEjercicio, 4) + "-07"; nT3 := nTotal
      CASE Left(sqlite3_column_text(stmt, 3), 7) >= Str(nEjercicio, 4) + "-10"; nT4 := nTotal
      OTHERWISE; nT1 := nTotal
      ENDCASE
      oOp := BuscarOperacion(aAdquis, cNifOp)
      IF oOp == NIL
         oOp := { cNifOp, sqlite3_column_text(stmt, 1), 0, 0, 0, 0, 0 }
         AAdd(aAdquis, oOp)
      ENDIF
      oOp[3] := oOp[3] + nTotal; oOp[4] := oOp[4] + nT1; oOp[5] := oOp[5] + nT2
      oOp[6] := oOp[6] + nT3; oOp[7] := oOp[7] + nT4
   ENDDO
   sqlite3_finalize(stmt)

   ASort(aEntregas, , , {|x, y| x[1] < y[1]})
   ASort(aAdquis, , , {|x, y| x[1] < y[1]})

   cDir := hb_GetEnv("HOME") + "/Facturas/modelos347"
   hb_DirBuild(cDir)
   cPath := cDir + "/" + AllTrim(cNif) + "_" + LTrim(Str(nEjercicio)) + ".347"
   hFile := FCreate(cPath, 0)
   IF hFile == -1
      RETURN NIL
   ENDIF

   cBuffer := Buffer1500()
   cBuffer := RellenarBuffer(cBuffer, 1, "1")
   cBuffer := RellenarBuffer(cBuffer, 2, PadR(cNif, 9))
   cBuffer := RellenarBuffer(cBuffer, 11, PadR(cRazon, 80))
   cBuffer := RellenarBuffer(cBuffer, 91, Str(nEjercicio, 4))
   cBuffer := RellenarBuffer(cBuffer, 95, "N")
   cBuffer := RellenarBuffer(cBuffer, 96, "F")
   nTotalOp := Len(aEntregas) + Len(aAdquis)
   cBuffer := RellenarBuffer(cBuffer, 97, PadL(LTrim(Str(nTotalOp)), 5, "0"))
   EscribirLinea(hFile, cBuffer)

   FOR nI := 1 TO Len(aEntregas)
      oOp := aEntregas[nI]; nCount++
      cBuffer := Buffer1500()
      cBuffer := RellenarBuffer(cBuffer, 1, "2")
      cBuffer := RellenarBuffer(cBuffer, 2, PadR(oOp[1], 9))
      cBuffer := RellenarBuffer(cBuffer, 11, PadR(oOp[2], 80))
      cBuffer := RellenarBuffer(cBuffer, 91, "E"); cBuffer := RellenarBuffer(cBuffer, 92, "N")
      cBuffer := RellenarBuffer(cBuffer, 93, FormatearImporte(oOp[3]))
      cBuffer := RellenarBuffer(cBuffer, 110, FormatearImporte(oOp[4]))
      cBuffer := RellenarBuffer(cBuffer, 127, FormatearImporte(oOp[5]))
      cBuffer := RellenarBuffer(cBuffer, 144, FormatearImporte(oOp[6]))
      cBuffer := RellenarBuffer(cBuffer, 161, FormatearImporte(oOp[7]))
      EscribirLinea(hFile, cBuffer)
   NEXT
   FOR nI := 1 TO Len(aAdquis)
      oOp := aAdquis[nI]; nCount++
      cBuffer := Buffer1500()
      cBuffer := RellenarBuffer(cBuffer, 1, "2")
      cBuffer := RellenarBuffer(cBuffer, 2, PadR(oOp[1], 9))
      cBuffer := RellenarBuffer(cBuffer, 11, PadR(oOp[2], 80))
      cBuffer := RellenarBuffer(cBuffer, 91, "A"); cBuffer := RellenarBuffer(cBuffer, 92, "N")
      cBuffer := RellenarBuffer(cBuffer, 93, FormatearImporte(oOp[3]))
      cBuffer := RellenarBuffer(cBuffer, 110, FormatearImporte(oOp[4]))
      cBuffer := RellenarBuffer(cBuffer, 127, FormatearImporte(oOp[5]))
      cBuffer := RellenarBuffer(cBuffer, 144, FormatearImporte(oOp[6]))
      cBuffer := RellenarBuffer(cBuffer, 161, FormatearImporte(oOp[7]))
      EscribirLinea(hFile, cBuffer)
   NEXT

   FClose(hFile)

   RETURN { ;
      "Ejercicio", nEjercicio, ;
      "Nif", cNif, ;
      "RazonSocial", cRazon, ;
      "TotalEntregas", Len(aEntregas), ;
      "TotalAdquisiciones", Len(aAdquis), ;
      "TotalOperaciones", nTotalOp, ;
      "Fichero", cPath }

STATIC FUNCTION BuscarOperacion(aList, cNif)
   LOCAL nI
   FOR nI := 1 TO Len(aList)
      IF aList[nI][1] == cNif
         RETURN aList[nI]
      ENDIF
   NEXT
   RETURN NIL
