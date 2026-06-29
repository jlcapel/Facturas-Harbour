FUNCTION GenerarCsvGastos(db, nYear)
   LOCAL stmt, aGastos := {}, cCsv, nI, aG
   LOCAL cNifProv, cNomProv, cCat, cPagado, cNFactura

   stmt := sqlite3_prepare(db, ;
      "SELECT g.NumeroFactura, g.NumeroRecepcion, g.FechaEmision, " + ;
      "p.Nif, p.Nombre, g.Descripcion, " + ;
      "CAST(g.BaseImponible AS REAL), CAST(g.IvaPorcentaje AS REAL), " + ;
      "CAST(g.IvaImporte AS REAL), CAST(g.RetencionPorcentaje AS REAL), " + ;
      "CAST(g.RetencionImporte AS REAL), CAST(g.Total AS REAL), " + ;
      "g.GastoDeducibleIRPF, cg.Nombre, g.Pagado, g.MedioPago " + ;
      "FROM Gastos g " + ;
      "JOIN Proveedores p ON g.ProveedorId = p.Id " + ;
      "LEFT JOIN CategoriasGasto cg ON g.CategoriaGastoId = cg.Id " + ;
      "WHERE CAST(strftime('%Y', g.FechaEmision) AS INTEGER) = ? " + ;
      "ORDER BY g.FechaEmision")
   sqlite3_bind_int(stmt, 1, nYear)
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aGastos, { ;
         sqlite3_column_text(stmt, 0), ;
         sqlite3_column_int(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_text(stmt, 11), ;
         sqlite3_column_text(stmt, 12), ;
         sqlite3_column_text(stmt, 13), ;
         sqlite3_column_int(stmt, 14) != 0, ;
         sqlite3_column_int(stmt, 15) })
   ENDDO
   sqlite3_finalize(stmt)

   cCsv := "NºFactura;FechaEmisión;NIF;Proveedor;Descripción;BaseImponible;Iva%;IVA;Ret%Iva;RetIva;Total;GastoDeducible;Categoría;Pagado;TipoPago" + hb_eol()

   FOR nI := 1 TO Len(aGastos)
      aG := aGastos[nI]
      cNifProv := aG[4]; cNomProv := aG[5]; cCat := aG[14]
      cPagado := Iif(aG[15], "Sí", "No")
      cNFactura := aG[1]
      IF aG[2] != 0 .AND. Empty(cNFactura)
         cNFactura := "R" + StrZero(aG[2], 4)
      ENDIF
      cCsv += EscaparCsv(cNFactura) + ";" + ;
         EscaparCsv(aG[3]) + ";" + ;
         EscaparCsv(cNifProv) + ";" + ;
         EscaparCsv(cNomProv) + ";" + ;
         EscaparCsv(aG[6]) + ";" + ;
         StrTran(aG[7], ".", ",") + ";" + ;
         StrTran(aG[8], ".", ",") + ";" + ;
         StrTran(aG[9], ".", ",") + ";" + ;
         StrTran(aG[10], ".", ",") + ";" + ;
         StrTran(aG[11], ".", ",") + ";" + ;
         StrTran(aG[12], ".", ",") + ";" + ;
         StrTran(aG[13], ".", ",") + ";" + ;
         EscaparCsv(cCat) + ";" + ;
         cPagado + ";" + ;
         hb_ntos(aG[16]) + hb_eol()
   NEXT

   RETURN cCsv

STATIC FUNCTION EscaparCsv(cVal)
   IF cVal == NIL; RETURN ""; ENDIF
   IF At(";", cVal) > 0 .OR. At('"', cVal) > 0 .OR. At(hb_eol(), cVal) > 0
      cVal := StrTran(cVal, '"', '""')
      cVal := '"' + cVal + '"'
   ENDIF
   RETURN cVal

STATIC FUNCTION StrZero(nNum, nLen)
   LOCAL cStr := hb_ntos(nNum)
   RETURN Replicate("0", Max(0, nLen - Len(cStr))) + cStr

FUNCTION GuardarCsvGastos(db, nYear)
   LOCAL cDir := ObtenerExportDir(), cPath, cCsv, cFile
   hb_DirBuild(cDir)
   cFile := "Gastos_" + hb_ntos(nYear) + ".csv"
   cPath := cDir + "/" + cFile
   cCsv := GenerarCsvGastos(db, nYear)
   hb_MemoWrit(cPath, cCsv)
   LogInfo("CSV gastos exportado: " + cPath)
   RETURN cPath

FUNCTION GuardarXmlRegistros(db)
   LOCAL cDir := ObtenerExportDir(), cPath, cXml
   hb_DirBuild(cDir)
   cPath := cDir + "/RegistrosAEAT.xml"
   cXml := ExportarRegistrosAEAT(db)
   hb_MemoWrit(cPath, cXml)
   RETURN cPath

FUNCTION GuardarXmlEventos(db)
   LOCAL cDir := ObtenerExportDir(), cPath, cXml
   hb_DirBuild(cDir)
   cPath := cDir + "/Eventos.xml"
   cXml := ExportarEventos(db)
   hb_MemoWrit(cPath, cXml)
   RETURN cPath

FUNCTION ObtenerExportDir()
   RETURN hb_GetEnv("HOME") + "/.local/share/Facturas/export"
