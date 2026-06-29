#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION GenerarModelo390(db, nEjercicio)
   LOCAL cFechaIni := Str(nEjercicio, 4) + "-01-01"
   LOCAL cFechaFin := Str(nEjercicio, 4) + "-12-31"
   LOCAL nB21 := 0, nC21 := 0, nB10 := 0, nC10 := 0, nB04 := 0, nC04 := 0, nBEx := 0
   LOCAL nBDed := 0, nCDed := 0, nTotDev, nTotDed, nResul
   LOCAL stmt, aCfg := ObtenerConfigAeat(db)
   LOCAL cNif := aCfg[1], cRazon := aCfg[2], cSis := aCfg[3], cNifDev := aCfg[4], cVer := aCfg[5]
   LOCAL cDir, cPath, hFile, cContenido, nPct, nImp

   stmt := sqlite3_prepare(db, ;
      "SELECT CAST(l.Importe AS REAL), CAST(l.IvaPorcentaje AS REAL) " + ;
      "FROM Facturas f INNER JOIN LineasFactura l ON f.Id = l.FacturaId " + ;
      "WHERE f.FechaEmision >= ? AND f.FechaEmision <= ? AND f.Estado != 'Anulada'")
   sqlite3_bind_text(stmt, 1, cFechaIni)
   sqlite3_bind_text(stmt, 2, cFechaFin)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nImp := Val(sqlite3_column_text(stmt, 0))
      nPct := Val(sqlite3_column_text(stmt, 1))
      IF Abs(nPct - 21) < 0.01
         nB21 := nB21 + nImp; nC21 := nC21 + nImp * nPct / 100
      ELSEIF Abs(nPct - 10) < 0.01
         nB10 := nB10 + nImp; nC10 := nC10 + nImp * nPct / 100
      ELSEIF Abs(nPct - 4) < 0.01
         nB04 := nB04 + nImp; nC04 := nC04 + nImp * nPct / 100
      ELSEIF nPct == 0
         nBEx := nBEx + nImp
      ENDIF
   ENDDO
   sqlite3_finalize(stmt)
   nB21 := RoundFiscal(nB21); nC21 := RoundFiscal(nC21)
   nB10 := RoundFiscal(nB10); nC10 := RoundFiscal(nC10)
   nB04 := RoundFiscal(nB04); nC04 := RoundFiscal(nC04)
   nBEx := RoundFiscal(nBEx)

   stmt := sqlite3_prepare(db, ;
      "SELECT CAST(BaseImponible AS REAL), CAST(IvaImporte AS REAL) " + ;
      "FROM Gastos WHERE FechaEmision >= ? AND FechaEmision <= ? AND IVADeducible = 1")
   sqlite3_bind_text(stmt, 1, cFechaIni)
   sqlite3_bind_text(stmt, 2, cFechaFin)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nBDed := nBDed + Val(sqlite3_column_text(stmt, 0))
      nCDed := nCDed + Val(sqlite3_column_text(stmt, 1))
   ENDDO
   sqlite3_finalize(stmt)
   nBDed := RoundFiscal(nBDed); nCDed := RoundFiscal(nCDed)

   nTotDev := RoundFiscal(nC21 + nC10 + nC04)
   nTotDed := RoundFiscal(nCDed)
   nResul := RoundFiscal(nTotDev - nTotDed)

   cDir := hb_GetEnv("HOME") + "/Facturas/modelos390"
   hb_DirBuild(cDir)
   cPath := cDir + "/" + AllTrim(cNif) + "_" + LTrim(Str(nEjercicio)) + ".390"
   cContenido := GenerarFichero390(nEjercicio, cNif, cRazon, cSis, cNifDev, cVer, ;
      nB21, nC21, nB10, nC10, nB04, nC04, nBEx, nBDed, nCDed, nTotDev, nTotDed, nResul)
   hFile := FCreate(cPath, 0)
   FWrite(hFile, cContenido)
   FClose(hFile)

   RETURN { ;
      "Ejercicio", nEjercicio, ;
      "Nif", cNif, ;
      "RazonSocial", cRazon, ;
      "Base21", nB21, "Cuota21", nC21, ;
      "Base10", nB10, "Cuota10", nC10, ;
      "Base04", nB04, "Cuota04", nC04, ;
      "BaseExenta", nBEx, ;
      "BaseDeducible", nBDed, "CuotaDeducible", nCDed, ;
      "TotalDevengado", nTotDev, "TotalDeducible", nTotDed, ;
      "Resultado", nResul, ;
      "Fichero", cPath }

STATIC FUNCTION GenerarFichero390(nEjer, cNif, cRazon, cSis, cNifDev, cVer, ;
   nB21, nC21, nB10, nC10, nB04, nC04, nBEx, nBDed, nCDed, nTotDev, nTotDed, nRes)
   LOCAL cRes := ""
   cRes += GenEncab390(nEjer, cNif, cRazon, cSis, cNifDev, cVer) + Chr(13) + Chr(10)
   cRes += GenP01000390(nEjer, cNif, cRazon) + Chr(13) + Chr(10)
   cRes += GenP03000390(nB21, nC21, nB10, nC10, nB04, nC04, nBEx, nBDed, nCDed, nTotDev, nTotDed) + Chr(13) + Chr(10)
   cRes += GenP04000390(nTotDev, nTotDed, nRes) + Chr(13) + Chr(10)
   cRes += GenPie390(nEjer) + Chr(13) + Chr(10)
   RETURN cRes

STATIC FUNCTION GenEncab390(nEjer, cNif, cRazon, cSis, cNifDev, cVer)
   LOCAL cAux, cEnc
   cEnc := "<T3030" + PadL(LTrim(Str(nEjer)), 4, "0") + "000000>"
   cAux := "0200000000>" + "04" + PadR(cVer, 5) + PadR(cNif, 9) + PadR(cSis, 40) + PadR(cNifDev, 9)
   cEnc += "<AUX>" + PadR(cAux, 213) + "</AUX>"
   RETURN cEnc

STATIC FUNCTION GenP01000390(nEjer, cNif, cRazon)
   LOCAL cPag := "<T30301000>" + Space(1900 - Len("<T30301000>"))
   cPag := RellenarBuffer(cPag, 12, PadR(cNif, 9))
   cPag := RellenarBuffer(cPag, 21, PadR(cRazon, 40))
   cPag := RellenarBuffer(cPag, 61, LTrim(Str(nEjer)))
   cPag := RellenarBuffer(cPag, 65, "00")
   cPag := RellenarBuffer(cPag, 67, "I")
   cPag := RellenarBuffer(cPag, 68, PadR(cNif, 9))
   cPag := RellenarBuffer(cPag, 77, PadR(cRazon, 40))
   cPag := RellenarBuffer(cPag, 1889, "</T30301000>")
   RETURN Left(cPag, 1900)

STATIC FUNCTION GenP03000390(nB21, nC21, nB10, nC10, nB04, nC04, nBEx, nBDed, nCDed, nTotDev, nTotDed)
   LOCAL cPag := "<T30303000>" + Space(2565 - Len("<T30303000>"))
   cPag := RellenarBuffer(cPag, 29, FormatearNumero(nB21))
   cPag := RellenarBuffer(cPag, 63, FormatearNumero(nC21))
   cPag := RellenarBuffer(cPag, 97, FormatearNumero(nB10))
   cPag := RellenarBuffer(cPag, 131, FormatearNumero(nC10))
   cPag := RellenarBuffer(cPag, 165, FormatearNumero(nB04))
   cPag := RellenarBuffer(cPag, 199, FormatearNumero(nC04))
   cPag := RellenarBuffer(cPag, 233, FormatearNumero(nBEx))
   cPag := RellenarBuffer(cPag, 850, FormatearNumero(nBDed))
   cPag := RellenarBuffer(cPag, 867, FormatearNumero(nCDed))
   cPag := RellenarBuffer(cPag, 1425, FormatearNumero(nTotDev))
   cPag := RellenarBuffer(cPag, 1492, FormatearNumero(nTotDed))
   cPag := RellenarBuffer(cPag, 2554, "</T30303000>")
   RETURN Left(cPag, 2565)

STATIC FUNCTION GenP04000390(nTotDev, nTotDed, nRes)
   LOCAL nSuma := RoundFiscal(nTotDev - nTotDed)
   LOCAL cPag := "<T30304000>" + Space(1595 - Len("<T30304000>"))
   cPag := RellenarBuffer(cPag, 15, FormatearNumero(0))
   cPag := RellenarBuffer(cPag, 32, Space(6))
   cPag := RellenarBuffer(cPag, 440, FormatearNSigno(nSuma))
   cPag := RellenarBuffer(cPag, 491, FormatearNSigno(nSuma))
   IF nSuma > 0
      cPag := RellenarBuffer(cPag, 525, FormatearNSigno(nSuma))
   ENDIF
   IF nSuma < 0
      cPag := RellenarBuffer(cPag, 559, FormatearNSigno(-nSuma))
   ENDIF
   cPag := RellenarBuffer(cPag, 593, FormatearNSigno(nSuma))
   cPag := RellenarBuffer(cPag, 1583, "</T30304000>")
   RETURN Left(cPag, 1595)

STATIC FUNCTION GenPie390(nEjer)
   RETURN "</T3030" + PadL(LTrim(Str(nEjer)), 4, "0") + "000000>"
