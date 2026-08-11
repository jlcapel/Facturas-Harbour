#include "hwgui.ch"

FUNCTION TiposIvaView(db, oParent, nX, nY, nW, nH)
   LOCAL oBrw, aData

   aData := ObtenerTiposIva(db)

   @ nX+20, nY+20 BROWSE oBrw ARRAY SIZE nW-40, nH-90 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL OF oParent

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("TiposIvaNombre"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New(L("TiposIvaPctHeader"), {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 10, 0, .F., DT_RIGHT))
   oBrw:AddColumn(HColumn():New(L("TiposIvaCalificacionOperacion"), {|v,o| (v), o:aArray[o:nCurrent, 9]}, "C", 8, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("TiposIvaActivo"), {|v,o| (v), iif(o:aArray[o:nCurrent, 4], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))
   oBrw:AddColumn(HColumn():New(L("TiposIvaDesde"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 14, 0, .F., DT_CENTER))

   @ nX+30, nY+nH-55 BUTTON L("TiposIvaNuevo") SIZE 70, 28 OF oParent ON CLICK {|| TipoIvaNuevo(db, @aData, oBrw)}
   @ nX+110, nY+nH-55 BUTTON L("TiposIvaEditar") SIZE 70, 28 OF oParent ON CLICK {|| TipoIvaEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ nX+190, nY+nH-55 BUTTON L("TiposIvaEliminar") SIZE 70, 28 OF oParent ON CLICK {|| TipoIvaEliminar(db, @aData, oBrw)}
   @ nX+270, nY+nH-55 BUTTON L("TiposIvaBtnPdf") SIZE 50, 28 OF oParent ON CLICK {|| ExportPdfTiposIva(db, aData)}
RETURN NIL

STATIC FUNCTION TipoIvaNuevo(db, aData, oBrw)
   LOCAL oDlg, cNombre := Space(30), cPorcentaje := Space(6), lCancel := .F.
   LOCAL cImpuesto := "01", cClaveRegimen := "01", cDescripcionFiscal := Space(120)
   LOCAL aCalificaciones := ObtenerCalificacionesIva(), nCalificacionSel := 1

   INIT DIALOG oDlg TITLE L("TiposIvaTitleNuevo") AT 0,0 SIZE 500, 320 STYLE DS_CENTER

   @ 20, 20 SAY L("TiposIvaNombreLabel") SIZE 80, 22
   @ 150, 18 GET cNombre SIZE 300, 26
   @ 20, 55 SAY L("TiposIvaPorcentajeLabel") SIZE 80, 22
   @ 150, 53 GET cPorcentaje SIZE 100, 26 PICTURE "99.99"
   @ 20, 90 SAY L("TiposIvaImpuestoLabel") SIZE 120, 22
   @ 150, 88 GET cImpuesto SIZE 60, 26
   @ 20, 125 SAY L("TiposIvaClaveRegimenLabel") SIZE 120, 22
   @ 150, 123 GET cClaveRegimen SIZE 60, 26
   @ 20, 160 SAY L("TiposIvaCalificacionLabel") SIZE 120, 22
   @ 150, 158 GET COMBOBOX nCalificacionSel ITEMS ListaNombresCalificaciones(aCalificaciones) SIZE 300, 160
   @ 20, 195 SAY L("TiposIvaDescripcionFiscalLabel") SIZE 120, 22
   @ 150, 193 GET cDescripcionFiscal SIZE 300, 50

   @ 150, 260 BUTTON L("TiposIvaGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 260, 260 BUTTON L("TiposIvaCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel .AND. !Empty(cNombre)
      GuardarTipoIva(db, 0, AllTrim(cNombre), AllTrim(cPorcentaje), .T., DToS(Date()), NIL, ;
         AllTrim(cImpuesto), AllTrim(cClaveRegimen), aCalificaciones[nCalificacionSel][5], AllTrim(cDescripcionFiscal))
      aData := ObtenerTiposIva(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION TipoIvaEditar(db, aData, oBrw, nRow)
   LOCAL aTipo, oDlg, cNombre, cPorcentaje, lCancel := .F.
   LOCAL cImpuesto, cClaveRegimen, cDescripcionFiscal, aCalificaciones, nCalificacionSel

   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("TiposIvaMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF

   aTipo := aData[nRow]
   cNombre := PadR(aTipo[2], 30)
   cPorcentaje := PadR(aTipo[3], 6)
   cImpuesto := PadR(aTipo[7], 2)
   cClaveRegimen := PadR(aTipo[8], 2)
   cDescripcionFiscal := PadR(Iif(aTipo[10] == NIL, "", aTipo[10]), 120)
   aCalificaciones := ObtenerCalificacionesIva()
   nCalificacionSel := BuscarIndiceCalificacion(aCalificaciones, aTipo[9])

   INIT DIALOG oDlg TITLE L("TiposIvaTitleEditar") AT 0,0 SIZE 500, 320 STYLE DS_CENTER

   @ 20, 20 SAY L("TiposIvaNombreLabel") SIZE 80, 22
   @ 150, 18 GET cNombre SIZE 300, 26
   @ 20, 55 SAY L("TiposIvaPorcentajeLabel") SIZE 80, 22
   @ 150, 53 GET cPorcentaje SIZE 100, 26 PICTURE "99.99"
   @ 20, 90 SAY L("TiposIvaImpuestoLabel") SIZE 120, 22
   @ 150, 88 GET cImpuesto SIZE 60, 26
   @ 20, 125 SAY L("TiposIvaClaveRegimenLabel") SIZE 120, 22
   @ 150, 123 GET cClaveRegimen SIZE 60, 26
   @ 20, 160 SAY L("TiposIvaCalificacionLabel") SIZE 120, 22
   @ 150, 158 GET COMBOBOX nCalificacionSel ITEMS ListaNombresCalificaciones(aCalificaciones) SIZE 300, 160
   @ 20, 195 SAY L("TiposIvaDescripcionFiscalLabel") SIZE 120, 22
   @ 150, 193 GET cDescripcionFiscal SIZE 300, 50

   @ 150, 260 BUTTON L("TiposIvaGuardar") SIZE 80, 28 ON CLICK {|| oDlg:Close()}
   @ 260, 260 BUTTON L("TiposIvaCancelar") SIZE 80, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF !lCancel
      GuardarTipoIva(db, aTipo[1], AllTrim(cNombre), AllTrim(cPorcentaje), .T., aTipo[5], aTipo[6], ;
         AllTrim(cImpuesto), AllTrim(cClaveRegimen), aCalificaciones[nCalificacionSel][5], AllTrim(cDescripcionFiscal))
      aData := ObtenerTiposIva(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ExportPdfTiposIva(db, aData)
   LOCAL aCols := { ;
      {L("TiposIvaNombre"), 200, 2}, ;
      {L("TiposIvaPctHeader"), 80, 3, .T.}, ;
      {L("TiposIvaCalificacionOperacion"), 60, 9}, ;
      {L("TiposIvaActivo"), 50, 4, .T.}, ;
      {L("TiposIvaDesde"), 120, 5} }
   LOCAL cPath := AbrirListadoPdf(db, L("TiposIvaTitlePage"), aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo(StrTran(L("TiposIvaMsgPdfGenerado"), "{1}", cPath), L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION TipoIvaEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo(L("TiposIvaMsgSeleccione"), L("CommonAviso"))
      RETURN
   ENDIF
   IF hwg_MsgYesNo(StrTran(L("TiposIvaMsgEliminar"), "{1}", aData[nRow][2]), L("CommonConfirmar"))
      aData := ObtenerTiposIva(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ObtenerCalificacionesIva()
   LOCAL aTratamientos := ObtenerTratamientosIva(), aCalificaciones := {}, nI

   FOR nI := 1 TO Len(aTratamientos)
      IF aTratamientos[nI][5] != NIL
         AAdd(aCalificaciones, aTratamientos[nI])
      ENDIF
   NEXT
RETURN aCalificaciones

STATIC FUNCTION ListaNombresCalificaciones(aCalificaciones)
   LOCAL aNombres := {}, nI

   FOR nI := 1 TO Len(aCalificaciones)
      AAdd(aNombres, aCalificaciones[nI][2])
   NEXT
RETURN aNombres

STATIC FUNCTION BuscarIndiceCalificacion(aCalificaciones, cCodigo)
   LOCAL nIndice := AScan(aCalificaciones, {|a| a[5] == cCodigo})

   IF nIndice == 0
      nIndice := 1
   ENDIF
RETURN nIndice
