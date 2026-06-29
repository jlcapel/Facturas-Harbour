#include "hwgui.ch"

FUNCTION GastoEditDialog(db, nGastoId)
   LOCAL oDlg, lCancel := .F., nResult := 0
   LOCAL aGasto, aGastoArr
   LOCAL cNumero := "", dFechaEmi := Date(), dFechaOp := NIL, dFechaRec := Date()
   LOCAL nTipoDoc := 0, nProveedorSel := 0, nCategoriaSel := 0
   LOCAL cDescripcion := Space(200)
   LOCAL nBaseImp := 0, nIvaPct := 21.00, nIvaImp := 0
   LOCAL nRetPct := 0, nRetImp := 0, nTotal := 0
   LOCAL nMedioPago := 1
   LOCAL lPagado := .F., dFechaPago := NIL
   LOCAL cObservaciones := Space(200)
   LOCAL lIvaDeducible := .T., nBienSel := 0
   LOCAL nGastoDeducible := 0

   LOCAL aProveedores, aCategorias, aBienes
   LOCAL aTiposDoc := {"Factura", "Ticket Simplificada", "Recibo", "DUA", "Otro"}
   LOCAL aMediosPago := {"Efectivo", "Transferencia", "Tarjeta", "Domiciliación", "Otro"}

   aProveedores := ObtenerProveedores(db)
   aCategorias := ObtenerCategoriasGasto(db)
   aBienes := ObtenerBienesInversion(db)

   IF nGastoId != 0
      aGasto := ObtenerGastoPorId(db, nGastoId)
      IF aGasto == NIL
         hwg_MsgInfo("Gasto no encontrado", "Error")
         RETURN 0
      ENDIF
      cNumero := aGasto[2]
      dFechaEmi := aGasto[4]
      IF aGasto[5] != NIL; dFechaOp := aGasto[5]; ENDIF
      dFechaRec := aGasto[6]
      nTipoDoc := aGasto[7]
      nProveedorSel := Max(AScan(aProveedores, {|x| x[1] == aGasto[8]}), 1)
      nCategoriaSel := 0
      IF aGasto[9] != NIL
         nCategoriaSel := Max(AScan(aCategorias, {|x| x[1] == aGasto[9]}), 0)
      ENDIF
      cDescripcion := PadR(aGasto[10], 200)
      nBaseImp := aGasto[11]; nIvaPct := aGasto[12]; nIvaImp := aGasto[13]
      nRetPct := aGasto[14]; nRetImp := aGasto[15]; nTotal := aGasto[16]
      nMedioPago := aGasto[18] + 1
      lPagado := aGasto[19]
      IF aGasto[20] != NIL; dFechaPago := CToD(aGasto[20]); ENDIF
      cObservaciones := PadR(aGasto[21], 200)
      lIvaDeducible := aGasto[23]
      IF aGasto[24] != NIL
         nBienSel := Max(AScan(aBienes, {|x| x[1] == aGasto[24]}), 0)
      ENDIF
   ELSE
      cNumero := ""
      dFechaRec := Date()
   ENDIF

   INIT DIALOG oDlg ;
      TITLE Iif(nGastoId == 0, "Nuevo gasto", "Editar gasto") ;
      AT 0, 0 ;
      SIZE 720, 520 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   @ 20, 15 SAY "Nº Factura:" SIZE 80, 22
   @ 110, 13 GET cNumero SIZE 150, 26
   @ 300, 15 SAY "Tipo doc.:" SIZE 80, 22
   @ 380, 13 COMBOBOX nTipoDoc ITEMS aTiposDoc SIZE 160, 200
   @ 20, 48 SAY "Fecha emisión:" SIZE 100, 22
   @ 130, 46 GET dFechaEmi SIZE 110, 26
   @ 300, 48 SAY "Fecha recepción:" SIZE 110, 22
   @ 420, 46 GET dFechaRec SIZE 110, 26
   @ 20, 81 SAY "Proveedor:" SIZE 80, 22
   @ 110, 79 COMBOBOX nProveedorSel ITEMS ListaProvNombres(aProveedores) SIZE 300, 200
   @ 20, 114 SAY "Categoría:" SIZE 80, 22
   @ 110, 112 COMBOBOX nCategoriaSel ITEMS ListaCatNombres(aCategorias) SIZE 250, 200
   @ 20, 147 SAY "Descripción:" SIZE 80, 22
   @ 110, 145 GET cDescripcion SIZE 500, 26
   @ 20, 180 GROUPBOX "Importes" SIZE 680, 170
   @ 30, 200 SAY "Base Imponible:" SIZE 110, 22
   @ 150, 198 GET nBaseImp PICTURE "9999999.99" SIZE 120, 26
   @ 310, 200 SAY "% IVA:" SIZE 50, 22
   @ 370, 198 GET nIvaPct PICTURE "99.99" SIZE 80, 26
   @ 30, 233 SAY "% Retención:" SIZE 100, 22
   @ 150, 231 GET nRetPct PICTURE "99.99" SIZE 80, 26
   @ 30, 266 SAY "IVA:" SIZE 100, 22
   @ 150, 264 SAY Str(nIvaImp, 12, 2) SIZE 110, 26
   @ 310, 266 SAY "Retención:" SIZE 80, 22
   @ 400, 264 SAY Str(nRetImp, 12, 2) SIZE 110, 26
   @ 30, 299 SAY "TOTAL:" SIZE 100, 22
   @ 150, 297 SAY Str(nTotal, 12, 2) SIZE 120, 26
   @ 310, 299 SAY "Gasto deducible IRPF:" SIZE 130, 22
   @ 450, 297 SAY Str(nGastoDeducible, 12, 2) SIZE 110, 26
   @ 30, 355 SAY "Medio pago:" SIZE 80, 22
   @ 130, 353 COMBOBOX nMedioPago ITEMS aMediosPago SIZE 160, 200
   @ 330, 355 CHECKBOX lPagado CAPTION "Pagado" SIZE 80, 26
   @ 30, 388 SAY "Observaciones:" SIZE 100, 22
   @ 140, 386 GET cObservaciones SIZE 480, 26
   @ 30, 421 CHECKBOX lIvaDeducible CAPTION "IVA Deducible" SIZE 130, 26

   @ 320, 490 BUTTON "Guardar" SIZE 90, 28 ON CLICK {;
      nResult := GuardarGastoDesdeDialog(db, nGastoId, cNumero, dFechaEmi, dFechaOp, dFechaRec, ;
         nTipoDoc, aProveedores, nProveedorSel, aCategorias, nCategoriaSel, ;
         cDescripcion, nBaseImp, nIvaPct, nRetPct, ;
         nMedioPago, lPagado, dFechaPago, cObservaciones, lIvaDeducible, aBienes, nBienSel), ;
      Iif(nResult > 0, oDlg:Close(), NIL) }
   @ 470, 490 BUTTON "Cancelar" SIZE 90, 28 ON CLICK {|| lCancel := .T., oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   IF lCancel
      RETURN 0
   ENDIF
   RETURN nResult

STATIC FUNCTION ListaProvNombres(aProvs)
   LOCAL aN := {}, nI
   FOR nI := 1 TO Len(aProvs)
      AAdd(aN, aProvs[nI][2])
   NEXT
   RETURN aN

STATIC FUNCTION ListaCatNombres(aCats)
   LOCAL aN := {}, nI
   FOR nI := 1 TO Len(aCats)
      AAdd(aN, aCats[nI][2])
   NEXT
   RETURN aN

STATIC FUNCTION GuardarGastoDesdeDialog(db, nGastoId, cNumero, dFechaEmi, dFechaOp, dFechaRec, ;
      nTipoDoc, aProveedores, nProveedorSel, aCategorias, nCategoriaSel, ;
      cDescripcion, nBaseImp, nIvaPct, nRetPct, ;
      nMedioPago, lPagado, dFechaPago, cObservaciones, lIvaDeducible, aBienes, nBienSel)
   LOCAL nProveedorId, aGastoArr, nResult
   LOCAL nIvaImp, nRetImp, nTotal, nGastoDeducible, lCatIvaDeducible

   IF nProveedorSel < 1 .OR. nProveedorSel > Len(aProveedores)
      hwg_MsgInfo("Seleccione un proveedor", "Aviso")
      RETURN 0
   ENDIF
   nProveedorId := aProveedores[nProveedorSel][1]

   nIvaImp := Redondear(nBaseImp * nIvaPct / 100)
   nRetImp := Redondear(nBaseImp * nRetPct / 100)
   nTotal := Redondear(nBaseImp + nIvaImp - nRetImp)

   lCatIvaDeducible := lIvaDeducible
   nGastoDeducible := nBaseImp
   IF nCategoriaSel > 0 .AND. nCategoriaSel <= Len(aCategorias)
      nGastoDeducible := Redondear(nBaseImp * Val(aCategorias[nCategoriaSel][3]) / 100)
      lCatIvaDeducible := aCategorias[nCategoriaSel][4]
   ENDIF

   aGastoArr := Array(23)
   aGastoArr[1] := AllTrim(cNumero)
   aGastoArr[2] := NIL
   aGastoArr[3] := dFechaEmi
   aGastoArr[4] := dFechaOp
   aGastoArr[5] := dFechaRec
   aGastoArr[6] := nTipoDoc
   aGastoArr[7] := nProveedorId
   aGastoArr[8] := Iif(nCategoriaSel > 0, aCategorias[nCategoriaSel][1], NIL)
   aGastoArr[9] := AllTrim(cDescripcion)
   aGastoArr[10] := nBaseImp
   aGastoArr[11] := nIvaPct
   aGastoArr[12] := nIvaImp
   aGastoArr[13] := nRetPct
   aGastoArr[14] := nRetImp
   aGastoArr[15] := nTotal
   aGastoArr[16] := Str(nGastoDeducible, 12, 2)
   aGastoArr[17] := nMedioPago - 1
   aGastoArr[18] := lPagado
   aGastoArr[19] := dFechaPago
   aGastoArr[20] := AllTrim(cObservaciones)
   aGastoArr[21] := ""
   aGastoArr[22] := lCatIvaDeducible
   aGastoArr[23] := Iif(nBienSel > 0, aBienes[nBienSel][1], NIL)

   IF nGastoId == 0
      nResult := CrearGasto(db, aGastoArr)
   ELSE
      IF ActualizarGasto(db, nGastoId, aGastoArr)
         nResult := nGastoId
      ELSE
         nResult := 0
      ENDIF
   ENDIF

   IF nResult > 0
      hwg_MsgInfo("Gasto " + AllTrim(cNumero) + " guardado", "Información")
   ELSE
      hwg_MsgInfo("Error al guardar el gasto", "Error")
   ENDIF
   RETURN nResult

STATIC FUNCTION Redondear(nVal)
   RETURN Int(nVal * 100 + 0.5) / 100
