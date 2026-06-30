#include "hwgui.ch"

FUNCTION ProveedoresView(db)
   LOCAL oDlg, oBrw, aData
   aData := ObtenerProveedores(db)
   INIT DIALOG oDlg TITLE L("ProveedoresTitle") AT 0,0 SIZE 800, 500 STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER
   @ 20, 20 BROWSE oBrw ARRAY SIZE 600, 400 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL
   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New(L("ProveedoresNombre"), {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New(L("ProveedoresNif"), {|v,o| (v), o:aArray[o:nCurrent, 3]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("ProveedoresPoblacion"), {|v,o| (v), o:aArray[o:nCurrent, 5]}, "C", 15, 0))
   oBrw:AddColumn(HColumn():New(L("ProveedoresTelefono"), {|v,o| (v), o:aArray[o:nCurrent, 7]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New(L("CommonActivo"), {|v,o| (v), Iif(o:aArray[o:nCurrent, 10], L("CommonSi"), L("CommonNo"))}, "C", 8, 0, .F., DT_CENTER))
   @ 30, 440 BUTTON L("ProveedoresNuevo") SIZE 70, 28 ON CLICK {|| ProvNuevo(db, @aData, oBrw)}
   @ 110, 440 BUTTON L("ProveedoresEditar") SIZE 70, 28 ON CLICK {|| ProvEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 440 BUTTON L("ProveedoresEliminar") SIZE 70, 28 ON CLICK {|| ProvEliminar(db, @aData, oBrw)}
   @ 270, 440 BUTTON "PDF" SIZE 50, 28 ON CLICK {|| ExportPdfProveedores(db, aData)}
   @ 650, 440 BUTTON L("ProveedoresVolver") SIZE 70, 28 ON CLICK {|| oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION ProvNuevo(db, aData, oBrw)
   LOCAL aR := ProvEditDialog(db, 0)
   IF aR != NIL
      GuardarProveedor(db, 0, aR[1], aR[2], aR[3], aR[4], aR[5], aR[6], aR[7], aR[8], aR[9], aR[10], aR[11], aR[12], .T.)
      aData := ObtenerProveedores(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ProvEditar(db, aData, oBrw, nRow)
   LOCAL aP, aR
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un proveedor", "Aviso"); RETURN; ENDIF
   aP := aData[nRow]
   aR := ProvEditDialog(db, aP[1])
   IF aR != NIL
      GuardarProveedor(db, aP[1], aR[1], aR[2], aR[3], aR[4], aR[5], aR[6], aR[7], aR[8], aR[9], aR[10], aR[11], aR[12], .T.)
      aData := ObtenerProveedores(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ProvEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData); hwg_MsgInfo("Seleccione un proveedor", "Aviso"); RETURN; ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][2] + "?", "Confirmar")
      EliminarProveedor(db, aData[nRow][1])
      aData := ObtenerProveedores(db); oBrw:aArray := aData; oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ProvEditDialog(db, nId)
   LOCAL oDlg, lCancel := .F.
   LOCAL cNombre := Space(50), cNif := Space(15), cNifIva := Space(15)
   LOCAL nTipoIdSel := 1, nPaisSel := 1
   LOCAL cDireccion := Space(50), cPoblacion := Space(30), cProvincia := Space(25)
   LOCAL cCp := Space(10), cTelefono := Space(15), cEmail := Space(30), cIban := Space(24)
   LOCAL aPaises, aTiposId, aProv

   aPaises := ObtenerPaises(db); aTiposId := ObtenerTiposIdentificacion(db)
   IF nId != 0
      aProv := ObtenerProveedorPorId(db, nId)
      IF aProv != NIL
         cNombre := PadR(aProv[2], 50); cNif := PadR(aProv[3], 15); cNifIva := PadR(aProv[4], 15)
         cDireccion := PadR(aProv[5], 50); cPoblacion := PadR(aProv[6], 30); cProvincia := PadR(aProv[7], 25)
         cCp := PadR(aProv[8], 10); cTelefono := PadR(aProv[9], 15); cEmail := PadR(aProv[10], 30)
         cIban := PadR(aProv[11], 24)
         nPaisSel := Max(AScan(aPaises, {|x| x[1] == aProv[13]}), 1)
         nTipoIdSel := Max(AScan(aTiposId, {|x| x[1] == aProv[14]}), 1)
      ENDIF
   ENDIF

   INIT DIALOG oDlg TITLE Iif(nId==0, "Nuevo proveedor", "Editar proveedor") AT 0,0 SIZE 520, 480 STYLE DS_CENTER
   @ 20, 15 SAY L("ProveedoresNombreLabel") SIZE 80, 22
   @ 110, 13 GET cNombre SIZE 370, 26
   @ 20, 48 SAY "NIF:" SIZE 80, 22
   @ 110, 46 GET cNif SIZE 150, 26
   @ 20, 81 SAY "NIF IVA:" SIZE 80, 22
   @ 110, 79 GET cNifIva SIZE 150, 26
   @ 20, 114 SAY "ID Fiscal:" SIZE 80, 22
   @ 110, 112 COMBOBOX nTipoIdSel ITEMS ListaProvTiposId(aTiposId) SIZE 200, 200
   @ 20, 147 SAY L("ProveedoresPais") SIZE 80, 22
   @ 110, 145 COMBOBOX nPaisSel ITEMS ListaProvPaises(aPaises) SIZE 200, 200
   @ 20, 180 SAY L("ProveedoresDireccion") SIZE 80, 22
   @ 110, 178 GET cDireccion SIZE 370, 26
   @ 20, 213 SAY L("ProveedoresPoblacionLabel") SIZE 80, 22
   @ 110, 211 GET cPoblacion SIZE 200, 26
   @ 290, 213 SAY L("ProveedoresProvincia") SIZE 80, 22
   @ 370, 211 GET cProvincia SIZE 120, 26
   @ 20, 246 SAY "C.Postal:" SIZE 80, 22
   @ 110, 244 GET cCp SIZE 100, 26
   @ 20, 279 SAY L("ProveedoresTelefonoLabel") SIZE 80, 22
   @ 110, 277 GET cTelefono SIZE 150, 26
   @ 290, 279 SAY L("ProveedoresEmailLabel") SIZE 80, 22
   @ 370, 277 GET cEmail SIZE 120, 26
   @ 20, 312 SAY L("ProveedoresIban") SIZE 80, 22
   @ 110, 310 GET cIban SIZE 200, 26
   @ 140, 440 BUTTON L("ProveedoresGuardar") SIZE 90, 30 ON CLICK {|| ProvGuardarConIban(AllTrim(cIban), oDlg) }
   @ 280, 440 BUTTON L("ProveedoresCancelar") SIZE 90, 30 ON CLICK {|| lCancel := .T., oDlg:Close()}
   ACTIVATE DIALOG oDlg CENTER
   IF lCancel; RETURN NIL; ENDIF
   RETURN { AllTrim(cNombre), AllTrim(cNif), Iif(Empty(cNifIva), NIL, AllTrim(cNifIva)), ;
      Iif(nTipoIdSel>0, aTiposId[nTipoIdSel][1], 0), Iif(nPaisSel>0, aPaises[nPaisSel][1], 0), ;
      AllTrim(cDireccion), AllTrim(cPoblacion), AllTrim(cProvincia), ;
      AllTrim(cCp), AllTrim(cTelefono), AllTrim(cEmail), AllTrim(cIban) }

STATIC FUNCTION ListaProvPaises(aPaises)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aPaises)
      AAdd(aNombres, aPaises[nI][2])
   NEXT
   RETURN aNombres

STATIC FUNCTION ExportPdfProveedores(db, aData)
   LOCAL aCols := { ;
      {L("ProveedoresNombre"), 200, 2}, ;
      {L("ProveedoresNif"), 120, 3}, ;
      {L("ProveedoresPoblacion"), 150, 5}, ;
      {L("ProveedoresTelefono"), 120, 7}, ;
      {L("CommonActivo"), 50, 10, .T.} }
   LOCAL cPath := AbrirListadoPdf(db, L("ProveedoresTitle"), aData, aCols)
   IF !Empty(cPath); hwg_MsgInfo("PDF generado: " + cPath, L("CommonExportar")); ENDIF
RETURN NIL

STATIC FUNCTION ListaProvTiposId(aTipos)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aTipos)
      AAdd(aNombres, aTipos[nI][2])
   NEXT
   RETURN aNombres

STATIC FUNCTION ProvGuardarConIban(cIban, oDlg)
   IF !ValidarIBAN(cIban)
      hwg_MsgInfo(L("ValidationIbanFormato"), "IBAN")
   ELSE
      oDlg:Close()
   ENDIF
RETURN NIL
