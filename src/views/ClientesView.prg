#include "hwgui.ch"

FUNCTION ClientesView(db)
   LOCAL oDlg, oBrw, aData

   aData := ObtenerClientes(db)

   INIT DIALOG oDlg ;
      TITLE "Clientes" ;
      AT 0, 0 ;
      SIZE 750, 500 ;
      STYLE WS_POPUP + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 20, 20 BROWSE oBrw ARRAY SIZE 550, 400 STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   oBrw:aArray := aData
   oBrw:AddColumn(HColumn():New("Nombre", {|v,o| (v), o:aArray[o:nCurrent, 2]}, "C", 25, 0))
   oBrw:AddColumn(HColumn():New("NIF", {|v,o| (v), o:aArray[o:nCurrent, 4]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New("Población", {|v,o| (v), o:aArray[o:nCurrent, 9]}, "C", 15, 0))
   oBrw:AddColumn(HColumn():New("Teléfono", {|v,o| (v), o:aArray[o:nCurrent, 12]}, "C", 14, 0))
   oBrw:AddColumn(HColumn():New("Activo", {|v,o| (v), iif(o:aArray[o:nCurrent, 14], "Sí", "No")}, "C", 8, 0, .F., DT_CENTER))

   @ 30, 440 BUTTON "Nuevo" SIZE 70, 28 ON CLICK {|| ClienteNuevo(db, @aData, oBrw)}
   @ 110, 440 BUTTON "Editar" SIZE 70, 28 ON CLICK {|| ClienteEditar(db, @aData, oBrw, oBrw:nCurrent)}
   @ 190, 440 BUTTON "Eliminar" SIZE 70, 28 ON CLICK {|| ClienteEliminar(db, @aData, oBrw)}
   @ 600, 440 BUTTON "Volver" SIZE 70, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION ClienteNuevo(db, aData, oBrw)
   LOCAL aResult := ClienteEditDialog(db, 0)
   IF aResult != NIL
      GuardarCliente(db, 0, aResult[1], aResult[2], aResult[3], aResult[4], aResult[5], ;
         aResult[6], aResult[7], aResult[8], aResult[9], aResult[10], aResult[11], aResult[12], .T.)
      aData := ObtenerClientes(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ClienteEditar(db, aData, oBrw, nRow)
   LOCAL aCliente, aResult
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un cliente", "Aviso")
      RETURN
   ENDIF
   aCliente := aData[nRow]
   aResult := ClienteEditDialog(db, aCliente[1])
   IF aResult != NIL
      GuardarCliente(db, aCliente[1], aResult[1], aResult[2], aResult[3], aResult[4], aResult[5], ;
         aResult[6], aResult[7], aResult[8], aResult[9], aResult[10], aResult[11], aResult[12], .T.)
      aData := ObtenerClientes(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ClienteEliminar(db, aData, oBrw)
   LOCAL nRow := oBrw:nCurrent
   IF nRow < 1 .OR. nRow > Len(aData)
      hwg_MsgInfo("Seleccione un cliente", "Aviso")
      RETURN
   ENDIF
   IF hwg_MsgYesNo("¿Eliminar " + aData[nRow][2] + "?", "Confirmar")
      EliminarCliente(db, aData[nRow][1])
      aData := ObtenerClientes(db)
      oBrw:aArray := aData
      oBrw:Refresh()
   ENDIF
RETURN NIL

STATIC FUNCTION ClienteEditDialog(db, nId)
   LOCAL oDlg, lCancel := .F.
   LOCAL cNombre := Space(50), nTipoCliente := 0, nPaisId := 0, nTipoIdId := 0
   LOCAL cNif := Space(15), cNifIva := Space(15)
   LOCAL cDireccion := Space(50), cPoblacion := Space(30), cProvincia := Space(25)
   LOCAL cCp := Space(10), cTelefono := Space(15), cEmail := Space(30)
   LOCAL aPaises, aTiposId, aTipoCliente := {"Nacional", "Intracomunitario", "Extracomunitario"}
   LOCAL nPaisSel := 1, nTipoIdSel := 1, nTipoClienteSel := 1, aCli

   aPaises := ObtenerPaises(db)
   aTiposId := ObtenerTiposIdentificacion(db)

   IF nId != 0
      aCli := ObtenerClientePorId(db, nId)
      IF aCli != NIL
         cNombre := PadR(aCli[2], 50)
         nTipoCliente := aCli[3]
         nPaisId := aCli[5]
         nTipoIdId := aCli[6]
         cNif := PadR(aCli[4], 15)
         cNifIva := PadR(aCli[7], 15)
         cDireccion := PadR(aCli[8], 50)
         cPoblacion := PadR(aCli[9], 30)
         cProvincia := PadR(aCli[10], 25)
         cCp := PadR(aCli[11], 10)
         cTelefono := PadR(aCli[12], 15)
         cEmail := PadR(aCli[13], 30)
         nTipoClienteSel := nTipoCliente + 1
         nPaisSel := AScan(aPaises, {|x| x[1] == nPaisId})
         IF nPaisSel == 0; nPaisSel := 1; ENDIF
         nTipoIdSel := AScan(aTiposId, {|x| x[1] == nTipoIdId})
         IF nTipoIdSel == 0; nTipoIdSel := 1; ENDIF
      ENDIF
   ENDIF

   INIT DIALOG oDlg TITLE "Editar cliente" AT 0,0 SIZE 520, 480 STYLE DS_CENTER

   @ 20, 15 SAY "Nombre:" SIZE 80, 22
   @ 110, 13 GET cNombre SIZE 370, 26

   @ 20, 48 SAY "Tipo:" SIZE 80, 22
   @ 110, 46 COMBOBOX nTipoClienteSel ITEMS aTipoCliente SIZE 150, 200

   @ 20, 81 SAY "País:" SIZE 80, 22
   @ 110, 79 COMBOBOX nPaisSel ITEMS ListaPaisesNombres(aPaises) SIZE 200, 200

   @ 20, 114 SAY "ID Fiscal:" SIZE 80, 22
   @ 110, 112 COMBOBOX nTipoIdSel ITEMS ListaTiposIdNombres(aTiposId) SIZE 200, 200

   @ 20, 147 SAY "NIF:" SIZE 80, 22
   @ 110, 145 GET cNif SIZE 150, 26

   @ 20, 180 SAY "NIF IVA:" SIZE 80, 22
   @ 110, 178 GET cNifIva SIZE 150, 26

   @ 20, 213 SAY "Dirección:" SIZE 80, 22
   @ 110, 211 GET cDireccion SIZE 370, 26

   @ 20, 246 SAY "Población:" SIZE 80, 22
   @ 110, 244 GET cPoblacion SIZE 200, 26

   @ 290, 246 SAY "Provincia:" SIZE 80, 22
   @ 370, 244 GET cProvincia SIZE 120, 26

   @ 20, 279 SAY "C.Postal:" SIZE 80, 22
   @ 110, 277 GET cCp SIZE 100, 26

   @ 20, 312 SAY "Teléfono:" SIZE 80, 22
   @ 110, 310 GET cTelefono SIZE 150, 26

   @ 290, 312 SAY "Email:" SIZE 80, 22
   @ 370, 310 GET cEmail SIZE 120, 26

   @ 140, 420 BUTTON "Guardar" SIZE 90, 30 ON CLICK {|| oDlg:Close()}
   @ 280, 420 BUTTON "Cancelar" SIZE 90, 30 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF lCancel
      RETURN NIL
   ENDIF

   nPaisId := Iif(nPaisSel > 0 .AND. nPaisSel <= Len(aPaises), aPaises[nPaisSel][1], 0)
   nTipoIdId := Iif(nTipoIdSel > 0 .AND. nTipoIdSel <= Len(aTiposId), aTiposId[nTipoIdSel][1], 0)

   RETURN { AllTrim(cNombre), nTipoClienteSel - 1, nPaisId, nTipoIdId, ;
      AllTrim(cNif), Iif(Empty(cNifIva), NIL, AllTrim(cNifIva)), ;
      AllTrim(cDireccion), AllTrim(cPoblacion), AllTrim(cProvincia), ;
      AllTrim(cCp), AllTrim(cTelefono), AllTrim(cEmail) }

STATIC FUNCTION ListaPaisesNombres(aPaises)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aPaises)
      AAdd(aNombres, aPaises[nI][3])
   NEXT
   RETURN aNombres

STATIC FUNCTION ListaTiposIdNombres(aTipos)
   LOCAL aNombres := {}, nI
   FOR nI := 1 TO Len(aTipos)
      AAdd(aNombres, aTipos[nI][3])
   NEXT
   RETURN aNombres
