#require "hbsqlit3"
#include "hbsqlit3.ch"

FUNCTION GenerarModelo130(db, nEjercicio, nTrimestre)
   LOCAL aRango := ObtenerRangoTrimestre(nEjercicio, nTrimestre)
   LOCAL cFechaIni := aRango[1], cFechaFin := aRango[2]
   LOCAL nIngresos := 0, nGastos := 0, nRendimiento, nPctRet, nResultado
   LOCAL stmt, aCfg := ObtenerConfigAeat(db)
   LOCAL cNif := aCfg[1], cRazon := aCfg[2], cSis := aCfg[3], cNifDev := aCfg[4], cVer := aCfg[5]
   LOCAL cDir, cPath, hFile, cContenido, cPctStr

   stmt := sqlite3_prepare(db, ;
      "SELECT CAST(BaseImponible AS REAL) FROM Facturas WHERE FechaEmision >= ? " + ;
      "AND FechaEmision <= ? AND Estado != 'Anulada'")
   sqlite3_bind_text(stmt, 1, cFechaIni)
   sqlite3_bind_text(stmt, 2, cFechaFin)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nIngresos := nIngresos + Val(sqlite3_column_text(stmt, 0))
   ENDDO
   sqlite3_finalize(stmt)
   nIngresos := RoundFiscal(nIngresos)

   stmt := sqlite3_prepare(db, ;
      "SELECT CAST(g.BaseImponible AS REAL), CAST(cg.PorcentajeDeducibleIRPF AS REAL) " + ;
      "FROM Gastos g LEFT JOIN CategoriasGasto cg ON g.CategoriaGastoId = cg.Id " + ;
      "WHERE g.FechaEmision >= ? AND g.FechaEmision <= ?")
   sqlite3_bind_text(stmt, 1, cFechaIni)
   sqlite3_bind_text(stmt, 2, cFechaFin)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      nGastos := nGastos + Val(sqlite3_column_text(stmt, 0)) * Val(sqlite3_column_text(stmt, 1)) / 100
   ENDDO
   sqlite3_finalize(stmt)
   nGastos := RoundFiscal(nGastos)

   nRendimiento := RoundFiscal(nIngresos - nGastos)

   cPctStr := ObtenerConfiguracion(db, "IRPF.Porcentaje")
   nPctRet := Val(cPctStr)
   IF nPctRet == 0; nPctRet := 20; ENDIF
   nResultado := 0
   IF nRendimiento > 0
      nResultado := RoundFiscal(nRendimiento * nPctRet / 100)
   ENDIF

   cDir := hb_GetEnv("HOME") + "/Facturas/modelos130"
   hb_DirBuild(cDir)
   cPath := cDir + "/" + AllTrim(cNif) + "_" + LTrim(Str(nEjercicio)) + "_" + LTrim(Str(nTrimestre)) + "T.130"
   cContenido := GenerarFichero130(nEjercicio, nTrimestre, cNif, cRazon, cSis, cNifDev, cVer, ;
      nIngresos, nGastos, nRendimiento, nPctRet, nResultado)
   hFile := FCreate(cPath, 0)
   FWrite(hFile, cContenido)
   FClose(hFile)

   RETURN { ;
      "Ejercicio", nEjercicio, ;
      "Trimestre", nTrimestre, ;
      "Nif", cNif, ;
      "RazonSocial", cRazon, ;
      "Ingresos", nIngresos, ;
      "GastosDeducibles", nGastos, ;
      "RendimientoNeto", nRendimiento, ;
      "PorcentajeRetencion", nPctRet, ;
      "Resultado", nResultado, ;
      "Fichero", cPath }

STATIC FUNCTION GenerarFichero130(nEjer, nTrim, cNif, cRazon, cSis, cNifDev, cVer, ;
   nIng, nGas, nRend, nPct, nRes)
   LOCAL cRes := ""
   cRes += GenerarEncabezado130(nEjer, nTrim, cNif, cRazon, cSis, cNifDev, cVer) + Chr(13) + Chr(10)
   cRes += GenerarP01000130(nEjer, nTrim, cNif, cRazon) + Chr(13) + Chr(10)
   cRes += GenerarP02000130(nIng, nGas, nRend, nPct, nRes) + Chr(13) + Chr(10)
   cRes += GenerarPie130(nEjer, nTrim) + Chr(13) + Chr(10)
   RETURN cRes

STATIC FUNCTION GenerarEncabezado130(nEjer, nTrim, cNif, cRazon, cSis, cNifDev, cVer)
   LOCAL cAux, cEnc
   cEnc := "<T3030" + PadL(LTrim(Str(nEjer)), 4, "0") + PadL(LTrim(Str(nTrim)), 2, "0") + "0000>"
   cAux := "0100000000>" + "03" + PadR(cVer, 5) + PadR(cNif, 9) + PadR(cSis, 40) + PadR(cNifDev, 9)
   cEnc += "<AUX>" + PadR(cAux, 213) + "</AUX>"
   RETURN cEnc

STATIC FUNCTION GenerarP01000130(nEjer, nTrim, cNif, cRazon)
   LOCAL cPag := "<T30301000>" + Space(1900 - Len("<T30301000>"))
   cPag := RellenarBuffer(cPag, 12, PadR(cNif, 9))
   cPag := RellenarBuffer(cPag, 21, PadR(cRazon, 40))
   cPag := RellenarBuffer(cPag, 61, LTrim(Str(nEjer)))
   cPag := RellenarBuffer(cPag, 65, PadL(LTrim(Str(nTrim)), 2, "0"))
   cPag := RellenarBuffer(cPag, 67, "I")
   cPag := RellenarBuffer(cPag, 68, PadR(cNif, 9))
   cPag := RellenarBuffer(cPag, 77, PadR(cRazon, 40))
   cPag := RellenarBuffer(cPag, 1889, "</T30301000>")
   RETURN Left(cPag, 1900)

STATIC FUNCTION GenerarP02000130(nIng, nGas, nRend, nPct, nRes)
   LOCAL cPag := "<T30302000>" + Space(1017 - Len("<T30302000>"))
   cPag := RellenarBuffer(cPag, 29, FormatearNumero(nIng))
   cPag := RellenarBuffer(cPag, 63, FormatearNumero(nGas))
   cPag := RellenarBuffer(cPag, 97, FormatearNumero(Max(0, nRend)))
   cPag := RellenarBuffer(cPag, 131, FormatearNumero(nPct))
   cPag := RellenarBuffer(cPag, 165, FormatearNumero(nRes))
   cPag := RellenarBuffer(cPag, 1006, "</T30302000>")
   RETURN Left(cPag, 1017)

STATIC FUNCTION GenerarPie130(nEjer, nTrim)
   RETURN "</T3030" + PadL(LTrim(Str(nEjer)), 4, "0") + PadL(LTrim(Str(nTrim)), 2, "0") + "0000>"
