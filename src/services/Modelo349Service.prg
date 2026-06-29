#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION GenerarModelo349(db, nEjercicio)
   LOCAL aCfg := ObtenerConfigAeat(db)
   LOCAL cNif := aCfg[1], cRazon := aCfg[2]
   LOCAL aEntregas := {}, aAdquis := {}, nI, oOp
   LOCAL cDir, cPath, hFile, cBuffer, nCount := 0
   LOCAL stmt, cNifOp, cNomOp, nTotal

   stmt := sqlite3_prepare(db, ;
      "SELECT c.Nif, c.Nombre, CAST(f.BaseImponible AS REAL) + CAST(f.IvaImporte AS REAL) " + ;
      "FROM Facturas f LEFT JOIN Clientes c ON f.ClienteId = c.Id " + ;
      "LEFT JOIN Paises p ON c.PaisId = p.Id " + ;
      "WHERE CAST(SUBSTR(f.FechaEmision, 1, 4) AS INTEGER) = ? " + ;
      "AND f.Estado != 'Anulada' AND c.TipoCliente = 1")
   sqlite3_bind_int(stmt, 1, nEjercicio)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cNifOp := sqlite3_column_text(stmt, 0)
      IF Empty(cNifOp); cNifOp := "00000000Z"; ENDIF
      nTotal := Val(sqlite3_column_text(stmt, 2))
      oOp := BuscarOp349(aEntregas, cNifOp)
      IF oOp == NIL
         oOp := { cNifOp, sqlite3_column_text(stmt, 1), 0 }
         AAdd(aEntregas, oOp)
      ENDIF
      oOp[3] := oOp[3] + nTotal
   ENDDO
   sqlite3_finalize(stmt)

   stmt := sqlite3_prepare(db, ;
      "SELECT p.Nif, p.Nombre, CAST(g.BaseImponible AS REAL) " + ;
      "FROM Gastos g LEFT JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "LEFT JOIN Paises pa ON p.PaisId = pa.Id " + ;
      "WHERE CAST(SUBSTR(g.FechaEmision, 1, 4) AS INTEGER) = ? AND pa.EsUE = 1")
   sqlite3_bind_int(stmt, 1, nEjercicio)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      cNifOp := sqlite3_column_text(stmt, 0)
      IF Empty(cNifOp); cNifOp := "00000000Z"; ENDIF
      nTotal := Val(sqlite3_column_text(stmt, 2))
      oOp := BuscarOp349(aAdquis, cNifOp)
      IF oOp == NIL
         oOp := { cNifOp, sqlite3_column_text(stmt, 1), 0 }
         AAdd(aAdquis, oOp)
      ENDIF
      oOp[3] := oOp[3] + nTotal
   ENDDO
   sqlite3_finalize(stmt)

   ASort(aEntregas, , , {|x, y| x[1] < y[1]})
   ASort(aAdquis, , , {|x, y| x[1] < y[1]})

   cDir := hb_GetEnv("HOME") + "/Facturas/modelos349"
   hb_DirBuild(cDir)
   cPath := cDir + "/" + AllTrim(cNif) + "_" + LTrim(Str(nEjercicio)) + ".349"
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
   nCount := Len(aEntregas) + Len(aAdquis)
   cBuffer := RellenarBuffer(cBuffer, 97, PadL(LTrim(Str(nCount)), 5, "0"))
   EscribirLinea(hFile, cBuffer)

   FOR nI := 1 TO Len(aEntregas)
      oOp := aEntregas[nI]
      cBuffer := Buffer1500()
      cBuffer := RellenarBuffer(cBuffer, 1, "2")
      cBuffer := RellenarBuffer(cBuffer, 2, PadR(oOp[1], 9))
      cBuffer := RellenarBuffer(cBuffer, 11, PadR(oOp[2], 80))
      cBuffer := RellenarBuffer(cBuffer, 91, "E")
      cBuffer := RellenarBuffer(cBuffer, 92, FormatearImporte(oOp[3]))
      EscribirLinea(hFile, cBuffer)
   NEXT

   FOR nI := 1 TO Len(aAdquis)
      oOp := aAdquis[nI]
      cBuffer := Buffer1500()
      cBuffer := RellenarBuffer(cBuffer, 1, "2")
      cBuffer := RellenarBuffer(cBuffer, 2, PadR(oOp[1], 9))
      cBuffer := RellenarBuffer(cBuffer, 11, PadR(oOp[2], 80))
      cBuffer := RellenarBuffer(cBuffer, 91, "A")
      cBuffer := RellenarBuffer(cBuffer, 92, FormatearImporte(oOp[3]))
      EscribirLinea(hFile, cBuffer)
   NEXT

   FClose(hFile)

   RETURN { ;
      "Ejercicio", nEjercicio, ;
      "Nif", cNif, ;
      "RazonSocial", cRazon, ;
      "TotalEntregas", Len(aEntregas), ;
      "TotalAdquisiciones", Len(aAdquis), ;
      "TotalOperaciones", nCount, ;
      "Fichero", cPath }

STATIC FUNCTION BuscarOp349(aList, cNif)
   LOCAL nI
   FOR nI := 1 TO Len(aList)
      IF aList[nI][1] == cNif
         RETURN aList[nI]
      ENDIF
   NEXT
   RETURN NIL
