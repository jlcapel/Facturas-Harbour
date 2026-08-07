#include "hwgui.ch"

FUNCTION FacturasView(db, oParent, nX, nY, nW, nH)
   LOCAL oBrw, aData

   aData := ObtenerFacturas(db)

   @ nX+20, nY+20 BROWSE oBrw ARRAY SIZE nW-40, nH-90 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL OF oParent

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("FacturasNroFacturaHead"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("FacturasFechaHead"), {|v,o| (v), DToC(o:aArray[o:nCurrent, 3])}, "C", 12, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("FacturasCliente"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New(L("FacturasTipoHead"), {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 6, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("CommonBase"), {|v,o| (v), Str(o:aArray[o:nCurrent, 6], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("FacturasTotalLinea"), {|v,o| (v), Str(o:aArray[o:nCurrent, 7], 10, 2)}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("FacturasEstadoHead"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 8] == 0, "Emitida", "Anulada")}, "C", 10, 0, .F., DT_CENTER))

   @ nX+30, nY+nH-55 BUTTON "Nueva" SIZE 70, 28 OF oParent ON CLICK {|| FacturaNueva(db, @aData, oBrw)}
   @ nX+110, nY+nH-55 BUTTON L("CommonEditar") SIZE 70, 28 OF oParent ON CLICK {|| FacturaEditar(db, @aData, oBrw)}
   @ nX+190, nY+nH-55 BUTTON L("FacturasImprimir") SIZE 70, 28 OF oParent ON CLICK {|| FacturaImprimir(db, aData, oBrw)}
   @ nX+270, nY+nH-55 BUTTON L("FacturasAnular") SIZE 70, 28 OF oParent ON CLICK {|| FacturaAnular(db, @aData, oBrw)}
RETURN NIL

STATIC FUNCTION FacturaNueva(db, aData, oBrw)
   LOCAL nId := FacturaCrearDialog(db, 0)
   IF nId > 0
      aData := ObtenerFacturas(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaEditar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL nId
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione una factura", "Aviso")
      RETURN
   ENDIF
   nId := FacturaCrearDialog(db, aData[nRow][1])
   IF nId > 0
      aData := ObtenerFacturas(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION FacturaAnular(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL nFacturaId, cNumFactura, dFechaEmision, nBaseImponible, nIvaImporte
   LOCAL cNifEmisor, cNumFacturaAnulacion, lAnulacion
   LOCAL stmt

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione una factura", "Aviso")
      RETURN
   ENDIF
   IF aData[nRow][8] != 0
      hwg_MsgInfo(L("ServiceFacturaYaAnulada"), "Aviso")
      RETURN
   ENDIF

   nFacturaId := aData[nRow][1]
   cNumFactura := aData[nRow][2]

   // Obtener datos de la factura original para la anulación
   stmt := sqlite3_prepare(db, ;
      "SELECT FechaEmision, BaseImponible, IvaImporte FROM Facturas WHERE Id = ?")
   sqlite3_bind_int(stmt, 1, nFacturaId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      dFechaEmision := sqlite3_column_text(stmt, 1)
      nBaseImponible := sqlite3_column_double(stmt, 2)
      nIvaImporte := sqlite3_column_double(stmt, 3)
   ENDIF
   sqlite3_finalize(stmt)

   IF hwg_MsgYesNo("¿Anular " + cNumFactura + "?", "Confirmar")
      // Anular factura (cambiar estado a 1 = Anulada)
      IF AnularFactura(db, nFacturaId)
         // Crear registro de anulación VERI*FACTU
         cNifEmisor := ObtenerConfiguracion(db, "Empresa.Nif")
         cNumFacturaAnulacion := "ANU-" + aData[nRow][2]

         lAnulacion := CrearRegistroAnulacion(db, nFacturaId, 0, ;
            cNumFacturaAnulacion, Date(), cNifEmisor, ;
            aData[nRow][6], aData[nRow][7] - aData[nRow][6] + 0, ;
            aData[nRow][2], aData[nRow][3], "F1", "Anulación voluntaria")

         IF lAnulacion
            // El envío SOAP se hace desde CrearRegistroAnulacion
         ENDIF

         // --- Evento VERI*FACTU: AnulacionFactura ---
         RegistrarEvento(db, "AnulacionFactura", "Factura " + cNumFactura + " anulada")
         // --- Fin Evento ---

         aData := ObtenerFacturas(db)
         oBrw:aArray := aData
         oBrw:Refresh()
      ENDIF
   ENDIF
RETURN NIL
STATIC FUNCTION FacturaImprimir(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   LOCAL cRuta, nId, cEntorno

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione una factura", "Aviso")
      RETURN
   ENDIF

   nId := aData[nRow][1]
   cRuta := "/tmp/Facturas/" + aData[nRow][2] + ".pdf"
   IF !hb_DirExists("/tmp/Facturas")
      hb_DirBuild("/tmp/Facturas")
   ENDIF

   cEntorno := Iif(ObtenerConfiguracion(db, "VeriFactu.Ambiente") == "2", "Preproduccion", "Produccion")
   IF GenerarPdfFactura(db, nId, cRuta, cEntorno)
      hwg_MsgInfo("PDF generado: " + cRuta, "Información")
   ELSE
      hwg_MsgInfo("Error al generar PDF", "Error")
   ENDIF
RETURN NIL
