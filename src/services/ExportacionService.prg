#include "hbsqlit3.ch"
FUNCTION ExportarRegistrosAEAT(db)
   LOCAL stmt, aRegistros := {}, cXml, nI, aReg

   stmt := sqlite3_prepare(db, ;
      "SELECT r.TipoRegistro, r.NifEmisor, r.NumeroFactura, " + ;
      "r.FechaEmision, r.BaseImponible, r.IvaImporte, r.Total, " + ;
      "r.Hash, r.HashAnterior, r.IdFacturaAnulada, r.CSV, r.FechaRegistro " + ;
      "FROM RegistrosFacturacion r ORDER BY r.Id")
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aRegistros, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5), ;
         sqlite3_column_text(stmt, 6), ;
         sqlite3_column_text(stmt, 7), ;
         sqlite3_column_text(stmt, 8), ;
         sqlite3_column_text(stmt, 9), ;
         sqlite3_column_text(stmt, 10), ;
         sqlite3_column_text(stmt, 11) })
   ENDDO
   sqlite3_finalize(stmt)

   cXml := '<?xml version="1.0" encoding="UTF-8"?>' + hb_eol()
   cXml += '<RegistroFacturacion Version="1.0">' + hb_eol()
   FOR nI := 1 TO Len(aRegistros)
      aReg := aRegistros[nI]
      cXml += '  <Registro>' + hb_eol()
      cXml += '    <TipoRegistro>' + EscaparXml(hb_ntos(aReg[1])) + '</TipoRegistro>' + hb_eol()
      cXml += '    <NIFEmisor>' + EscaparXml(aReg[2]) + '</NIFEmisor>' + hb_eol()
      cXml += '    <NumeroFactura>' + EscaparXml(aReg[3]) + '</NumeroFactura>' + hb_eol()
      cXml += '    <FechaEmision>' + EscaparXml(aReg[4]) + '</FechaEmision>' + hb_eol()
      cXml += '    <BaseImponible>' + EscaparXml(aReg[5]) + '</BaseImponible>' + hb_eol()
      cXml += '    <IVAImporte>' + EscaparXml(aReg[6]) + '</IVAImporte>' + hb_eol()
      cXml += '    <Total>' + EscaparXml(aReg[7]) + '</Total>' + hb_eol()
      cXml += '    <Hash>' + EscaparXml(aReg[8]) + '</Hash>' + hb_eol()
      IF !Empty(aReg[9])
         cXml += '    <HashAnterior>' + EscaparXml(aReg[9]) + '</HashAnterior>' + hb_eol()
      ENDIF
      IF !Empty(aReg[10])
         cXml += '    <IdFacturaAnulada>' + EscaparXml(aReg[10]) + '</IdFacturaAnulada>' + hb_eol()
      ENDIF
      cXml += '    <CSV>' + EscaparXml(aReg[11]) + '</CSV>' + hb_eol()
      cXml += '    <FechaRegistro>' + EscaparXml(aReg[12]) + '</FechaRegistro>' + hb_eol()
      cXml += '  </Registro>' + hb_eol()
   NEXT
   cXml += '</RegistroFacturacion>' + hb_eol()

   RegistrarEvento(db, 5, "Exportación registros AEAT (" + hb_ntos(Len(aRegistros)) + ")", NIL)

   RETURN cXml

FUNCTION ExportarEventos(db)
   LOCAL stmt, aEventos := {}, cXml, nI, aEv

   stmt := sqlite3_prepare(db, ;
      "SELECT TipoEvento, Descripcion, Usuario, FechaHora, Hash, HashAnterior " + ;
      "FROM RegistrosEvento ORDER BY Id")
   DO WHILE sqlite3_step(stmt) == SQLITE_ROW
      AAdd(aEventos, { ;
         sqlite3_column_int(stmt, 0), ;
         sqlite3_column_text(stmt, 1), ;
         sqlite3_column_text(stmt, 2), ;
         sqlite3_column_text(stmt, 3), ;
         sqlite3_column_text(stmt, 4), ;
         sqlite3_column_text(stmt, 5) })
   ENDDO
   sqlite3_finalize(stmt)

   cXml := '<?xml version="1.0" encoding="UTF-8"?>' + hb_eol()
   cXml += '<RegistroEventos>' + hb_eol()
   FOR nI := 1 TO Len(aEventos)
      aEv := aEventos[nI]
      cXml += '  <Evento>' + hb_eol()
      cXml += '    <Tipo>' + EscaparXml(hb_ntos(aEv[1])) + '</Tipo>' + hb_eol()
      cXml += '    <Descripcion>' + EscaparXml(aEv[2]) + '</Descripcion>' + hb_eol()
      IF !Empty(aEv[3])
         cXml += '    <Usuario>' + EscaparXml(aEv[3]) + '</Usuario>' + hb_eol()
      ENDIF
      cXml += '    <FechaHora>' + EscaparXml(aEv[4]) + '</FechaHora>' + hb_eol()
      cXml += '    <Hash>' + EscaparXml(aEv[5]) + '</Hash>' + hb_eol()
      IF !Empty(aEv[6])
         cXml += '    <HashAnterior>' + EscaparXml(aEv[6]) + '</HashAnterior>' + hb_eol()
      ENDIF
      cXml += '  </Evento>' + hb_eol()
   NEXT
   cXml += '</RegistroEventos>' + hb_eol()

   RETURN cXml

STATIC FUNCTION EscaparXml(cText)
   IF cText == NIL; RETURN ""; ENDIF
   cText := StrTran(cText, "&", "&amp;")
   cText := StrTran(cText, "<", "&lt;")
   cText := StrTran(cText, ">", "&gt;")
   cText := StrTran(cText, '"', "&quot;")
   cText := StrTran(cText, "'", "&apos;")
   RETURN cText
