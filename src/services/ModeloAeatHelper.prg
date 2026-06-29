FUNCTION FormatearImporte(nVal)
   LOCAL nCent := RoundFiscal(nVal) * 100
   RETURN PadL(AllTrim(Str(Int(nCent + 0.5))), 17, "0")

FUNCTION FormatearNumero(nVal)
   RETURN FormatearImporte(Abs(nVal))

FUNCTION FormatearNSigno(nVal)
   LOCAL cSigno := Iif(nVal < 0, "N", " ")
   RETURN cSigno + PadL(AllTrim(Str(Int(Abs(RoundFiscal(nVal)) * 100 + 0.5))), 16, "0")

FUNCTION ObtenerRangoTrimestre(nEjercicio, nTrim)
   LOCAL dInicio, dFin
   SWITCH nTrim
   CASE 1
      dInicio := hb_Date(nEjercicio, 1, 1)
      dFin := hb_Date(nEjercicio, 3, 31)
      EXIT
   CASE 2
      dInicio := hb_Date(nEjercicio, 4, 1)
      dFin := hb_Date(nEjercicio, 6, 30)
      EXIT
   CASE 3
      dInicio := hb_Date(nEjercicio, 7, 1)
      dFin := hb_Date(nEjercicio, 9, 30)
      EXIT
   CASE 4
      dInicio := hb_Date(nEjercicio, 10, 1)
      dFin := hb_Date(nEjercicio, 12, 31)
      EXIT
   ENDSWITCH
   RETURN { FechaISO8601(dInicio), FechaISO8601(dFin) }

FUNCTION EscribirLinea(hFile, cBuffer)
   FWrite(hFile, cBuffer + Chr(13) + Chr(10))
RETURN NIL

FUNCTION Buffer1500()
   RETURN Space(1500)

FUNCTION RellenarBuffer(cBuffer, nStart, cVal)
   LOCAL nLen := Len(cVal)
   IF nStart + nLen - 1 <= Len(cBuffer)
      cBuffer := Stuff(cBuffer, nStart, nLen, cVal)
   ENDIF
   RETURN cBuffer

FUNCTION FormatearLinea111(nNifLen, cNif, cNombre, nTotalLen, nTotalCent, nBase, nRetencion)
   RETURN NIL

FUNCTION ObtenerConfigAeat(db)
   LOCAL aCfg := { ;
      ObtenerConfiguracion(db, "Empresa.Nif"), ;
      ObtenerConfiguracion(db, "Empresa.Nombre"), ;
      ObtenerConfiguracion(db, "VeriFactu.NombreSistemaInformatico"), ;
      ObtenerConfiguracion(db, "VeriFactu.NifDesarrollo"), ;
      ObtenerConfiguracion(db, "VeriFactu.VersionSIF") }
   IF aCfg[3] == NIL; aCfg[3] := "Facturas"; ENDIF
   IF aCfg[4] == NIL; aCfg[4] := aCfg[1]; ENDIF
   IF aCfg[5] == NIL; aCfg[5] := "1.0.0"; ENDIF
   RETURN aCfg
